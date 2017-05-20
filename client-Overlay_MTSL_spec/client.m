function client(root)

addpath([pwd, '\helper'])

% root = 'F:\Box Sync\Bench\170420 Hep Drop';

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

dataset = dataset2cell(spc2txt(root));
% title = input('Title = ', 's');
title = '4- CL400 SL100 Hep170 dense';
% title = '400DL 100SL 125Hep';
% title = 'Droplet Microscopic Condition 60h';

Analysis.root = root;
Analysis.dataset = dataset;
Analysis.norm = 1;
Analysis.bg = 1;
Analysis.Selection = [];
Figure.filenameSave = [title, ' Lineshape'];
Figure.Legends = {'Solution', '15 min', '18h' };

s = EPRCompare(Analysis, Figure);

% Analysis.norm = 0;
% Analysis.Selection = s;
% Figure.filenameSave = [title, ' Intensity'];
% 
% s = EPRCompare(Analysis, Figure);

end
