function EPRkinetics(root, filenameSave)

if ~exist('filenameSave', 'var')
    filenameSave = 'untitled';
end

root = 'F:\Yanxian\Documents\Bench\160628_droplet heparin - Copy';

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

mkdir([root, '\', 'fig']);
datasetFilename = [root, '\', 'dataset.csv'];

dataset = read_mixed_csv(datasetFilename, ',');
[dsDim1, dsDim2] = size(dataset);
[Selection,ok] = listdlg('PromptString', 'Select a file:',...
    'ListString', dataset(2:dsDim1, 8), ...
    'SelectionMode','multiple');

dataFiles = dataset(Selection + 1, 1);  % Raw data
Legends = dataset(Selection + 1, 8);

% Create Basic Plot
% figure('Units', 'pixels', ...
%     'Position', [0 0 968 1204]);
% hold on;

for iii = 1:length(dataFiles)
    datFile = dataFiles(iii);
    
    
    fig = threePeaksPlot(datFile);

   
end




%% Export to PNG
% I set |PaperPositionMode| to auto so that the exported figure looks like
% it does on the screen.

set(fig,'position',[0.01 0.01 0.98 0.90],'units','normalized')
print([root, '/fig/', filenameSave],'-dpng');
% set(gcf, 'PaperOrientation','landscape');

% set(gca,'position',get(gcf, 'position'),'units','normalized')
% set(gcf, 'PaperPositionMode', 'auto');
print([root, '/fig/', filenameSave],'-dpdf');



close;
% end


clearvars -except root
end
