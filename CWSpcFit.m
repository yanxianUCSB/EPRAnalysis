classdef CWSpcFit < CWSpc
    properties
        A, g,  
        Components  % struct of multiple components
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
            %% esfit
        function esfit(obj)
            % fit one component and vary rotational correlation time
        end
    end
end