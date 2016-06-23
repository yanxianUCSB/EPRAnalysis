function pipeline(root)
if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

spc2txt(root);
title = input('Title = ', 's');
EPRCompare(root, title);

end