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
Sys.A = [mt2mhz([6.2 5.9 37]/10, Sys.g)];
Sys.logtcorr = -9;
%A perfect fit of spectrum needs convolutions with 12+1 protons, and 1
%13Carbon. To do that, we use phenomenological a Lorentzian line broadening.
Sys.lw = [0 0.1];  
%% fix and apply EMX B0 shift
Exp = correct_exp_field(Sys, Exp, spc);
%% Simopt and Fitopt
SimOpt.Method = 'exact'; 
FitOpt.Method = 'levmar';      % for Levenberg/Marquardt
FitOpt.Scaling = 'maxabs';    % scaling so that the maximum absolute values coincide
% FitOpt.Scaling = 'lsq';       % determine scaling via least-squares fitting
FitOpt.maxTime = 10;     % maximum time, in minutes
%% fit R
clear Vary;
Vary.logtcorr = 1;
Vary.lw = [0 0.1];
[bestsys, bestspc]=esfit('chili',spc,Sys,Vary,Exp,SimOpt,FitOpt);
clf;plot_spc_sim_exp(B, bestspc, spc);export_fig('plot.png');
% input('okay?');
end