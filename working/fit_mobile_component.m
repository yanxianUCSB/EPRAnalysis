function [bestsys] = fit_mobile_component(fileIn)
%easyfit
% clear all;
% [B,spc,Pars,fileN] = eprload('working/mtsl450uM.spc');
[B,spc,Pars,fileN] = eprload(fileIn);
Exp.mwFreq = Pars.MF;
% Pars.HCF = 1e4*Pars.MF*1e9*planck/2.0022/bmagn;
Exp.Range = [-1,1]*10 + Pars.HCF./10-5;
%% Initial MTSL g and A tensors
Sys.g = [2.0078 2.0058 2.0022];
Sys.Nucs = '14N';
Sys.A = [6.2 5.9 37]*gfree*bmagn/planck*1e-4*1e-6
Sys.logtcorr = -9;
%% fix and apply EMX B0 shift
clf;
[B_sim, spc_sim] = chili(Sys, Exp);
[B, B_off] = fix_EMX_B0(spc, B_sim, spc_sim);
subplot(211);plot(B_sim,spc_sim);hold on; plot(B, spc); hold off;title('before');
Exp.Range = Exp.Range+B_off;
[B_sim, spc_sim] = chili(Sys, Exp);
subplot(212);plot(B_sim,spc_sim);hold on; plot(B, spc); hold off;title('after');
pause('okay?');
%% Simopt and Fitopt
SimOpt.Method = 'exact';
% Calling the fitting function
% FitOpt.Method = 'simplex int'; % simplex algorithm, integrals of spectra
% FitOpt.Method = 'simplex';     % for Nelder/Mead downhill simplex
FitOpt.Method = 'levmar';      % for Levenberg/Marquardt
% FitOpt.Method = 'montecarlo';  % for Monte Carlo
% FitOpt.Method = 'genetic';     % for the genetic algorithm
% FitOpt.Method = 'grid';        % for grid search
FitOpt.Scaling = 'maxabs';    % scaling so that the maximum absolute values coincide
% FitOpt.Scaling = 'lsq';       % determine scaling via least-squares fitting
FitOpt.maxTime = 10;     % maximum time, in minutes
%% fit g
clear Vary;
Vary.logtcorr = 1;
Vary.g = [0.01, 0.01, 0.01];
[bestsys, bestspc]=esfit('garlic',spc,Sys,Vary,Exp,SimOpt,FitOpt);
clf;plot_spc_sim_exp(B, bestspc, spc);
pause('okay?');
%% accept 
Sys = bestsys;
%% fit A
clear Vary;
Vary.logtcorr = 1;
Vary.A = [10,10,10];
[bestsys, bestspc]=esfit('garlic',spc,Sys,Vary,Exp,SimOpt,FitOpt);
clf;plot_spc_sim_exp(B, bestspc, spc);
pause('okay?');
%% accept 
Sys = bestsys;
%% fit R
clear Vary;
Vary.logtcorr = 1;
[bestsys, bestspc]=esfit('garlic',spc,Sys,Vary,Exp,SimOpt,FitOpt);
clf;plot_spc_sim_exp(B, bestspc, spc);
pause('okay?');
end