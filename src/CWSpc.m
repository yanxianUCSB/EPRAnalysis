classdef CWSpc
    % parent class of 1D and 2D CWSpc
    % Error Identifier
    % CWSPC:DimError    1D/2D CWSpc input error
    % CWSPC:NoArgin
    properties
        B, spc
        acqParams  % acquisition parameters, including MW power, receiver gain,
                   % modulation amp, time constants, conversion time
    end
    properties (Dependent)
        NX  % size of the 1st dimension
        NY  % size of the 2nd dimension
        is1d, is2d  % type of cwspc
        NScan  % number of scan per 1 row of spc
    end
    properties (Hidden)
        iBASELINE  % regions to define as baseline for noise control
    end
    methods
        function is2d = get.is2d(obj)
            is2d = size(obj.spc, 2) > 1;
        end
        function is1d = get.is1d(obj)
            is1d = ~obj.is2d;
        end
        function NX = get.NX(obj)
            %' number of points at x dim
            NX = size(obj.spc, 1);
        end
        function NY = get.NY(obj)
            %' number of points at y dim
            NY = size(obj.spc, 2);
        end
        function NScan = get.NScan(obj)
            %' number of acquisitions per spc
            NScan = obj.acqParams.NScan;
        end
        function obj = set.NScan(obj, NScan)
            obj.acqParams.NScan = NScan;
        end
    end
    
    methods
    
        function obj = CWSpc(FileName)
            if nargin == 0
                return
            end
            [x,y,obj.acqParams] = eprload(FileName);
            if iscell(x)
                obj.B = reshape(x{1}, obj.acqParams.SSX, 1);
                obj.spc = reshape(y, obj.acqParams.SSX, obj.acqParams.SSY);
            else
                obj.B = reshape(x, obj.acqParams.ANZ, 1);
                obj.spc = reshape(y, obj.acqParams.ANZ, 1);
            end
            % rename a few acqparams
            % Date Time
            obj.acqParams.date = obj.acqParams.JDA;
            obj.acqParams.time = obj.acqParams.JTM;
            % NScan
            obj.acqParams.NScan = obj.acqParams.JNS;
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
            
            % define baseline regions
            if obj.NX == 1024
                obj.iBASELINE = [1:200 825:1024];
            end
        end
        
        function obj = bshift(obj, x)
            % use spline interpolate to map spc(b) to spc(b+x)
            throw(MException('NotImplemented'));
        end
        
        function obj = bdrift(obj, cwspc)
            % lsq fit obj to cwspc using (a*y + b).bshift(c)
            throw(MException('NotImplemented'));
        end
        
        function obj = correct_baseline(obj, tol, verbose)
            % baseline correction
            if nargin < 3
                verbose = false;
            end
            if nargin < 2
                tol = round(0.15*length(obj.B));
            end
            assert(obj.is1d, 'CWSPC:DimError', '');
            
            B_good = obj.B; spc_good = obj.spc;
            % 1st integral
            spc_cs = cumsum(spc_good);
%             plot(B_good, cumsum(spc_good))
            
            % define a region
            bs_region = [1:tol length(B_good)-tol:length(B_good)];
            
            % spline interpolate
            p = polyfit(B_good(bs_region), spc_cs(bs_region), 3);
            spc_bs = polyval(p, B_good);
            spc_cor = [0; diff(spc_cs - spc_bs)];
            if verbose
                plot(B_good, spc_cs); hold on;
                plot(B_good(bs_region), spc_cs(bs_region), '.');
                plot(B_good, spc_bs); hold off;
                legend('1st integral', 'selected region', 'baseline');
            end
            obj.spc = spc_cor;
        end
        
        function obj = subtractbg(obj, cwspc)
            assert(nargin == 2, 'CWSPC:NoArgin', '');
            assert(obj.mean().sameparams(cwspc.mean()), 'CWSPC:NotSameParams', '');
            obj.spc = obj.spc - cwspc.mean().spc / cwspc.mean().NScan * obj.NScan;
        end
        
        function obj = rescale(obj, mode)
            if nargin == 1
                mode = 'minmax';
            end
            assert(obj.is1d, 'CWSPC:DimError', '');
            obj.spc = rescale(obj.spc, mode);
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
        
        function img = image(obj)
            img = image(obj.spc, 'CDataMapping', 'scaled', 'YData', obj.B);
            xlabel('scan'); ylabel('B');
        end
        %% CWspc.is2d
        function obj = mean(obj, slices)
            if nargin == 1
                slices = 1:obj.NY;
            else
                assert(isnumeric(slices))
            end
            obj.spc = sum(obj.spc(:, slices), 2)/numel(slices);
        end
        
        function obj = sum(obj, slices)
            if nargin == 1
                slices = 1:obj.NY;
            else
                assert(isnumeric(slices))
            end
            obj.NScan = obj.NScan * numel(slices);
            obj.spc = sum(obj.spc(:, slices), 2);
        end
        
        function obj = rmzeros(obj)
            %' remove empty scans from 2D data of early-terminated acquisition
            if obj.is1d
                return
            else
                obj.spc = obj.spc(:, std(obj.spc, 1) ~= 0);
            end
        end
        
        function [obj, ibadscan] = rmbadscans(obj, igoodscans)
            if nargin == 1
                % assume first scan is a good scan
                igoodscans = 1;
            end
            if obj.is1d
                ibadscan = [];
                return
            end
            rms = @(x) sqrt(sum(x.^2));
            std_good = rms(obj.spc(obj.iBASELINE, igoodscans));
            std_base = rms(obj.spc(obj.iBASELINE, :));
            ibadscan = std_base > 1.5 * mean(std_good);
            % identify 'jumping slices' or slices with exceptional high baseline noise
            obj.spc = obj.spc(:, ~ibadscan);
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
        
        function [f, hData] = stackplot(cwspc, legends)
            %' stackplot multiple cwspc
            %'
            assert(CWSpc.allsameparams(cwspc), 'Input should all have same acq parameters');
            f = CWSpc.myFigure();
            hold on;
            for ii = 1:numel(cwspc)
                assert(cwspc(ii).is1d, 'Input is 2D not 1D')
                hData(ii) = cwspc(ii).line();
                % Adjust Line Properties (Functional)
                set(hData(ii)                         , ...
                    'LineStyle'       , '-'      , ...
                    'Color'           , getColor(ii)         );
                % Adjust Line Properties (Esthetics)
                set(hData(ii)                         , ...
                    'Marker'          , 'none'      , ...
                    'LineWidth'       , 1.5                );
                set(gca, 'XLim', [min(cwspc(ii).B), max(cwspc(ii).B)])
            end
            hold off;
            CWSpc.setaxis();
            if nargin == 2
                CWSpc.setlegends(hData, legends);
            end
        end
        
    end
    
    methods (Hidden)
    end
    
    methods (Hidden, Static)
        
        function f = myFigure(width, height)
            if nargin < 1
                width = 7;
                height = 4;
            end
            f = gcf;
            set(f, ...
                'rend','painters',...'pos',[100 100 375 800/2],...
                'Units', 'inches', ...
                'pos', [0 0 width height]);
            set(f.Children, ...
                'FontName',     'Helvetica', ...
                'FontSize',     12);            
            pos = get(f,'Position');
            set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]) 
        end
        
        function a = setaxis(a)
            if nargin == 0
                a = gca;
            end
            set(a, ...
                'FontName',     'Helvetica' , ...
                'FontSize',     8, ...
                'Box'         , 'off'     , ...
                'XTick',[],'XTickLabel',[], ...
                'YTick',[],'YTickLabel',[], ...
                'Visible'     , 'off'        , ...
                'Color'       , 'w', ...
                'LineWidth'   , 1         );
        end
        
        function h = setlegends(hData, legends)
            h = legend( ...
                [hData], ...
                legends , ...
                'location', 'NorthEast' );
            set([h, gca]             , ...
                'FontSize'   , 12           );
            set(h, 'Interpreter', 'none');
        end
        
        function export_fig(FileName)
            export_fig(FileName)
        end
        
    end
end


