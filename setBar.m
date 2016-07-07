function hBar = setBar(Line, Pos) 

hBar    = line(Line, Pos);
set(hBar                         , ...
    'LineStyle'       , '-'      , ...
    'Color'           , 'k'       );
set(hBar                         , ...
    'Marker'          , 'none'   , ...
    'LineWidth'       , 2         );
