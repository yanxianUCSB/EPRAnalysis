%% get mobile component
Sys_mobile = fit_mobile_component('');
%% load high dimension data
[B,spc,Pars,fileN] = eprload('working/2d.spc');
%remove empty column
spc = spc(:,find(range(spc) ~= 0));