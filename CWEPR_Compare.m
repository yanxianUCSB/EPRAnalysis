function CWEPR_Compare(root)
% 

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

title = input('Title = ', 's');

EPRCompare(root, title)

end
