%% eprload
FileName = 'data/real1D.spc';
[x,y,Pars] = eprload(FileName);
cwspc1d = CWSpc(FileName);
%%
FileName = 'data/real2D.spc';
[x,y,Pars] = eprload(FileName);
cwspc2d = CWSpc(FileName);
%%
clear all;
pathin = "/Users/yanxlin/Box/data/CWEPR/191223-LLPS-salt-SL";
FileNames = {
    '313SL-NaCl-0',
    '313SL-NaCl-1p5',
    '313SL-NaCl-3p0',
    '313SL-NaCl-4p5'
};
Legends = FileNames;
cwsarray = CWSpc().empty();
for ii = 1:numel(FileNames)
    cwsarray(ii) = CWSpc(char(strcat(pathin, filesep, FileNames{ii}, '.spc')));
    cwsarray(ii) = cwsarray(ii).mean();
end
[f, h] = CWSpc.stackplot(cwsarray, Legends);
export_fig(char(strcat(pathin, filesep, '313SL-NaCl', '.pdf')))
%%
cws = CWSpc(char(strcat(pathin, filesep, FileNames{4}, '.spc')));
cws
CWSpc.stackplot(cws.mean())
cws.image()
%% rmzeros
cws = cws.rmzeros()
cws.image()
%% rmbadscans
clear; close;
path_in = '/Users/yanxlin/Box/data/CWEPR/191219 high salt 313 404';
SL10_404_on = '404 10SL t=0p5-16 h.spc';
file_in = SL10_404_on;
file_in = strcat(path_in, filesep, file_in);
cws = CWSpc(file_in);
imshowpair(cws.rmzeros().spc, cws.rmzeros().rmbadscans().spc,'montage');