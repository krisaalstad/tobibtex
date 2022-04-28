# tobibtex
Converts references in a text (.txt) file to bibtex format and writes these to a .bib file using the MATLAB function tobibtex.m

To test this function, run the example script (**example.m**) which takes the 124 references in the file **refs.txt**, converts them to bibtex format and then writes them to the file **thebib.bib** that is ready for use as a bibliography in a LaTeX document. 

For details on how this works, look at the function itself (**tobibtex.m**) which includes an extensive initial set of comments. Comments in the body of the function itself are minimal since these are all elementary string processing operations that are tied to the assumed input format. The idea is that this can serve as a skeleton for other input formats as well.

Note that this is currently set up for the copernicus bib class, so it writes a DOI field of the form DOI={} which is not standard in bibtex. This can easily be edited out or changed depending on the desired format (and journal constraints). 

The script has also only been tested on a linux OS (ubuntu) and may need some tuning for windows and mac. 


