function s = getColor(n)
colorList = ['c'; 'k'; 'b'; 'r'; 'g'; 'm'];
s = (colorList(mod(n, 6) + 1));
end
