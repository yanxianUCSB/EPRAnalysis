function client(root)

addpath([pwd, '\helper'])

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

spc2txt(root);
% title = input('Title = ', 's');
% title = 'Solution Overnight';
title = 'Tau187SL322_100SL';
% title = 'Droplet Microscopic Condition 60h';
Selection = EPRCompare(root, [title, ' Lineshape']);

EPRCompare(root, [title, ' Signal'], 0, Selection);

end
