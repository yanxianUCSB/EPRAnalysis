function trackLineshapeNorm(root, filenameSave, nscancombine, selection)


if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

selectedDatasetRow = selectSingle(root);
dataFile = selectedDatasetRow(:, 1);

if ~exist('filenameSave', 'var')
    
    filenameSave = selectedDatasetRow(:, 8);
    filenameSave = filenameSave{:};
    
end

filenameSave = [filenameSave ' norm'];

%% config
if ~exist('nscancombine', 'var')
nscancombine = 16;
end
nscan   = 5;
timePerFrame = 41.94*nscancombine*nscan;

if ~exist('selection', 'var')

selection = [1 6 10 15];
selection = [1 3 5 7];


end

% legends
for i = 1:length(selection)

    Legends{i} = [sprintf('%.2g', (selection(i) - 1)*timePerFrame/3600), ' hr'];

end

%% Load Data
rawData = load(dataFile{:});

% Data Cleaning
rawData = rawData(:, sum(rawData, 1) ~= 0);
field = rawData(:,1);
spectra = average2(rawData(:, 2:end-1), nscancombine);

% spectra plot
figure('Units', 'pixels', ...
    'Position', [0 0 968 1204]);
hold on;

setFigure(gca);
set(gca, 'xLim', [min(field) max(field)]);
set(gca, 'yLim', [-1.2 1.2]);

hData = spectraPlot_stack(field, spectra, selection, 1);

hLegend = setLegends(hData, Legends);

hTitle = setTitle(filenameSave, mean(field), 1.2);

hBar = setBar([min(field), min(field)+20], [0 0]);

hText = setText('20 G',  min(field)+10, 0.1);

%% Export to PNG
% I set |PaperPositionMode| to auto so that the exported figure looks like
% it does on the screen.

set(gca,'position',[0.01 0.01 0.98 0.90],'units','normalized')
fname = [root, '/fig/', filenameSave];
print(fname, '-dpng');
print(fname, '-dpdf');

% export_fig(gcf, [root, '/fig/', filenameSave, '.png']);
% export_fig(gcf, [root, '/fig/', filenameSave, '.pdf']);

% set(gcf, 'PaperOrientation','landscape');

% set(gca,'position',get(gcf, 'position'),'units','normalized')
% set(gcf, 'PaperPositionMode', 'auto');
% export_fig([root, '/fig/', filenameSave],'-dpdf');



close;
% end


clearvars -except root
end
