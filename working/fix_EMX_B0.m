function [B_out, B_off] = fix_EMX_B0(spc_exp, B_sim, spc_sim)
spc_sim = asvector(spc_sim);
spc_exp = asvector(spc_exp);
%% using lsqcurvefit to find best B0 shift
fun = @(ishift)rms(cumsum(spc_sim) - cumsum(circshift(spc_exp, ishift)));
best_shift = 0;
fval = 99999;
for ishift = 1:length(spc_exp)
    f = fun(ishift);
    if f < fval
        fval = f;
        best_shift = ishift;
    end
end
B_off = best_shift * (B_sim(2)-B_sim(1));
B_out = B_sim + B_off;
end