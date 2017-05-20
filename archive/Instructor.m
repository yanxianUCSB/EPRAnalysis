classdef Instructor
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root
        dataFiles
        Legends
    end
    
    methods
        function obj = setup(obj, root)
        
            if ~exist('root', 'var')
                if isempty(obj.root)
                    root = uigetdir('SPC file folder');
                else
                    root = obj.root;
                end
            end
            
            datasetFilename = [root, '\', 'dataset.csv'];
            
            dataset = read_mixed_csv(datasetFilename, ',');
            [dsDim1, dsDim2] = size(dataset);
            [Selection,ok] = listdlg('PromptString', 'Select a file:',...
                'ListString', dataset(2:dsDim1, 8), ...
                'SelectionMode','multiple');
            
            dataFiles = dataset(Selection + 1, 1);  % Raw data
            Legends = dataset(Selection + 1, 8);
            
            obj.dataFiles = dataFiles;
            obj.Legends = Legends;
            obj.root = root;
        end
    end
    
end

