function Z = my_trapz(X, Y)
B = X;
spc = Y;

Z(1) = 0;
for iii = 1:length(Y)-1
    Z(iii+1) = Z(iii) + (B(iii+1)-B(iii))*(spc(iii)+spc(iii+1))/2;
end

Z = reshape(Z, length(Z), 1);
end
