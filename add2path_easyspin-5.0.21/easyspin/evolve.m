% evolve  Time domain evolution of density matrix
%
%   td = evolve(Sig,Det,Ham,n,dt);
%   td = evolve(Sig,Det,Ham,n,dt,IncScheme);
%   td = evolve(Sig,Det,Ham,n,dt,IncScheme,Mix);
%
%   Evolves the density matrix Sig  under the
%   Hamiltonian Ham with time step dt n-1 times
%   and detects using Det after each step. Hermitian
%   input matrices are assumed. td(1) is the value
%   obtained by detecting Sig without evolution.
%
%   IncScheme determines the incrementation scheme
%   and can be one of the following (up to four
%   sweep periods, up to two dimensions)
%
%     [1]         simple FID, 3p, DEFENCE
%     [1 1]       2p, CP
%     [1 -1]      PEANUT
%     [1 2 1]     2D 3p
%     [1 2]       HYSCORE, DONUT-HYSCORE
%     [1 2 2 1]   2D CP
%     [1 2 -2 1]  2D PEANUT
%
%   [1] is the default. For an explanation of
%   the format, see the documentation.
%
%   Mix is a cell array containing the propagators
%   of the mixing sequence(s), for experiments with more than
%   1 sweep period.
%
%   td is a vector/matrix with t1 along dim
%   1 and t2 along dim 2.
