function EPR2IntCompare(root, filenameSave)

filenameSave = 'double Intergral';


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

% dataFiles = dataset(Selection + 1, 1);  % Raw data
dataFiles = dataset(Selection + 1, 6);  % Double Integral
Legends = dataset(Selection + 1, 8);

% Create Basic Plot
figure('Units', 'pixels', ...
    'Position', [0 0 968 1204]);
hold on;

maxSpc = 0;
for iii = 1:length(dataFiles)
    datFile = dataFiles(iii);
    %% Load Data
    filename = datFile{:};
    dat = load(filename);
    B = dat(2:end,1);
    spc = dat(2:end,2);
    % Normalization
    spcBox(:,iii) = spc;
    maxSpc = max([maxSpc; spc]);
    % Center Allignment
%     centroid = mean([B(find(spc == max(spc))) B(find(spc == min(spc)))]);
    BBox(:,iii) = B;
   
end
clear iii;
for iii = 1:length(dataFiles)
    spc = spcBox(:,iii) / maxSpc;
    B = BBox(:,iii);
     % Create Basic Plot
    hData(iii)   = line(B, spc);
    
    hLabel(iii)  = text(max(max(BBox)), max(spc) + 0.02, ...
    sprintf('%.1f%%', round(1000*max(spc))/10), ...
    'HorizontalAlignment','right');

    % Adjust Line Properties (Functional)
    set(hData(iii)                         , ...
        'LineStyle'       , '-'      , ...
        'Color'           , getColor(iii)         );
    
    % Adjust Line Properties (Esthetics)
    set(hData(iii)                         , ...
        'Marker'          , 'none'      , ...
        'LineWidth'       , 1.5                );
    
    set(hLabel(iii)                         , ...
        'FontSize'   , 20       , ...
        'FontName'   , 'Helvetica'                );
end

% Legend
hLegend = legend( ...
    [hData], ...
    Legends , ...
    'location', 'West' );
set([hLegend, gca]             , ...
    'FontSize'   , 20           );
set(hLegend, 'Interpreter', 'none');

% Title
hTitle  = text(mean(B), 1.2, ...
    sprintf(filenameSave), ...
    'HorizontalAlignment','center');
% Adjust Font and Axes Properties
% Since many publications accept EPS formats, I select fonts that are supported by PostScript and Ghostscript. Anything that's not supported will be replaced by Courier. I also define tick locations, especially when the default is too crowded.
set( gca                       , ...
    'FontName'   , 'Helvetica' );
set([hTitle], ...
    'FontName'   , 'Helvetica');
set( hTitle                    , ...
    'FontSize'   , 28          , ...
    'FontWeight' , 'bold'      );
set(gca, ...
    'Box'         , 'off'     , ...
    'XLim'        , [min(B), max(B)], ...
    'YLim'        , [-0.1 1.15], ...
    'XTick',[],'XTickLabel',[], ...
    'YTick',[],'YTickLabel',[], ...
    'Visible'     , 'off'        , ...
    'Color'       , 'w', ...
    'LineWidth'   , 1         );

% Scale Bar
hBar    = line([min(B), min(B)+20], [0.15 0.15]);
set(hBar                         , ...
    'LineStyle'       , '-'      , ...
    'Color'           , 'k'         );
set(hBar                         , ...
    'Marker'          , 'none'      , ...
    'LineWidth'       , 2                );
hText   = text(min(B)+10, 0.22, ...
    sprintf('20 G'), ...
    'HorizontalAlignment','center');
set([hText], ...
    'FontName'   , 'Helvetica');
set([hText]  , ...
    'FontSize'   , 20          );

%% Export to PNG
% I set |PaperPositionMode| to auto so that the exported figure looks like
% it does on the screen.

set(gca,'position',[0.01 0.01 0.98 0.90],'units','normalized')
print([root, '/fig/', filenameSave],'-dpng');
% set(gcf, 'PaperOrientation','landscape');

% set(gca,'position',[0 0 1 1],'units','normalized')
% set(gcf, 'PaperPositionMode', 'auto');
print([root, '/fig/', filenameSave],'-dpdf');



close;
% end


clearvars -except root
% end
