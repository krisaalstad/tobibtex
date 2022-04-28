% Example script calling tobibtex.m to convert refs.txt to bibtex format.
clearvars;

inputfile='refs.txt';
outputfile='thebib.bib';
status=tobibtex(inputfile,outputfile);