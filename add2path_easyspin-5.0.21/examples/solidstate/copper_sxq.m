% A Cu(II) complex at S, X and Q band
%==========================================================================
clear, clf, clc

% set up spin system (natural-abundance mixture of 63Cu and 65Cu)
SysCu.g = [2 2.2];
SysCu.lwpp = 1;
SysCu.Nucs = 'Cu';
SysCu.A = [50 400]; % for 63Cu (most abundant isotope), MHz

% set spectrometer frequency for S band, X band and Q band
% experiments and simulate; use automatic field ranging
Exp.mwFreq = 2;
Exp.CenterSweep = [65 80];
[Bs,specS] = pepper(SysCu,Exp);

Exp.mwFreq = 9.5;
Exp.CenterSweep = [315 80];
[Bx,specX] = pepper(SysCu,Exp);

Exp.mwFreq = 34;
Exp.CenterSweep = [1150 150];
[Bq,specQ] = pepper(SysCu,Exp);

% display
subplot(3,1,1); plot(Bs,specS); axis tight; title('S band');
subplot(3,1,2); plot(Bx,specX); axis tight; title('X band');
subplot(3,1,3); plot(Bq,specQ); axis tight; title('Q band');
xlabel('magnetic field [mT]');
