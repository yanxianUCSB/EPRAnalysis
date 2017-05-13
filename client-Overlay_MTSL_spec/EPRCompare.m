function Selection = EPRCompare(Analysis, Figure)
% v1.0; Plot multiple cwEPR spc-derived txt data.
% v1.1 return Selection
% root, filenameSave, norm, Selection

if isempty(Analysis.root)
    root = uigetdir('SPC file folder');
else
    root = Analysis.root;
end

if isempty(Analysis.dataset)
    datasetFilename = [root, '\', 'dataset.csv'];
    dataset = read_mixed_csv(datasetFilename, ',');
else
    dataset = Analysis.dataset;
end

if isempty(Analysis.Selection)
    [dsDim1, dsDim2] = size(dataset);
    [Selection, ok] = listdlg('PromptString', 'Select a file:',...
        'ListString', dataset(2:dsDim1, 8), ...
        'SelectionMode','multiple');
else
    Selection = Analysis.Selection;
end

if isempty(Figure.filenameSave)
    filenameSave = 'untitled';
else
    filenameSave = Figure.filenameSave;
end

if isempty(Figure.Legends)
    Legends = dataset(Selection + 1, 8);
else
    Legends = Figure.Legends;
end

mkdir([root, '\', 'fig']);
% Create Basic Plot
figure('Units', 'pixels', ...
    'Position', [0 0 968 1204]);
hold on;

norm = Analysis.norm;

% Load BG
if (Analysis.bg)
    dat = load([root, '\', 'background_dat.txt']);
    bgSPC = dat(2:end, 2);
else
    bgSPC = 0;
end

% Load Data
dataFiles = dataset(Selection + 1, 1);  % Raw data
Data = datafiles2data(dataFiles);

for iii = 1:length(dataFiles)
%     datFile = dataFiles(iii);
%     filename = datFile{:};
%     dat = load(filename);
%     B = dat(2:end,1);
%     spc = dat(2:end,2);
    B = Data.B{iii};
    spc = Data.SPC{iii} - bgSPC;
    
    if(norm == 0)
        spc = spc/Data.SPCMAX;
    else
        spc = spc/max(abs(spc));
    end
    centroid = mean([B(find1(spc == max(spc))) B(find1(spc == min(spc)))]);
    B = B - centroid;
    % Create Basic Plot
    hData(iii)   = line(B, spc);
    
    % Adjust Line Properties (Functional)
    set(hData(iii)                         , ...
        'LineStyle'       , '-'      , ...
        'Color'           , getColor(iii)         );
    
    % Adjust Line Properties (Esthetics)
    set(hData(iii)                         , ...
        'Marker'          , 'none'      , ...
        'LineWidth'       , 1.5                );
end

% Legend
hLegend = legend( ...
    [hData], ...
    Legends , ...
    'location', 'NorthEast' );
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
    'YLim'        , [-1.1, 1.1], ...
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

% set(gca,'position',get(gcf, 'position'),'units','normalized')
% set(gcf, 'PaperPositionMode', 'auto');
print([root, '/fig/', filenameSave],'-dpdf');



close;
% end



end
