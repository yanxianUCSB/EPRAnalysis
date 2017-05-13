% curry  Computation of magnetometry data
%         (magnetic moment, susceptibility)
%
%   curry(Sys,Exp)
%   curry(Sys,Exp,Opt)
%   muz = curry(...)
%   [muz,chizz] = curry(...)
%
%    Calculates the magnetic moment and the molar static magnetic
%    susceptibility of a powder sample for given values of
%    applied magnetic field and temperature.
%
%    Input:
%      Sys    spin system
%      Exp    experimental parameter
%        Field        list of field values (mT)
%        Temperature  list of temperatures (K)
%      Opt    calculation options
%        nKnots       number of knots for powder average
%
%    Output:
%      muz      magnetic moment along zL axis
%               in units of Bohr magnetons
%      chizz    molar susceptibility, zLzL component
%               in SI units (m^3 mol^-1)
%    
%    zL is the direction of the applied static magnetic field
%
%    The size of muz and chizz is nB x nT, where nB is the number of
%    field values in Exp.Field and nT is the number of temperature values
%    in Exp.Temperature.
%
%   If no output argument is given, the computed data are plotted.
