%% eprload
FileName = 'data/real1D.spc';
[x,y,Pars] = eprload(FileName);
cwspc1d = CWSpc(FileName);
%%
FileName = 'data/real2D.spc';
[x,y,Pars] = eprload(FileName);
cwspc2d = CWSpc(FileName);
%%
cwsarray = [cwspc1d, cwspc1d];
[f, h] = CWSpc.stackplot([cwspc1d, cwspc1d], {'1', '2'});
export_fig('test.pdf')
