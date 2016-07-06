function pipeline2(root)
if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

% spc2txt2(root);
title = input('Title = ', 's');
track3peaks(root, title);

end
