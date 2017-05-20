function fig = threePeaksPlot(datFile, Title, Config)
if ~exist('combine', 'var')
    combine = 1;
end

% time scale
scanTime = Config.framerate*Config.spinning;

%% Load Data
filename = datFile{:};
dat = load(filename);

% Data Cleaning
nullvec = sum(dat, 1);
dat = dat(:, nullvec ~= 0);
field = dat(:,1);
spectra = dat(:, 2:end-1);
spectra = average2(spectra, Config.spinning);

% % 3D Exploratory plot
% for jjj = 1:size(spectra,2)
%     spectrum = spectra(:, jjj);
%     hData3D(iii, jjj)   = line(field, repmat(jjj, 1, length(spectrum)), spectrum);
% end
% axis tight, grid on, view(35,40)

% track 3 peaks
fig = figure;
hold on;
threePeaks = find3peaks(sum(spectra,2));
for kkk = 1:3
    hData(kkk) = line(1:size(spectra, 2), spectra(threePeaks(kkk), :)/max(max(spectra))); 

% Adjust Line Properties (Functional)
set(hData(kkk)                         , ...
    'LineStyle'       , '-'      , ...
    'Color'           , getColor(kkk)         );

% Adjust Line Properties (Esthetics)
set(hData(kkk)                         , ...
    'Marker'          , 'none'      , ...
    'LineWidth'       , 1.5                );

end





%% Legend
for i = 1:3
    Legends{i} = [num2str(round(field(threePeaks(i)))/1000) ' GHz'];
end


hLegend = legend( ...
    [hData], ...
    Legends , ...
    'location', 'NorthEast' );
%%
set([hLegend, gca]             , ...
    'FontSize'   , 20           );
set(hLegend, 'Interpreter', 'none');

% Title
hTitle  = text(size(spectra, 2)/2, 1.2, ...
    Title, ...
    'HorizontalAlignment','center');


% Since many publications accept EPS formats, I select fonts that are supported by PostScript and Ghostscript. Anything that's not supported will be replaced by Courier. I also define tick locations, especially when the default is too crowded.
set( gca                       , ...
    'FontName'   , 'Helvetica' );
set(gca, ...
    'Box'         , 'off'     , ...
    'XTick',[],'XTickLabel',[], ...
    'YTick',[],'YTickLabel',[], ...
    'Visible'     , 'off'        , ...
    'Color'       , 'w', ...
    'LineWidth'   , 1         );

% Scale Bar
hBar    = line([0, 1200/scanTime], [0 0]);
set(hBar                         , ...
    'LineStyle'       , '-'      , ...
    'Color'           , 'k'       );
set(hBar                         , ...
    'Marker'          , 'none'   , ...
    'LineWidth'       , 2         );
hText   = text(1200/scanTime*1.2, 0, ...
    sprintf('20 min'), ...
    'HorizontalAlignment','left');
set([hText], ...
    'FontName'   , 'Helvetica');
set([hText]  , ...
    'FontSize'   , 20          );
end

