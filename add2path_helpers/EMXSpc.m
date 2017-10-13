classdef EMXSpc
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filename
        spc
        ns
    end
    
    methods
        function obj = EMXSpc(filename)
            if nargin > 0
                obj.filename = filename;
                [path, basename, ext] = fileparts(filename);
                
                spcfilename = [path, basename, '.spc'];
                spcfilename
                
                [B,spc, para] = eprload([spcfilename]);

            end
        end
    end
    
end

classdef MyClass
   properties
      Prop
   end
   methods
      function obj = MyClass(val)
         if nargin > 0
            obj.Prop = val;
         end
      end
   end
end
