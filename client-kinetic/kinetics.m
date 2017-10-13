function kinetics(root)

if ~exist('root', 'var')
    root = uigetdir('SPC file folder');
end

% Config
% framerate in second
Config = struct();
Config.framerate = 5.12 * 8 ;
Config.spinning = 10;
Config.select = [1 20 40 59];


spc2txt2(root);

title = input('Title = ', 's');

track3peaks(root, title, Config);

track2Integral(root, title, Config)

trackLineshape(root, title,Config)

trackLineshapeNorm(root, title, Config)

end

