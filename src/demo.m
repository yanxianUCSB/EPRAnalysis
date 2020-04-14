%% setup
addpath((fullfile(pwd, '3rd', 'easyspin-5.2.25', 'easyspin')));
addpath((fullfile(pwd, '3rd', 'altmany-export_fig-eaeef72')));
%% eprload
FileName = 'data/real1D.spc';
[x,y,Pars] = eprload(FileName);
cwspc1d = CWSpc(FileName);

FileName = 'data/real2D.spc';
[x,y,Pars] = eprload(FileName);
cwspc2d = CWSpc(FileName);

%% 191223 overlapping multiple spectra
clear all;
clf;

% path where to look for .spc files; make sure .spc and .par are in the
% same path
pathin = 'data/';

% filenames without exstension
FileNames = {
    'real1D'
    'real2D'
};

% cell of legends
Legends = FileNames;

% create an array of CWSpc
cwsarray = CWSpcArray(FileNames, pathin);

% call stackplot with legends
[f, h] = cwsarray.stackplot(Legends);

% export figure
% export_fig(char(strcat(pathin, filesep, '313SL-NaCl', '.pdf')))
%%
cws = CWSpc(char(strcat(pathin, filesep, FileNames{4}, '.spc')));
cws
% CWSpc.stackplot(cws.mean())
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


