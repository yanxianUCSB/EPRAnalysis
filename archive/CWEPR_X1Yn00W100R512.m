function CWEPR_X1Yn00W100R512(root)
% For 2D EPR analysis

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

scanTime = 41.94 / 2;
nscancombine = 100;
fileSelection = 0;
scanSelection = [0];

title = input('Title = ', 's');
for(i = 1:length(scanSelection))
    Legends{i} = [num2str((scanSelection(i) - 1) * scanTime * nscancombine), ' s'];
end
yLim = [-1.1 1.1];

csvfilename = spc2txt2(root);
fileSelection = combineScan(csvfilename, nscancombine, 0);
splitScan(root, scanSelection, fileSelection)

% selectScan(csvfilename, scanSelection, fileSelection);

normScan(csvfilename, 0, 1E4);


plotSpectra(root, fileSelection, [title, ' Normalized'], Legends, yLim)

fileSelection = scan2lineshape(csvfilename, fileSelection);

plotSpectra(root, fileSelection, [title, ' lineshape'], Legends, yLim)

end
