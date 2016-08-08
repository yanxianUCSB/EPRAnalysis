% rescale     Rescaling of one spectrum so that it fits a second
%
%   ynew = rescale(y,mode1)
%   ynew = rescale(y,yref,mode2)
%
%   Shifts and rescales the spectrum y. If given, ynew serves
%   as the reference. The rescaled y is returned in ynew.
%
%   mode1:
%     'minmax'  shifts&scales to minimum 0 and maximum 1
%     'maxabs'  scales to maximum abs 1, no shift
%     'none'    no scaling
%
%   mode2:
%     'minmax'  shifts&scales so that minimum and maximum of y
%               fit the minimum and maximum of yref
%     'maxabs'  scales y so that maximum absolute values of y fits yref
%     'lsq'     least-squares fit of a*y to yref
%     'lsq0'    least-squares fit of a*y+b to yref
%     'lsq1'    least-squares fit of a*y+b+c*x to yref
%     'lsq2'    least-squares fit of a*y+b+c*x+d*x^2 to yref
%     'none'    no scaling
