%% 2P ESEEM Analysis Package
% Ohio Advanced EPR Laboratory
% Rob McCarrick
% OAEPRL EPR Processings Package, Version 1.13
% Last Modified 02/21/2011

clear all;  % Clears all variables and structures

%% Read in the Bruker EPR File

[b spec params fname] = eprload(); % Uses EasySpin eprload function to read in data
fname = fname(1:end-4); % Truncates the file extension

if (isfield(params,'YPTS') == 0); % Checks to see if the data are 1D
    
[shift ns] = strread(params.FTEzDelay1,'%f %s'); % Reads in the value of tau (d1)
[pw ns] = strread(params.FTEzMWPiHalf,'%f %s'); % Reads in the value of the pulse width (p0)
b = (b' + shift + pw + pw/2); % Shifts the x axis values by tau (d1)
spec = real(spec'); % Removes the imaginary component of the y data

%% Background Subtraction and Scaling to 1

[k,c,yfit] = exponfit(b,spec,2); % Uses the EasySpin function expnfit to fit the background
scale = max(yfit); % Establishes the maximum of the exponential fit as a scaling factor
spec_scaled = spec/max(scale); % Scales the experimental data
yfit_scaled = yfit/max(scale); % Scales the exponential background
ysub = spec_scaled-yfit_scaled; % Subtracts the background function

%% Calculate Fouier Transform

[inc ns] = strread(params.FTEzDeltaX,'%f %s'); % Reads the time increment from the paramaters structure
xf = fdaxis(inc/1000,params.XPTS*2); % Uses the EasySpin fdaxis function to generate an x axis for the FT
ft = real(ctafft(ysub,params.XPTS-1,params.XPTS*2)); % Constructs the Cross Term Averaged FFT of the experimental data
ft = fftshift(ft); % Shifts the FFT using the Matlab function fftshift to obtain the correct spectrum

%% Plot the Data

subplot(3,1,1); % Establishes a subplot
plot(b,spec_scaled,b,yfit_scaled); % Plots the scaled experimental and exponential fit
xlabel('\tau(ns)','FontSize',14), ylabel('normalized intensity','FontSize',14); % Constructs the axes labels
title('Normalized Time Domain','FontSize',16); % Constructs the title
subplot(3,1,2); % Establishes a subplot
plot(b,ysub); % Plots the subtracted data
xlabel('\tau(ns)','FontSize',14), ylabel('intensity','FontSize',14); % Constructs the axes labels
title('Subtracted Time Domain','FontSize',16); % Constructs the title
subplot(3,1,3); % Establishes a subplot
plot(xf,ft); % Plots the FT
xlabel('frequency(MHz)','FontSize',14), ylabel('intensity','FontSize',14); % Constructs the axes labels
title('Fourier Transform','FontSize',16); % Constructs the title
axis([0 max(xf) 0 max(ft)*1.2]); % Limits the x axis of the plot to the positive values of the FT

%% Save an ASCII File with the Initial Data, Background, Subtraction and FT

fnametime = sprintf('%s_time.txt',fname); % Reads in the filename
fnameft = sprintf('%s_FT.txt',fname); % Appends _FT.txt to the filename
datatime = [b' spec' yfit' spec_scaled' yfit_scaled' ysub']; % Creates an array with the time data
dataft = [xf' ft']; % Creates an array with the FT data
save(fnametime,'datatime','-ascii'); % Saves an ASCII file of the time data
save(fnameft,'dataft','-ascii'); % Saves and ASCII file of the FT data

elseif (isfield(params,'YPTS') == 1); % if stucture that checks to see if the YPTS field is present (find 2D data)

[inc ns] = strread(params.FTEzDeltaX,'%f %s');
[incy ns] = strread(params.FTEzDeltaY,'%f %s');
[shift ns] = strread(params.FTEzDelay1,'%f %s'); % Reads in the value of tau (d1)
x = b{1}
x = (x' + shift); % Shifts the x axis values by tau (d1)
spec = real(spec); % Removes the imaginary component of the y data

%% Background Subtraction and Scaling to 1

for i = 1:params.YPTS; % for loop that writes an ASCII file for each slice of data
        time(:,i) = x; % Creates a mutlidimensional time array for plotting
        [k,c,yfit(:,i)] = exponfit(x,spec(:,i),2); % Uses the EasySpin function expnfit to fit the background
        scale = max(yfit(:,i)); % Establishes the maximum of the exponential fit as a scaling factor
        spec_scaled(:,i) = spec(:,i)/max(scale); % Scales the experimental data
        yfit_scaled(:,i) = yfit(:,i)/max(scale); % Scales the exponential background
        ysub(:,i) = spec_scaled(:,i)-yfit_scaled(:,i); % Subtracts the background function
        xf(:,i) = fdaxis(inc/1000,params.XPTS*2); % Uses the EasySpin fdaxis function to generate an x axis for the FT
        ft(:,i) = real(ctafft(ysub(:,i),params.XPTS-1,params.XPTS*2)); % Constructs the Cross Term Averaged FFT of the experimental data
        ft(:,i) = fftshift(ft(:,i)); % Shifts the FFT using the Matlab function fftshift to obtain the correct spectrum
        for j = 1:params.XPTS; % For loop to create a y offset for the data
        stack(j,i) = shift+ (i-1)*incy; % Creates a y dimension of tau
        end; % Cnds the for loop
end
xf(1:params.XPTS,:) = []; % gets rid of the negative FFT values
ft(1:params.XPTS,:) = []; % gets rid of the negative FFT Values

%% Plot the Data

figure; % Establishes a Figure
subplot(2,1,1); % Establishes a suplot for the time data
hold on; % Puts a hold on the figure so that new plots are added
for i = 1:params.YPTS; % Begins a for loop to write the data slices to the plot
plot3(time(:,i),stack(:,i),ysub(:,i)); % Creates the 3D plot
view([-5 35]); % Establishes the viewing angle
xlabel('\tau(ns)','FontSize',14), ylabel('field (G)','FontSize',14), zlabel('normalized intensity','FontSize',14); % Constructs the axes labels
title('Normalized Time Domain','FontSize',16); % Constructs the title
end; % Ends the for loop
hold off; % Ends the hold on the plot
subplot(2,1,2); % Establishes a suplot for the FT data
hold on; % Establishes a suplot for the time data
for i = 1:params.YPTS; % Begins a for loop to write the data slices to the plot
plot3(xf(:,i),stack(:,i),ft(:,i)); % Creates the 3D plot
view([-5 35]); % Establishes the viewing angle
xlabel('Frequency (MHz)','FontSize',14), ylabel('\tau (ns)','FontSize',14), zlabel('intensity','FontSize',14); % Constructs the axes labels
title('Fourier Transform','FontSize',16); % Constructs the title
end; % Ends the for loop
hold off; % Ends the hold on the plot
grid on; % Turns on a grid for the plot
axis tight; % Sets the axis range to tight

%% Save an ASCII File with the Initial Data, Background, Subtraction and FT

for i = 1:params.YPTS % Begins a for loop to write the data to ASCII files
    datatime = [time(:,i) spec(:,i) yfit(:,i) spec_scaled(:,i) yfit_scaled(:,i) ysub(:,i)]; % Creates an array with the time data
    tau = b{2} + shift;% Creates a data array for a text file
    fnametime = sprintf('%s_%i_time.txt',fname,tau(i)); % Creates a string with the filename and index
    save(fnametime,'datatime','-ascii'); % Saves and ASCII file of the data array
end % ends the for loop
for i = 1:params.YPTS % Begins the for loop to write the data to ASCII files
    dataft = [xf(:,i) ft(:,i)]; % Creates a data array for a text file
    tau = b{2} + shift;% Creates a data array for a text file
    fnameft = sprintf('%s_%i_ft.txt',fname,tau(i)); % Creates a string with the filename and index
    save(fnameft,'dataft','-ascii'); % Saves and ASCII file of the data array
end % ends the for loop
end
