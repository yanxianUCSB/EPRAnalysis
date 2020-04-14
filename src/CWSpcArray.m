% an array of CWSpc to handle group of CWSpc, like stackplot
classdef CWSpcArray
    properties
        cwsarray = CWSpc().empty();
    end
    methods
        function obj = CWSpcArray(FileNames, pathin)
            if nargin < 2
                pathin = '';
            end
            if nargin < 1
                return
            end
            for ii = 1:numel(FileNames)
                obj.cwsarray(ii) = CWSpc(char(strcat(pathin, filesep, FileNames{ii}, '.spc')));
            end
        end
        function [f, h] = stackplot(obj, legends)
            if nargin < 1
                legends = {};
            end
            for ii = 1:numel(obj.cwsarray)
                if obj.cwsarray(ii).is1d
                    obj.cwsarray(ii) = obj.cwsarray(ii).mean();
                else
                    obj.cwsarray(ii) = obj.cwsarray(ii).rmzeros().rmbadscans().mean();
                end
            end
            [f, h] = CWSpc.stackplot(obj.cwsarray, legends);
        end
    end
    
    
end
