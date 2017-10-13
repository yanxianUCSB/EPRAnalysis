function main(root)

if ~exist('root', 'var')
    root = input('working directory : ', 's');
end

listing = dir(root);
dir root;
% Config
% framerate in second
Config = struct();
Config.framerate = 5.12 * 60 * 60 / 6000;
Config.spinning = 1;
Config.select = [1 2 3];


spc2txt2(root);

title = input('Title = ', 's');

track3peaks(root, title, Config);

track2Integral(root, title, Config)

trackLineshape(root, title,Config)

trackLineshapeNorm(root, title, Config)

end

