function Data = datafiles2data(dataFiles)
% Datafiles to B and SPC data

len = length(dataFiles);
B = cell([1, len]);
SPC = cell([1, len]);
SPCMAX = [];

for iii = 1:length(dataFiles)
    datFile = dataFiles(iii);
    %% Load Data
    filename = datFile{:};
    dat = load(filename);
    B{iii} = dat(2:end,1);
    SPC{iii} = dat(2:end,2);
    SPCMAX(iii) = max( abs( SPC{iii} ) );
end
Data.B = B;
Data.SPC = SPC;
Data.SPCMAX = max(SPCMAX);
    
