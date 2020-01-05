classdef CWSpc
    % parent class of 1D and 2D CWSpc
    properties
        B, spc
        acqParams  % acquisition parameters, including MW power, receiver gain,
        % modulation amp, time constants, conversion time
    end
    properties (Dependent)
        NX  % size of the 1st dimension
        NY  % size of the 2nd dimension
        is1d, is2d  % type of cwspc
    end
    methods
        function is2d = get.is2d(obj)
            is2d = isfield(obj.acqParams, 'REY');
        end
        function is1d = get.is1d(obj)
            is1d = ~obj.is2d;
        end
        function NX = get.NX(obj)
            if obj.is1d
                NX = obj.acqParams.ANZ;
            else
                NX = obj.acqParams.SSX;
            end
        end
        function NY = get.NY(obj)
            if obj.is1d
                NY = 1;
            else
                NY = obj.acqParams.SSY;
            end
        end
    end
    methods
        function obj = CWSpc(FileName)
            if nargin == 0
                return
            else
                if strcmp(FileName, 'demo1D')
                    obj = obj.getdemo1D();
                elseif strcmp(FileName, 'demo2D')
                    obj = obj.getdemo2D();
                else
                    [x,y,obj.acqParams] = eprload(FileName);
                    if iscell(x)
                        obj.B = x{1};
                    else
                        obj.B = x;
                    end
                    obj.spc = y;
                    % rename a few acqparams
                    % Date Time
                    obj.acqParams.date = obj.acqParams.JDA;
                    obj.acqParams.time = obj.acqParams.JTM;
                    % Hall
                    obj.acqParams.CenterField = obj.acqParams.HCF;
                    obj.acqParams.SweepWidth = obj.acqParams.HSW;
                    % MW Bridge
                    obj.acqParams.MPowerDamp = obj.acqParams.MPD;
                    % Receiver
                    obj.acqParams.RGain = obj.acqParams.RRG;
                    obj.acqParams.ModAmp = obj.acqParams.RMA;
                    obj.acqParams.tconst = obj.acqParams.RTC;
                    obj.acqParams.tconv = obj.acqParams.RCT;
                end
            end
        end
        function obj = bshift(obj, x)
        end
        function obj = bdrift(obj, cwspc)
        end
        function obj = subtractbg(obj, cwspc)
        end
        function obj = scale(obj, scale)
        end
        function issameparam = sameparams(obj, cwspc)
            if nargin == 1
                throw(MException('CWSpc:NoArgin', ''));
            end
            issameparam = ...
                obj.is1d == cwspc.is1d && ...  % same dimension
                obj.NX == cwspc.NX && ...  % same X resolution
                obj.acqParams.CenterField == cwspc.acqParams.CenterField && ...
                obj.acqParams.SweepWidth == cwspc.acqParams.SweepWidth && ...
                obj.acqParams.MPowerDamp == cwspc.acqParams.MPowerDamp && ...
                obj.acqParams.RGain == cwspc.acqParams.RGain && ...
                obj.acqParams.ModAmp == cwspc.acqParams.ModAmp && ...
                obj.acqParams.tconst == cwspc.acqParams.tconst && ...
                obj.acqParams.tconv == cwspc.acqParams.tconv;
        end
        function h = line(obj)
            if obj.is2d
                obj = obj.mean();
            end
            h = line(obj.B, obj.spc);
        end
        %% CWspc.is2d
        function obj = mean(obj, slices)
        end
        function obj = sum(obj, slices)
        end
        function obj = partsum(obj, slices)
        end
    end
    methods (Static)
        function issameparams = allsameparams(cwspc)
            if numel(cwspc) == 1
                issameparams = true;
                return
            else
                issameparams = true;
                for ii = 1:numel(cwspc)
                    issameparams = issameparams && cwspc(1).sameparams(cwspc(ii));
                end
                return
            end
        end
        function f = stackplot(cwspc)
            assert(CWSpc.allsameparams(cwspc));
            f = CWSpc.myFigure();
            for ii = 1:numel(cwspc)
                assert(cwspc(ii).is1d)
                hData(ii) = cwspc(ii).scale().line();
                % Adjust Line Properties (Functional)
                set(hData(ii)                         , ...
                    'LineStyle'       , '-'      , ...
                    'Color'           , getColor(ii)         );
                % Adjust Line Properties (Esthetics)
                set(hData(ii)                         , ...
                    'Marker'          , 'none'      , ...
                    'LineWidth'       , 1.5                );
            end
        end
    end
    methods (Hidden)
        function obj = getdemo1D(obj)
            obj = CWSpc('data/real1D.spc');
        end
        function obj = getdemo2D(obj)
            obj = CWSpc('data/real2D.spc');
        end
    end
    methods (Hidden, Static)
        function f = myFigure(width, height)
            if nargin < 1
                width = 3.42;
                height = 3.42;
            end
            f = figure('rend','painters',...'pos',[100 100 375 800/2],...
                'Units', 'inches', ...
                'pos', [0 0 width height]);
            set(f.Children, ...
                'FontName',     'Helvetica', ...
                'FontSize',     12);
            set(gca,'LooseInset', max(get(gca,'TightInset'), 0.01))
            
            pos = get(f,'Position');
            set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
            
        end
    end
end


