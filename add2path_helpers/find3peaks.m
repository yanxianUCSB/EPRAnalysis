function threePeaks = find3peaks(spectra)

max1 = max(spectra);
max1p = min(find(spectra == max1));

p = 0;
for iii = 1:max1p-1
    p = max1p-iii;
    if(spectra(p)*spectra(p+1) <= 0)
        break
    end
end

threePeaks(1) = min(find(spectra(1:p) == max(spectra(1:p))));
threePeaks(2) = max1p;

for iii = max1p + 1 : length(spectra)
    p = iii;
    if(spectra(p)*spectra(p-1) <= 0)
        break
    end
end
threePeaks(3) = threePeaks(2) + min(find(spectra(p:end) == max(spectra(p:end))));
