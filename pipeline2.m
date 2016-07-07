function pipeline2(root)
if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

nscancombine = 8;
selection = [1 4 8];

spc2txt2(root);

title = input('Title = ', 's');

track3peaks(root, title);

track2Integral(root, title, nscancombine, selection)

trackLineshape(root, title, nscancombine, selection)

trackLineshapeNorm(root, title, nscancombine, selection)



end
