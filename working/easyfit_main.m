clear;
%get mobile component
% Sys_mobile = fit_mobile_component('mtsl450uM.spc');
% save('data/sys_mobile.mat', 'Sys_mobile');
s = load('sys_mobile.mat');Sys_mobile = s.Sys_mobile;
%
%load high dimension data
[B_struct,spc,Pars,fileN] = eprload('2d.spc');
Exp.mwFreq = Pars.MF;
Exp.Range = [-1,1]*10 + Pars.HCF./10-5;
sec_per_scan = Pars.RTC*Pars.SSX./1e3  % sec per scan
total_hour = Pars.RTC*Pars.SSX*size(spc,2)./3.6e6  % hours
%remove empty column
spc = spc(:,range(spc) ~= 0);
B = B_struct{1};
%
clf;stackedplot(spc',2,10,[-11.1,20.2,-3,3]);
xlabel('B');ylabel('time');export_fig('data/2d.png');
%averaged 
naverage = 100;
short_spc = average2(spc, naverage);
size(short_spc)
% %%
% clf;stackedplot(short_spc',2,10,[-11.1,20.2,-3,3]);
% xlabel('B');ylabel('time');export_fig('data/2d.png');
% Fit first spectrum
first_spc = asvector(short_spc(:,1));
% correct B_shift
Exp = correct_exp_field(Sys_mobile, Exp, first_spc);
%% fit two component 
clearvars SimOpt FitOpt Sys1 Sys2 Vary1 Vary2;
% SimOpt.Method = 'perturb';
SimOpt.LLKM = [14 11 6 2]; % moderately large basis size from MultiComponent
FitOpt.Method = 'levmar';      % for Levenberg/Marquardt
% FitOpt.Method = 'simplex int'; % simplex algorithm, integrals of spectra
FitOpt.Scaling = 'maxabs';    % scaling so that the maximum absolute values coincide
FitOpt.maxTime = 10;     % maximum time, in minutes
%component A: mobile
Sys1 = Sys_mobile;
Sys1.weight = 0.4;
%component B: immobile, with ordering potential c20
Sys2 = Sys_mobile;
Sys2.logtcorr = -8;
Sys2.weight = 0.6;
Sys2.lambda = [0.3];  % indicates ?2,0 = 0.3 and ?2,2 = ?4,0 = ?4,2 = 0.
Sys2.DiffFrame = [0 36 0]*pi/180;  % Euler angles, molecular frame -> Diff frame
%
Vary1.weight = 0.4;
Vary2.logtcorr = 1;
Vary2.weight = 0.6;
% Vary2.lambda = 0.3;
Sys0 = {Sys1, Sys2};
Vary = {Vary1, Vary2};
% Vary.lw = 0.1;
[bestsys, bestspc]=esfit('garlic',first_spc,Sys0,Vary,Exp,SimOpt,FitOpt);  
%VERY SLOW! TAKES HOURS!
% [bestsys, bestspc]=esfit('chili',first_spc,Sys0,Vary,Exp,SimOpt,FitOpt);
% 
clf;plot_spc_sim_exp(B, bestspc, first_spc);
%% accept fit
Sys0 = bestsys;
%% fit 2D for two components
spcs = short_spc;
bestspcs = zeros(size(spcs));
logtcorrs = zeros(size(spcs,2), 2);
weights = zeros(size(spcs,2), 2);
inpt = '\n';
for ispc = 1:size(spcs, 2)
    spc = asvector(spcs(:,ispc));
    clear Vary;
    %
    Vary1.weight = 0.4;
    Vary2.logtcorr = 1;
    Vary2.weight = 0.6;
    % Vary2.lambda = 0.3;
    Vary = {Vary1, Vary2};
    [bestsys, bestspc]=esfit('garlic',spcs(:,ispc),Sys0,Vary,Exp,SimOpt,FitOpt);
    bestspcs(:,ispc) = bestspc;
    logtcorrs(ispc,:) = [bestsys{1}.logtcorr, bestsys{2}.logtcorr];
    weights(ispc,:) = [bestsys{1}.weight, bestsys{2}.weight];
    Sys0 = bestsys;  % evolving with fitting
    clf;plot_spc_sim_exp(B, bestspc, spc);
    if strcmp(inpt, '\n');inpt = input('okay?');end
end
%%
clf;tspan = sec_per_scan*naverage*(1:length(logtcorrs))./3600;
subplot(311);plot(tspan, 10.^logtcorrs/1e-9, '.-');ylabel('t_{corr}/ns');legend({'fast','slow'},'Location','best');
subplot(312);plot(tspan, weights*100, '.-');ylabel('weight / %');legend({'fast','slow'},'Location','best');
subplot(313);plot(tspan, 100*rms((bestspcs-spcs)/range(range(spcs))), '.-');xlabel('time (h)');ylabel('RMSE / %');
export_fig('data/2d-fit.png');