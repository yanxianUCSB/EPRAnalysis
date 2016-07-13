function splitScan(root, scanSelection, fileSelection)
% Step 2. Ver 02

csvfilename = [root, '\', 'dataset.csv'];

dataset = read_mixed_csv(csvfilename, ',');
[dsDim1, dsDim2] = size(dataset);

if(~exist('fileSelection', 'var'))
    [fileSelection,ok] = listdlg('PromptString', 'Select a file:',...
        'ListString', dataset(2:dsDim1, 8), ...
        'SelectionMode','multiple');
elseif( fileSelection == 0 )
    fileSelection = 1:dsDim1-1;
end


dataFiles = dataset(fileSelection + 1, 1);  % Raw data

for iii = 1:length(dataFiles)
    datFile = dataFiles(iii);
    %% Load Data

    dat = load(datFile{:});
    
    B = dat(1:end, 1);
    spc = dat(1:end, 2:end);
    
    if(scanSelection == 0)
        scanSelection = 1:size(spc, 2);
    end

    [path, filename ]= fileparts(datFile{:});
    for j = scanSelection
        newspc = spc(:, j);    
        dat = [B, newspc];
        save([path, '\', filename, ' Scan ', num2str(j), '.txt' ],'dat','-ascii');
        
        filenameCellBody(j, :) = {[path, filename, ' Scan ', num2str(j), '.txt' ], ...
        '2', ...
        '3', ...
        '4', ...
        '5', ...
        '6', ...
        '7', ...
        [filename, ' Scan ', num2str(j)], ...
        '9'};
    
    end
    
    dataset = [dataset; filenameCellBody];
end

ds = cell2dataset(dataset);
csvfilename = [root, '\', 'dataset.csv'];
export(ds,'file', csvfilename,'delimiter',',')

end
