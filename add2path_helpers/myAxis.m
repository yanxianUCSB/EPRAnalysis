function a = myAxis(ver)
% set(gca,'LooseInset', max(get(gca,'TightInset'), 0.01))
% set(gca, 'Units', 'centimeters')
% set(gca,'TickLength',[0.05, 0.05])
if strcmp(ver, 'empty')
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
% set(gca,'TightInset', max(get(gca,'TightInset'), 0.01))
end
if strcmp(ver, 'nolabel')
    set(gca,'xticklabel',[])
    set(gca,'yticklabel',[])
end
% default
set(gca,...
    'TickLength',[0.04, 0.04],...
    'FontSize', 8)
axis square
end