function fig = EPRkineticsPlot(datFile)

%% Load Data
filename = datFile{:};
dat = load(filename);
B = dat(2:end,1);

% Data Cleaning
nullvec = sum(dat, 1);
dat = dat(:, nullvec ~= 0);

% 3D Exploratory plot
for jjj = 2:size(dat,2)
    spc = dat(2:end, jjj);
    hData(iii)   = line(B, repmat(jjj, 1, length(spc)), spc);
end
axis tight, grid on, view(35,40)

% Along Z
MTSLp = [3486.282
    3470.761
    3520.909];
peakTol = 0.1;
pIndex = MTSLp - peakTol <= B && B <= MTSLp + peakTol;


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

fig = hData(iii)
end
