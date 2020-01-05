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
                    % rename a few acqparams
                    obj.acqParams.npoints = obj.acqParams.ANZ;
                    obj.acqParams.date = obj.acqParams.JDA;
                    obj.acqParams.time = obj.acqParams.JTM;
                    obj.acqParams.RGain = obj.acqParams.RRG;
                    obj.acqParams.MPowerDamp = obj.acqParams.MPD;
                    obj.acqParams.ModAmp = obj.acqParams.RMA;
                    obj.acqParams.tconst = obj.acqParams.RTC;
                    obj.acqParams.tconv = obj.acqParams.RCT;
                end
            end
        end
        function show(obj)
            
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
end
        
        
       