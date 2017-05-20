%% Power Saturation Function
% Ohio Advanced EPR Laboratory
% Rob McCarrick
% OAEPRL EPR Processings Package, Version 1.13
% Last Modified 02/21/2011

function f = powerfit(x,power,sqrtpower,height) % Establishes the powerfit function
[m n] = size(sqrtpower); % gets the size of the sqrtpower array
for i = 1:n; % for loop structure to create the fit
fit(i) = x(1)*sqrtpower(i)/((1+(power(i)/x(2)))^(0.5*x(3))); % the fit function
end; % ends the for loop
f = ((sum(abs(height-fit)).^2)/n)^0.5; % root mean squared deviation between data and fit
