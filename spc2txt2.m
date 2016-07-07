function spc2txt2(root)

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
    
if strcmp(class(B), 'double')
    continue
end
    B = B{1}';

    dat = [B, spc];
    
    for icol = 1:size(spc,2)
        vcol = spc(:, icol);
        vcol_max = max(vcol);
        col_max_p(icol) = mean([B(find1(vcol == max(vcol))) B(find1(vcol == min(vcol)))]);
        col_max(icol) = vcol_max;
        spc_norm_byCol(:, icol) = vcol./vcol_max;  
        spc_2Int(:, icol) = my_trapz(B, my_trapz(B, spc(:, icol)));
    end
    spc_max_p = mean(col_max_p);
    spc_max = max(col_max);
    spc_norm = spc./spc_max;
    dat_norm = [B - spc_max_p, spc_norm];
    dat_norm_byCol = [B - spc_max_p, spc_norm_byCol];
    dat_trapInt2 = [B - spc_max_p, spc_2Int];

    
    datfilename = [root, '\', basename, '_dat.txt'];
    datnormfilename = [root, '\', basename, '_dat_norm.txt'];
    datnormbyColfilename = [root, '\', basename, '_dat_norm_byCol.txt'];
    dat_trapInt2filename = [root, '\', basename, '_dat_trapInt2.txt'];

    lengend = basename;
    
    save(datfilename,'dat','-ascii');
    save(datnormfilename,'dat_norm','-ascii');
    save(datnormbyColfilename,'dat_norm_byCol','-ascii');
    save(dat_trapInt2filename,'dat_trapInt2','-ascii');

    
    filenameCellBody(iii, :) = {datfilename, ...
        datnormfilename, ...
        datnormbyColfilename, ...
        4, ...
        5, ...
        dat_trapInt2filename, ...
        7, ...
        lengend, ...
        9};
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
