function plot_spc_sim_exp(B, bestspc, spc)
subplot(211);plot(B, bestspc);hold on;plot(B,spc);hold off
subplot(212);plot(B,bestspc-spc);title('res');
end