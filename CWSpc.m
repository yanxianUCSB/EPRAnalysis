classdef CWSpc
    % parent class of 1D and 2D CWSpc
    properties
        B, spc
        acqParams  % acquisition parameters, including MW power, receiver gain, 
                   % modulation amp, time constants, conversion time
        NA  % num of acquisition
    end
    properties (Dependent)
        NY  % size of the 2nd dimension
        is1d, is2d  % type of cwspc
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
    end
    methods (Hidden)
        function obj = getdemo1D(obj)
        end
        function obj = getdemo2D(obj)
        end
    end
end
        
        
       