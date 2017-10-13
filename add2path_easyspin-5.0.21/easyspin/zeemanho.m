% zeemanho  higher order Zeeman interaction Hamiltonian 
%
%   H = zeemanho(SpinSystem)
%   H = zeemanho(SpinSystem, B)
%   H = zeemanho(SpinSystem, B, Spins)
%   H = zeemanho(SpinSystem, B, Spins, 'sparse')
%
%   Returns the higher order Zeeman interaction Hamiltonian for
%   the spins 'Spins' of the spin system 'SpinSystem'.
%
%   Input:
%   - SpinSystem: Spin system structure.
%   - B: Magnetic field vector, in millitesla. If B is ommited zero field
%   is used.
%   - Spins: Vector of spin numbers. For one electron spin: 1
%     is the electron, >=2 are the nuclei. For two electron
%     spins: 1 and 2 electrons, >=3 nuclei, etc. If Spins is
%     omitted, all spins are included.
%   - 'sparse': If given, results returned in sparse format.
%
%   Output:
%   - H: the Hamiltonian of the Zeeman interaction.
%
%   Uses the Hamiltonian as given in
%   MgGavin, Tennant and Weil, Jour. Mag. Res. 87,92-109 (1990)
%
%   it is complete in the sense that it contain all usual terms (in
%   principal also the nuclear and hyperfine for a single nuclei, but this
%   is not implemented) for a single spin, but in a non-popular convention.
