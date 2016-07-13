function csvfilename = spc2txt2(root)
% Step 1. Ver 02

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

files = dir(strcat([root,'/*.spc']));

filenameCellBody = {};
%%
for iii = 1:size(files,1)
    
    thisfile = files(iii).name;
    [a,basename,b] = fileparts(thisfile);
    
    [B,spc] = eprload([root, '/', thisfile]);
    
% if strcmp(class(B), 'double')
%     continue
% end
if ~strcmp(class(B), 'double')
    B = B{1}';
else
    B = B';
    spc = spc';
end

    dat = [B, spc];
    
    for icol = 1:size(spc,2)
        spc_i = spc(:, icol);
        spc_imax = max(spc_i);
        spc_imin = min(spc_i);
        col_max_p(icol) = mean([B(find1(spc_i == spc_imax)) B(find1(spc_i == spc_imin))]);
        col_max(icol) = spc_imax;
        spc_norm_byCol(:, icol) = spc_i./spc_imax;  
        spc_2Int(:, icol) = my_trapz(B, my_trapz(B, spc(:, icol)));
    end
    
%     Clean Empty columns
    NonEmptyCol = find(range(spc) ~= 0);
    spc = spc(:, NonEmptyCol);
    spc_norm_byCol = spc_norm_byCol(:, NonEmptyCol);
    spc_2Int = spc_2Int(:, NonEmptyCol);
    
    spc_max_p = mean(col_max_p);
    spc_max = max(col_max);
    spc_norm = spc./spc_max;
    
    B_norm = B - spc_max_p;
    
    dat = [B_norm, spc];
    dat_norm = [B_norm, spc_norm];
    dat_norm_byCol = [B_norm, spc_norm_byCol];
    dat_trapInt2 = [B_norm, spc_2Int];

    
    datfilename = [root, '\', basename, '_dat.txt'];
    datnormfilename = [root, '\', basename, '_dat_norm.txt'];
    datnormbyColfilename = [root, '\', basename, '_dat_norm_byCol.txt'];
    dat_trapInt2filename = [root, '\', basename, '_dat_trapInt2.txt'];

    lengend = basename;
    
    save(datfilename,'dat','-ascii');
%     save(datnormfilename,'dat_norm','-ascii');
%     save(datnormbyColfilename,'dat_norm_byCol','-ascii');
%     save(dat_trapInt2filename,'dat_trapInt2','-ascii');

%     
%     filenameCellBody(iii, :) = {datfilename, ...
%         datnormfilename, ...
%         datnormbyColfilename, ...
%         4, ...
%         5, ...
%         dat_trapInt2filename, ...
%         7, ...
%         lengend, ...
%         9};
    
    filenameCellBody(iii, :) = {datfilename, ...
        2, ...
        3, ...
        4, ...
        5, ...
        6, ...
        7, ...
        lengend, ...
        9};
    
    clearvars -except iii files filenameCellBody root
end

filenameCellHead = {'_dat', ...
    '_dat_norm', ...
    '_dat_norm_byCol', ...
    '', ...
    '', ...
    '', ...
    '', ...
    'legend', ...
    ''};
filenameCell = [filenameCellHead; filenameCellBody];

ds = cell2dataset(filenameCell);
csvfilename = [root, '\', 'dataset.csv'];
export(ds,'file', csvfilename,'delimiter',',')

end
%%
