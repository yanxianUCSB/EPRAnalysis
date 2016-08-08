function pipeline(root)
root = 'F:\Documents\Bench\Antibody 160729';
if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

ds = spc2txt(root);
% title = input('Title = ', 's');
title = 'Hep4 65h';
EPRCompareBgCor(root, [title, ' Lineshape']);

EPRCompareBgCor(root, [title, ' Signal'], 0);

end
