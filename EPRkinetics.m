function EPRkinetics(root, filenameSave)

if ~exist('filenameSave', 'var')
    filenameSave = 'Before and After Droplet Diluted';
end

root = 'F:\Yanxian\Documents\Bench\160628_tau_antibody - Copy'

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
figure('Units', 'pixels', ...
    'Position', [0 0 968 1204]);
hold on;

for iii = 1:length(dataFiles)
    datFile = dataFiles(iii);
    
%     hData(iii) = EPRkineticsPlot(datFile);

%% Load Data
filename = datFile{:};
dat = load(filename);
B = dat(1:end,1);

% Data Cleaning
nullvec = sum(dat, 1);
dat = dat(:, nullvec ~= 0);

% 3D Exploratory plot
for jjj = 2:size(dat,2)
    spc = dat(:, jjj);
    hData3D(iii)   = line(B, repmat(jjj, 1, length(spc)), spc);
end
axis tight, grid on, view(35,40)

% Along Z
MTSLp = [3486.282
    3470.761
    3520.909];
peakTol = 0.1;
for kkk = 1:length(MTSLp)
    pIndex = (MTSLp(kkk) - peakTol <= B) & (B <= MTSLp(kkk) + peakTol);
    peak(kkk,:) = mean(dat(pIndex, :), 1);
    hData(iii) = 
end

dat(pIndex(kkk, :)
for jjj = 2:size(dat,2)

    spc = dat(2:end, jjj);
    
    
    hData(iii)   = line(B, repmat(jjj, 1, length(spc)), spc);
end

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


clearvars -except root
end
