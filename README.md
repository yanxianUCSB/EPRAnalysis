# EPRAnalysis
clients for Bruker EMX MTSL EPR spectra plotting

## Input
input01: Bruker EMX *.par and *.spc no Y-sweep.
input02: Bruker EMX *.par and *.spc with Y-sweep.

## clients
client01-compare2int: compare double integral of two spectra of input01.
client02-Overlay_MTSL: plot multiple MTSL spectra of input01.
client03-kinetics: plot single MTSL spectra of input02 over time.

## output
*.png and *.pdf figures

# How to install
1. clone or download entire repo to a local directory.
2. start MATLAB 2015 or later.
3. add folders and subfolders of "add2path-*" folders to path in MATLAB
4. go to client folder and run client.m or main.m
