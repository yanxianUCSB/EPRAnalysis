function plot_spc_sim_exp(B, bestspc, spc, title_)
if nargin < 4
    title_ = '';
end
subplot = @(m,n,p) subtightplot (m, n, p, [0.05 0.02], [0.1 0.05], [0.1 0.04]);
subplot(2,1,1);plot(B, bestspc);hold on;plot(B,spc);hold off;xticklabels([]);ylabel('Amp (a.u.)');legend({'fit', 'data'});title(title_);
subplot(2,1,2);plot(B,(bestspc-spc)./range(spc)*100);xlabel('B (G)');ylabel('Residual %');
end