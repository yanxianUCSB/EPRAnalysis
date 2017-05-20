function plotSpectra(root, fileSelection, Title, Legends, yLim)

if ~exist('Title', 'var')
    Title = 'Untitled';
end
if ~exist('yLim', 'var')
    yLim = [-1.1 1.1];
end

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

mkdir([root, '\', 'fig']);

csvfilename = [root, '\', 'dataset.csv'];

dataset = read_mixed_csv(csvfilename, ',');
[dsDim1, dsDim2] = size(dataset);

if(~exist('fileSelection', 'var'))
    [fileSelection,ok] = listdlg('PromptString', 'Select a file:',...
        'ListString', dataset(2:dsDim1, 8), ...
        'SelectionMode','multiple');
elseif( fileSelection == 0 )
    fileSelection = 1:dsDim1-1;
end

dataFiles = dataset(fileSelection + 1, 1);  % Raw data
% Legends = dataset(fileSelection + 1, 8);

% Create Basic Plot
figure('Units', 'pixels', ...
    'Position', [0 0 968 1204]);
hold on;

for iii = 1:length(dataFiles)
    datFile = dataFiles(iii);
    %% Load Data
    dat = load(datFile{:});
    B = dat(2:end,1);
    
    for jjj = 2:size(dat,2)
        spc = dat(2:end, jjj);

        % Create Basic Plot
        hData(jjj)   = line(B, spc);
        
        % Adjust Line Properties (Functional)
        set(hData(jjj)                         , ...
            'LineStyle'       , '-'      , ...
            'Color'           , getColor(jjj)         );
        
        % Adjust Line Properties (Esthetics)
        set(hData(jjj)                         , ...
            'Marker'          , 'none'      , ...
            'LineWidth'       , 1.5                );
    end

% Legend
if(exist('Legends', 'var'))
%     hLegend = legend( ...
%         [hData], ...
%         Legends , ...
%         'location', 'NorthEast' );
    hLegend = legend( ...
        Legends , ...
        'location', 'NorthEast' );
    set([hLegend, gca]             , ...
        'FontSize'   , 20           );
    set(hLegend, 'Interpreter', 'none');
end

% Title
hTitle  = text(mean(B), 1.2, ...
    sprintf(Title), ...
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
    'XTick',[],'XTickLabel',[], ...
    'YTick',[],'YTickLabel',[], ...
    'Visible'     , 'off'        , ...
    'Color'       , 'w', ...
    'LineWidth'   , 1         );
ylim(yLim);

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
[path, filename ]= fileparts(datFile{:});
filenameSave = [root, '\', 'fig\', filename, ' ', Title];

set(gca,'position',[0.01 0.01 0.98 0.90],'units','normalized')
print(filenameSave,'-dpng');
% set(gcf, 'PaperOrientation','landscape');

% set(gca,'position',get(gcf, 'position'),'units','normalized')
% set(gcf, 'PaperPositionMode', 'auto');
print(filenameSave,'-dpdf');


close;
% end

clearvars -except iii root dataFiles Title fileSelection Legends yLim
end
