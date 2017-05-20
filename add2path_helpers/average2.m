function shortSpectra = average2(spectra, num)

i = 0;
while (i+1)*num <= size(spectra, 2)
    shortSpectra(:, i+1) = sum(spectra(:, (i*num+1):((i+1)*num)), 2);
    i = i+1;
end
