function client(root)

addpath([pwd, '\helper'])

% root = 'F:\Box Sync\Bench\170310 TEMP';

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

dataset = dataset2cell(spc2txt(root));
% title = input('Title = ', 's');
% title = 'Solution Overnight';
title = 'Undiluted';
% title = 'Droplet Microscopic Condition 60h';

Analysis.root = root;
Analysis.dataset = dataset;
Analysis.norm = 1;
Analysis.bg = 1;
Analysis.Selection = [];
Figure.filenameSave = [title, ' Lineshape'];
Figure.Legends = {'Undiluted Tau', 'Undiluted Tau+PolyU', 'Undiluted Tau+PolyU+NaCl'};

s = EPRCompare(Analysis, Figure);

Analysis.norm = 0;
Analysis.Selection = s;
Figure.filenameSave = [title, ' Intensity'];

s = EPRCompare(Analysis, Figure);

end
