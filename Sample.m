classdef Sample
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        spcList
        bgspec
        assayX
        assayY
    end
    
    methods
        function obj = bgCor(obj, var)
            for i = 1:length(obj.spcList)
                eprspec = obj.spcList(i);
                obj.spcList(i) = eprspec.subtract(obj.bgspec);
            end
        end
    end
    
end

