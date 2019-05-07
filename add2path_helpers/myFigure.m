function f = myFigure(width, height)
if nargin < 1
    width = 3.42;
    height = 3.42;
end
f = figure('rend','painters',...'pos',[100 100 375 800/2],...
    'Units', 'inches', ...
    'pos', [0 0 width height]);
set(f.Children, ...
    'FontName',     'Helvetica', ...
    'FontSize',     12);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.01))

pos = get(f,'Position');
set(f,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])


end