% Basic example of spectral fitting using EasySpin
%====================================================================
clear

%
% use Experiment data
[B, spc, Pars, FileN] = eprload('working\test_MTSL450uM.spc');
% correct field reading error
% centroid = mean([B(find1(spc == max(spc))) B(find1(spc == min(spc)))]);
% Boffset = centroid - median(B);
% trueMWFreq = Pars.HCF * gfree * bmagn / (planck*1e9);
% trueMWFreq = 1.760859644e11 * Pars.HCF*1e-4/(planck*1e9);
Exp.mwFreq = 9.755560   % from MultiComponent
Exp.Range = 3475.85/10 + [-1 1]*Pars.HSW/20  % From MultiComponent
Exp.nPoints = Pars.ANZ
% Exp.ModAmp = Pars.RMA/10
%
% Since we don't have any experimental data available, let's create some mock
% data by simulating a spectrum and adding some noise. If you use this example
% as a basis for your fittings, replace this code by code that loads your
% experimental data.
% 
% Sys.g = [2 2.1 2.2];
% Sys.Nucs = '1H';
% Sys.A = [120 50 78];
% Sys.lwpp = 1;
% Exp.mwFreq = 10;
% Exp.Range = [300 380];
% [B,spc] = pepper(Sys,Exp);
% spc = addnoise(spc,150,'n');

% Now we set up the least-squares fitting. First comes a starting set of
% parameters (which we obtain by copying the spin system from the simulation
% and changing a few values).
Sys0.g = [2.0078, 2.0058, 2.0022];  % check Zach's manuscript for reference
Sys0.Nucs = '14N';
Sys0.A = [6.2, 5.9, 37.0];
% Sys0.lwpp = 0.2;
Sys0.logtcorr = -8.723535; % corresponds to 1ns seconds

[B1, spc1] = chili(Sys0, Exp);
plot(B1, spc); hold on; plot(B1, spc1, '-r'); hold off
%%
% Next, we specify which parameter we want to be fitted and by how much the
% fitting algorithm can vary it approximately.
% Vary.g = [0.1 0.1 0.1];
% Vary.A = [30 30 30];
Vary.logtcorr = 1;

% We also can provide options for the simulation function.
SimOpt.Method = 'perturb';

% Finally, we specify the fitting algorithm and what should be fitted.
FitOpt.Method = 'simplex int'; % simplex algorithm, integrals of spectra
% FitOpt.Method = 'levmar';      % for Levenberg/Marquardt

FitOpt.Scaling = 'maxabs';

[bestsys,bestspc]=esfit('chili',spc,Sys0,Vary,Exp,SimOpt,FitOpt);

% If the fitting algorithm doesn't find the correct minimum, you can change
% the algorithm, target function, and starting point in the UI. For example,
% run Monte Carlo for a bit, save the best fit, and then use that as the
% starting point with Nelder/Mead to close in on the correct fit.
%%
plot(B1, spc); hold on; plot(B1, bestspc, '-r'); hold off
