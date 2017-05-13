classdef spcFiles
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root
        dataset
        dataFiles
        legends
        spcFileList
        selection
    end
    
    methods
        function obj = setRoot(obj, var)
            obj.root = uigetdir('SPC file folder');
        end
        function obj = setDataset(obj, var)
            datasetFilename = [obj.root, '\', 'dataset.csv'];
            obj.dataset = read_mixed_csv(datasetFilename, ',');
        end
        function obj = setSelection(obj, var)
            [Selection, ok] = listdlg('PromptString', 'Select a file:',...
                'ListString', obj.dataset(2:end, 8), ...
                'SelectionMode','multiple');
            obj.Selection = Selection;
        end
        function obj = setDataFiles(obj, var)
            obj.dataFiles = obj.dataset(Selection + 1, 1);  % Raw data
            obj.legends = obj.dataset(Selection + 1, 8);
        end
        
        function obj = load(var)
            obj.setRoot();
            obj.setDataset();
            
            
            
            
            for iii = 1:length(dataFiles)
                
                eprspec = eprSpec;
                eprspec.filename = datFile{iii};
                
            end
            
            
            obj.root = root;
            obj.Selection = Selection;
        end
        function eprSpec2 = subtract(obj, eprSpec1)
            eprSpec2 = obj;
            eprSpec2.spc = obj.spc - eprSpec1.spc;
        end
    end
    
end

