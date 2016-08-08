% nucspinrmv   Remove nuclear spin from spin system
%
%   NewSys = nucspinrmv(Sys,idx)
%
%   Removes one or more nuclei from the spin system
%   Sys and returns the result in NewSys. idx a vector
%   of nuclear numbers as they appear in Sys. E.g. idx=1
%   removes the first nucleus, idx=[2 4] removes the
%   second and the fourth.
%
%   Example:
%    Sys = struct('S',1/2,'g',[2 2 3],'Nucs','14N','A',[4 6 10]);
%    Sys = nucspinrmv(Sys,1);
