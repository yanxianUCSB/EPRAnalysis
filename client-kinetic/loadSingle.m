function selectedRow = loadSingle(root)
% project  EPRAnalysis
% function load single datafile from dataset.csv
% version  1.0
% author   @yanxianUCSB
if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

mkdir([root, '\', 'fig']);
datasetFilename = [root, '\', 'dataset.csv'];

dataset = read_mixed_csv(datasetFilename, ',');

selectedRow = dataset(2, :);  % Raw data
