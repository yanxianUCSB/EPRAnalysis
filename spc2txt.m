function spc2txt(root)

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
    
    dat = [B(:), spc(:)];
    dat_norm = [B(:)-B(find1(spc(:) == max(spc(:)))), spc(:)/max(spc(:))];
    B_mid = (B(2:end)+B(1:end-1))/2;
    B_mid2 = (B_mid(2:end)+B_mid(1:end-1))/2;
    spc_dif = diff(spc)./diff(B);
    dat_dif = [B_mid, spc_dif];
    dat_dif_norm = [B_mid(:)-B_mid(find1(spc_dif(:) == max(spc_dif(:)))),...
        spc_dif(:)/max(spc_dif(:))];
    dat_trapInt = [B(:), my_trapz(B, spc)];
    dat_trapInt2 = [B(:), my_trapz(B, my_trapz(B, spc))];
    
    datfilename = [root, '\', basename, '_dat.txt'];
    datnormfilename = [root, '\', basename, '_dat_norm.txt'];
    datdiffilename = [root, '\', basename, '_dat_dif.txt'];
    datdifnormfilename = [root, '\', basename, '_dat_dif_norm.txt'];
    dat_trapIntFilename = [root, '\', basename, 'dat_trapInt.txt'];
    dat_trapInt2Filename = [root, '\', basename, 'dat_trapInt2.txt'];
    lengend = basename;
    
    save(datfilename,'dat','-ascii');
    save(datnormfilename,'dat_norm','-ascii');
    save(datdiffilename,'dat_dif','-ascii');
    save(datdifnormfilename,'dat_dif_norm','-ascii');
    save(dat_trapIntFilename,'dat_trapInt','-ascii');
    save(dat_trapInt2Filename,'dat_trapInt2','-ascii');
    
    
    filenameCellBody(iii, :) = {datfilename, datnormfilename, ...
        datdiffilename, datdifnormfilename, ...
        dat_trapIntFilename, dat_trapInt2Filename, ...
        '0', lengend, '0'};
end

filenameCellHead = {'_dat', '_dat_norm', '_dat_dif', '_dat_dif_norm', ...
    'dat_trapInt', 'dat_trapInt2', ...
    'group', 'legend', 'color'};
filenameCell = [filenameCellHead; filenameCellBody];

ds = cell2dataset(filenameCell);
csvfilename = [root, '\', 'dataset.csv'];
export(ds,'file', csvfilename,'delimiter',',')
end
%%
