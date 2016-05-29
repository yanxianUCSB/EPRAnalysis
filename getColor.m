function s = getColor(n)
colorList = ['k'; 'b'; 'r'; 'g'; 'm'; 'y'];
s = (colorList(mod(n, 6) + 1));
end
