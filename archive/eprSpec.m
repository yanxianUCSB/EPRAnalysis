classdef eprSpec
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mata;
        spc;
        B;
        filename;
    end
    
    methods
        function eprLoad(var)
            dat = load(filename);
            obj.B = as.matrix(dat(:,1));
            obj.spc = as.matrix(dat(:,2:end)); 
        end
        function eprSpec2 = subtract(obj, eprSpec1)
            eprSpec2 = obj;
            eprSpec2.spc = obj.spc - eprSpec1.spc;
        end
    end
    
end

