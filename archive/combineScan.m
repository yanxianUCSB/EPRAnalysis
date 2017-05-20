function fileSelection = combineScan(csvfilename, ncombine, fileSelection)
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
    
    ii = ncombine;
    newspc_i = 1;
    while ii <= size(spc,2)
        newspc(:, newspc_i) = sum(spc(:, ii - ncombine + 1 : ii), 2);
        ii = ii + ncombine;
        newspc_i = newspc_i + 1;
    end
    if(~exist('newspc', 'var'))
        newspc = zeros(size(spc, 1), 1);
    end
    spc = newspc;
    
    dat = [B, spc];
    save(filename,'dat','-ascii');
    
    clearvars -except dataFiles iii ncombine fileSelection
end

end
