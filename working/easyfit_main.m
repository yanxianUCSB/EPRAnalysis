%easyfit
[B,spc,Pars,fileN] = eprload('working/mtsl450uM.spc');
Exp.mwFreq = Pars.MF
Exp.Range = [-1,1]*10 + Pars.HCF./10

Sys.g = [2 2.1 2.2];
Sys.Nucs = '1H';
Sys.A = [120 50 78];

