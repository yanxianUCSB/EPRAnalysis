% Two coupled electrons
%==========================================================================
clear, clf

% two-electron system, both electrons with rhombic g
Sys.S = [1/2 1/2];
Sys.g = [2 2.05 2.1; 2.2 2.25 2.3];
Sys.lwpp = 1;
Sys.ee = [1 1 -2]*100; % electron-electron coupling in MHz

% X band conditions
Exp.mwFreq = 9.5;
Exp.Range = [280 350];

pepper(Sys,Exp);

title('Two coupled orthorhombic S=1/2');
