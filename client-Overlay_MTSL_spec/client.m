function client(root)

addpath([pwd, '\helper'])

% root = 'F:\Box Sync\Bench\170420 Hep Drop';

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

dataset = dataset2cell(spc2txt(root));
% title = input('Title = ', 's');
title = 'pH10';
% title = '400DL 100SL 125Hep';
% title = 'Droplet Microscopic Condition 60h';

Analysis.root = root;
Analysis.dataset = dataset;
Analysis.norm = 1;
Analysis.bg = 0;
Analysis.Selection = [];
Figure.filenameSave = [title, ' Lineshape'];
Figure.Legends = {'pH=10', 'pH=7' };

s = EPRCompare(Analysis, Figure);

Analysis.norm = 0;
Analysis.Selection = s;
Figure.filenameSave = [title, ' Intensity'];

s = EPRCompare(Analysis, Figure);

end
