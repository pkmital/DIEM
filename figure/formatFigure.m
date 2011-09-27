function h = formatFigure(num)

try
    close num;
end
h=figure(num);
clf;
set(h,'Units','centimeters');
set(h,'PaperUnits','centimeters');
size = [42.2003   17.6186];
set(h, 'Position', [1 1 size]);
set(h, 'PaperSize', size);
curPosition = get(h,'Position');
set(h,'PaperPosition',[0,0,curPosition(3:4)]);
set(h,'PaperSize',curPosition(3:4));
set(h, 'PaperPositionMode', 'auto');
set(gca, 'LooseInset', get(gca,'TightInset'));

