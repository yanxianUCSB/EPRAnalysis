classdef CWSpcFit < CWSpc
    properties
        A, g,
        Components  % struct of multiple components
        Sys  % System structure for easyspin
        Exp  % Experiment struct for easyspin
        fitspc
    end
    methods % setters and getters
        function obj = set_sys_nitroxide(obj)
            obj.Sys.A=mt2mhz([0.62 0.59 3.7]);
            obj.Sys.g=[2.0078 2.0058 2.0022];
            obj.Sys.S=1/2;
            obj.Sys.Nucs='14N';
        end
        function obj = set_exp_acqu(obj)
            obj.Exp.mwFreq = obj.acqParams.MF;
            obj.Exp.Range = obj.acqParams.CenterField + obj.acqParams.SweepWidth * 0.5 * [-1, 1];
            obj.Exp.nPoints = length(obj.B);
        end
    end
    methods
        function obj = CWSpcFit(FileName)
            if nargin == 0
                superargs = {};
            else
                superargs = {FileName};
            end
            % Superclass constructor
            obj@CWSpc(superargs{:});
        end
        
        function obj = fix_mwFreq(obj)
            assert(~isempty(obj.Sys) && ~isempty(obj.Exp));
            obj.Exp.mwFreq = obj.find_mwFreq(obj.spc, obj.Sys, obj.Exp);
        end
        %% esfit
        function obj = esfit_garlic_logtcorr(obj, logtcorr0)
            % fit logtcorr to current Sys struct
            if nargin == 1
                logtcorr0 = -9;
            end
            obj.Sys.logtcorr = -9;
            Vary.logtcorr = 1;
            obj = obj.esfit('garlic', obj.Sys, Vary, obj.Exp);
        end
        
        function obj = esfit(obj, simfunc, Sys0, Vary, Exp)
            % use esfit to fit current spectrum            
            [obj.Sys, obj.fitspc] = esfit(simfunc, obj.spc, Sys0, Vary, Exp);
        end
        
    end
    
    methods (Static)
        function [x]=find_mwFreq(spc, Sys, Exp)
            % find the correct Exp.mwFreq for the spc
            % Sys, Exp: see definitions in easyspin
            spc = reshape(spc, [1, length(spc)]);
            spc = scale(cumsum(spc));
            
            function y = loss(mFreq)
                Exp.mwFreq = mFreq;
                spec = garlic(Sys, Exp);
                spec = scale(cumsum(spec));
                y = sqrt(mean((spec - spc).^2));
                %         plot(data_spc); hold on ;
                %         plot(spec); hold off
                %         title([num2str(mFreq), ' ', num2str(y)]);
            end
            
            function y = scale(y)
                y = (y - min(y))/(max(y)-min(y)) - 0.5;
            end
            
            x = fminbnd(@loss, Exp.mwFreq*0.95, Exp.mwFreq*1.02);
        end
        
    end
end