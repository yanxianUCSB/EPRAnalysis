function kinetics(root)

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

% Config
% framerate in second
Config = struct();
Config.framerate = 5.12 * 8 + 10 + 5;
Config.spinning = 1;
Config.select = [1 10 20 39];


spc2txt2(root);

title = input('Title = ', 's');

track3peaks(root, title, Config);

track2Integral(root, title, Config)

trackLineshape(root, title,Config)

trackLineshapeNorm(root, title, Config)

end

