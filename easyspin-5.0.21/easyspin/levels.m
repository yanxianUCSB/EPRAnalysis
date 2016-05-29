% levels  Energy levels of a spin system 
%
%   En = levels(SpinSystem,Ori,B)
%   En = levels(SpinSystem,phi,theta,B)
%   [En,Ve] = levels(...);
%
%   Calculates energy levels of a spin system.
%
%   Input:
%   - SpinSystem: spin system specification structure
%   - phi,theta: vectors of orientation angles of
%     magnetic field [radians]
%   - Ori: 2xn or nx2 array of orientations (phi,theta).
%       or 'x', 'y', 'z'.
%   - B: vector of magnetic field magnitudes [mT]
%
%   Output:
%   - En: array containing all energy eigenvalues [MHz], sorted,
%     for all possible (phi,theta,B) or (Ori,B) combinations. Depending
%     on the dimensions of Ori, phi,theta and B, out can be up
%     to 4-dimensional. The dimensions are in the order phi,
%     theta (or Ori), field, level number.
