function [b, spc, Par] = epr2D_load_and_fix(path_in, file_in)
%' load and fix jumping cwEPR data collected by Han Lab EMX
% baseline regions
BS_REGION = [1:200 825:1024];

%% Load
file_in = strcat(path_in, filesep, file_in);

[B, SPC, Par] = eprload(file_in);

%% remove bad slices
% define a good slice
igood = 1;
std_good = sqrt(sum(abs(SPC(BS_REGION, igood).^2)));
% identify 'jumping slices' or slices with exceptional high baseline noise
stds = sqrt(sum(SPC(BS_REGION,:).^2, 1));
ibad = stds > 1.5 * std_good;

SPC = SPC(:, ~ibad);

disp(['I removed ', num2str(sum(ibad)), ' bad slices ']);

plot(stds, '.');

%% remove empty scans and the last scan
SPC = SPC(:, sum(abs(SPC))~=0);
SPC = SPC(:, 1:end-1);

%%
b = B{1}';
spc = SPC;
end