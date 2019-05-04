function Exp = correct_exp_field(Sys, Exp, spc)
%% fix and apply EMX B0 shift
clf;
[B_sim, spc_sim] = garlic(Sys, Exp);
%scale spc_sim and spc to same scale
spc = spc./max(spc).*max(spc_sim);
[B, B_off] = fix_EMX_B0(spc, B_sim, spc_sim);
subplot(211);plot(B_sim,spc_sim);hold on; plot(B, spc); hold off;title('before');
Exp.Range = Exp.Range+B_off;
[B_sim, spc_sim] = garlic(Sys, Exp);
subplot(212);plot(B_sim,spc_sim);hold on; plot(B, spc); hold off;title('after');
% input('okay?');
end