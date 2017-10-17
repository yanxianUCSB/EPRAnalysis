function dataset = explode(root, stacknum)
% Step 1. Ver 01
if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

if ~exist('stacknum', 'var')
	stacknum = 1;
end

files = dir(strcat([root,'/*.spc']));

filenameCellBody = {};
filenamecellbodyi = 1;

for iii = 1:size(files,1)
    
    thisfile = files(iii).name;
    [a,basename,b] = fileparts(thisfile);
    
    [B, spc, par] = eprload([root, '/', thisfile]);

    if ~strcmp(class(B), 'double')  % test if B is DOUBLE or CELL
        B = B{1}';
    else
        B = B';
        spc = spc';
    end

    dat = [B, spc];
        
    for icol = 1:size(spc,2)
        spc_i = spc(:, icol);
%     Clean Empty columns
		if (range(spc_i) ~= 0) && (mod(icol - 1, stacknum) == 0)
			dat_i = [B, spc_i];
			par_i = par;
			par_i.REY = 1;
            par_i.JRE = '';  % remove JRE for struct2csv
            filename_dat = [root, '\', basename, '_', num2str(icol), '_dat.txt'];
            filename_par = [root, '\', basename, '_', num2str(icol), '_par.csv'];
            save(filename_dat, 'dat_i', '-ascii');
            struct2csv(par_i, filename_par);
            filenameCellBody(filenamecellbodyi, :) = {[root, '\', basename, b], filename_dat, filename_par};
            filenamecellbodyi = filenamecellbodyi + 1;
		end
    end
end
filenameCellHead = {'dat', 'col', 'par'};
filenameCell = [filenameCellHead; filenameCellBody];
ds = cell2dataset(filenameCell);
csvfilename = [root, '\', 'dataset.csv'];
export(ds,'file', csvfilename,'delimiter',',')

dataset = ds;
end

