%% T2 Fitting Package
% Ohio Advanced EPR Laboratory
% Rob McCarrick
% OAEPRL EPR Processings Package, Version 1.13
% Last Modified 02/21/2011

clear all;  % Clears all variables and structures

%% Read in the Bruker EPR File

[b spec params fname] = eprload(); % Uses EasySpin eprload function to read in data
fname = fname(1:end-4); % Truncates the file extension
[shift ns] = strread(params.FTEzDelay1,'%f %s'); % Reads in the value of tau (d1)
b = (b' + shift)/1000; % Shifts the x axis values by tau (d1)
spec = real(spec'/max(spec)); % Removes the imaginary component of the y data

%% Minimize the Exponential Fit

options = optimset('MaxFunEvals',10000); % Sets the Maximum number of function evaluations
[x,fval] = fminsearch(@t2decay,[max(spec)/2,max(b)/4],options,b,spec,params); % Uses the Matlab builtin fminsearch to minimize the t2fit function

%% Plot the Data

plot(b,spec,b,x(1)*exp(-b/x(2))); % Plots the experimental data and the optained fit
axis tight; % Shrinks the axis to fit the data tightly
title('T_2 Determination','FontSize',20); % Constructs the title
xlabel('time(\mus)','FontSize',18), ylabel('intensity','FontSize',18); % Constructs the axes labels
label = [sprintf('T_2 = %0.2f ',x(2)) '\mus']; % Assigns a string to the obtained value for T2 on the plot
text(x(2)+max(b)/30,max(spec)*0.8,label,'FontSize',18); % Prints the T2 string on the plot
line([x(2);x(2)],[0;max(spec)],'Color','r','LineWidth',2); % Draws a line at the T1 value

%% Save and ASCII File of the Results

fit = x(1)*exp(-b/x(2)); % Consrtucts an array from the best fit to the data
data = [b' spec' fit']; % Cosntructs an array with the x, y and fit data
fnamet2 = sprintf('%s.txt',fname); % Constructs a filename string from the params structure
save(fnamet2,'data','-ascii'); % Saves the data array to an ASCII file
