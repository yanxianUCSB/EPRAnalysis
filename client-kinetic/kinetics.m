function kinetics(root)

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

% Config
% framerate in second
Config = struct();
Config.framerate = 10 * 60 * 60 / 6000;
Config.spinning = 32;
Config.select = [1 4 12 36 72 144];


spc2txt2(root);

title = input('Title = ', 's');

track3peaks(root, title, Config);

track2Integral(root, title, Config)

trackLineshape(root, title,Config)

trackLineshapeNorm(root, title, Config)

end

