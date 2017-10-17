function client()

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

dataset = dataset2cell(explode(root, 1));
title = input('Title = ', 's');
% title = ' ';

Analysis.root = root;
Analysis.dataset = dataset;
Analysis.norm = 1;
Analysis.bg = 0;
Analysis.bjust = 1;
Analysis.Selection = [];
Figure.filenameSave = [title, ' Lineshape'];
Figure.Legends = {' ', ' ' };
Figure.title = 0;

Analysis.Selection = [608 610 + 89*6];

s = EPRCompare(Analysis, Figure);
s

Analysis.norm = 0;
Analysis.Selection = s;
Figure.filenameSave = [title, ' Intensity'];

s = EPRCompare(Analysis, Figure);

end

