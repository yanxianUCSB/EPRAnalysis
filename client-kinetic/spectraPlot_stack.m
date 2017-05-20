function hData = spectraPlot_stack(field, spectra, selection, normalized)

if ~exist('selection', 'var')
    selection = 1:size(spectra,2) ;
end
if ~exist('normalized', 'var')
    normalized = 1;
end


for kkk = 1:length(selection)
    
    if normalized == 1
        hData(kkk) = line(field, spectra(:, selection(kkk))/max(spectra(:, selection(kkk))));
    elseif normalized == 2
        hData(kkk) = line(field, spectra(:, selection(kkk))/max(max(spectra)));
    else
        hData(kkk) = line(field, spectra(:, selection(kkk)));
    end


    % Adjust Line Properties (Functional)
    set(hData(kkk)                         , ...
        'LineStyle'       , '-'      , ...
        'Color'           , getColor(kkk)         );
    
    % Adjust Line Properties (Esthetics)
    set(hData(kkk)                         , ...
        'Marker'          , 'none'      , ...
        'LineWidth'       , 1.5                );

end

