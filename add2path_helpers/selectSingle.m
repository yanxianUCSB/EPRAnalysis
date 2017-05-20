function selectedRow = selectSingle(root)
% project  EPRAnalysis
% function select single datafile from dataset.csv
% version  1.0
% author   @yanxianUCSB
if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

mkdir([root, '\', 'fig']);
datasetFilename = [root, '\', 'dataset.csv'];

dataset = read_mixed_csv(datasetFilename, ',');

[dsDim1, ~] = size(dataset);
[Selection, ~] = listdlg('PromptString', 'Select a file:',...
    'ListString', dataset(2:dsDim1, 8), ...
    'SelectionMode','single');

selectedRow = dataset(Selection + 1, :);  % Raw data
