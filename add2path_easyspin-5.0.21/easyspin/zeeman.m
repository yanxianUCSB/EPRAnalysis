% zeeman  Zeeman interaction Hamiltonian 
%
%   H = zeeman(SpinSystem, B)
%   H = zeeman(SpinSystem, B, Spins)
%   H = zeeman(SpinSystem, B, Spins, 'sparse')
%   [Zx, Zy, Zz] = zeeman(SpinSystem)
%   [Zx, Zy, Zz] = zeeman(SpinSystem, Spins)
%   [Zx, Zy, Zz] = zeeman(SpinSystem, Spins, 'sparse')
%
%   Returns the Zeeman interaction Hamiltonian for
%   the spins 'Spins' of the spin system 'SpinSystem'.
%
%   Input:
%   - SpinSystem: Spin system structure.
%   - B: Magnetic field vector, in millitesla.
%   - Spins: Vector of spin numbers. For one electron spin: 1
%     is the electron, >=2 are the nuclei. For two electron
%     spins: 1 and 2 electrons, >=3 nuclei, etc. If Spins is
%     omitted, all spins are included.
%   - 'sparse': If given, results returned in sparse format.
%
%   Output:
%   - Zx, Zy, Zz: components of the Zeeman interaction Hamiltonian
%     for the selected spins as defined by Hi=d(H)/d(B_i)
%     i=x,y,z where B_i are the cartesian components of
%     the external field. Units are MHz/mT = 1e9 Hz/T. To get the
%     full Hamiltonian, use H = Zx*B(1)+Zy*B(2)+Zz*B(3), where B is
%     the magnetic field in mT.
%   - H: the Hamiltonian of the Zeeman interaction.
