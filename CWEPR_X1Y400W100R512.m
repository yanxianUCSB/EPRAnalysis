function CWEPR_X1Y400W100R512(root)
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
fileSelection = combineScan(csvfilename, nscancombine);
fileSelection = selectScan(csvfilename, scanSelection, fileSelection);
fileSelection = normScan(csvfilename, fileSelection);
splitScan(root, scanSelection, fileSelection)

plotSpectra(root, fileSelection, [title, ' Normalized'], Legends, yLim)

fileSelection = scan2lineshape(csvfilename, fileSelection);

plotSpectra(root, fileSelection, [title, ' lineshape'], Legends, yLim)


% EPRCompare(root, title)

% track3peaks(root, title);
% 
% track2Integral(root, title, nscancombine, scanSelection)
% 
% trackLineshape(root, title, nscancombine, scanSelection)
% 
% trackLineshapeNorm(root, title, nscancombine, scanSelection)



end
