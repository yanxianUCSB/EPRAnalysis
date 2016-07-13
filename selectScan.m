function fileSelection = selectScan(csvfilename, scanSelection, fileSelection)
% Step 2. Ver 02

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
    filename = datFile{:};
    dat = load(filename);
    
    B = dat(1:end, 1);
    spc = dat(1:end, 2:end);
    
    if(scanSelection == 0)
        scanSelection = 1:size(spc, 2);
    end

    
    newspc = spc(:, scanSelection);
    spc = newspc;
    
    dat = [B, spc];
    save(filename,'dat','-ascii');
    
end

end
