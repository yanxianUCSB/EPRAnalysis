% isotopologues  generates list of isotopologues
%
%    isotopologues(NucList)
%    isotopologues(NucList,Abundances)
%    out = ...
%    
%    Computes all possible isotopologues of the
%    given list of nuclei or elements, including
%    their natural abundances.
%
%    NucList: list of isotopes or elements
%      e.g. 'Cu', '63Cu,N,N', 'H,H,C,C'
%
%    out: structure containing the isotope lists
%      for the various isotopologues and their abundances
%
%    If out is not requested, the results are display.
