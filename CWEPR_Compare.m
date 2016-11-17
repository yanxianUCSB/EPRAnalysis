function CWEPR_Compare(root)
% compare cwepr plot
addpath([pwd, '\helper'])

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

spc2txt(root);

title = input('Title = ', 's');

Selection = EPRCompare(root, [title, ' Lineshape']);
Selection = EPRCompare(root, [title, ' Signal'], 0, Selection);

end
