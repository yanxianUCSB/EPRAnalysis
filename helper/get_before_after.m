function [spc_before, spc_after] = get_before_after(SPC)
assert(size(SPC, 2) > 2000);

spc_before = mean(SPC(:, 1:1000), 2);
spc_after = mean(SPC(:, end-1000:end), 2);
% norm
spc_before = (spc_before - min(spc_before))/range(spc_before);
spc_after = (spc_after - min(spc_after))/range(spc_after);
end