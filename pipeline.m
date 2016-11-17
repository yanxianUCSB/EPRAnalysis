function pipeline(root)

addpath([pwd, '\helper'])

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

spc2txt(root);
% title = input('Title = ', 's');
% title = 'Solution Overnight';
title = '95%Alg 30min';
% title = 'Droplet Microscopic Condition 60h';
out = EPRCompareBgCor(root, [title, ' Lineshape']);

EPRCompareBgCor(root, [title, ' Signal'], 0, out.Selection);

end
