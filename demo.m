%% eprload
FileName = 'data/real1D.spc';
[x,y,Pars] = eprload(FileName);
cwspc1d = CWSpc(FileName);
%%
FileName = 'data/real2D.spc';
[x,y,Pars] = eprload(FileName);
cwspc2d = CWSpc(FileName);
%% 191223 overlapping multiple spectra
clear all;
pathin = "/Users/yanxlin/Box/data/CWEPR/191223-LLPS-salt-SL";
FileNames = {
    '313SL-NaCl-0'
    '313SL-NaCl-1p5'
    '313SL-NaCl-3p0'
    '313SL-NaCl-4p5'
};
Legends = FileNames;
cwsarray = CWSpc().empty();
for ii = 1:numel(FileNames)
    cwsarray(ii) = CWSpc(char(strcat(pathin, filesep, FileNames{ii}, '.spc')));
    if cwsarray(ii).is1d
        cwsarray(ii) = cwsarray(ii).mean();
    else
        cwsarray(ii) = cwsarray(ii).rmzeros().rmbadscans().mean();
    end
end
[f, h] = CWSpc.stackplot(cwsarray, Legends);
% export_fig(char(strcat(pathin, filesep, '313SL-NaCl', '.pdf')))
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
pathin = '/Users/yanxlin/Box/data/CWEPR/191219 high salt 313 404';
SL10_404_on = '404 10SL t=0p5-16 h.spc';
filein = SL10_404_on;
filein = strcat(pathin, filesep, filein);
cws = CWSpc(filein);
imshowpair(cws.rmzeros().spc, cws.rmzeros().rmbadscans().spc,'montage');
%% subtract background
clear; close;
pathin = fullfile(getuserdir(),'../Box/data/CWEPR/191223-LLPS-salt-SL');
% filein = '313SL-NaCl-4p5.spc';
filein = strcat(pathin, filesep, '313SL-NaCl-4p5.spc');
filebg = strcat(pathin, filesep, 'water repeat 2.spc');
cws = CWSpc(filein).rmzeros().rmbadscans();
cwsbg = CWSpc(filebg).rmzeros().rmbadscans();
cws1 = cws.subtractbg(cwsbg);

CWSpc.stackplot([cws.mean(), cwsbg.mean(), cws1.mean()], ...
    {'raw', 'bg', 'cor'})

export_fig(char(strcat(pathin, filesep, '313SL-NaCl-4p5-bgcor', '.pdf')))

eprsave(strcat(pathin, filesep, '313SL-NaCl-4p5-bgcor'), cws1.mean().B, cws1.mean().spc)
%%
doc eprsave


