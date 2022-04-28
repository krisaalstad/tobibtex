function status=tobibtex(readf,writef)
%% status=tobibtex(readf,writef) : convert text references to BibTeX
% BibTeX is the bibliography format used for LaTeX typesetting system which 
% is widely used for scientific books and articles. 
%
% example.m Provides an example script to run this converter.
%
% Input:
%   readf=String specifying the text file (can include full path) to read 
%   from (.txt)
%   
%   writef=String specifying the bibtex file (can include full path) to
%   read from (.bib)
%
% Output:
%   status=Statust variable indicating if the bibtex file was written
%   succesfully. This is just a boolean that will always be 1 if the
%   function runs succesfully.
%   All the references will be of the form LastnameYYYY where Lastname is
%   the last name fo the first author and YYYY is the year.
%   If a first author has multiple publications that are cited in the same
%   year, the first publication will be cited with LastnameYYYY while
%   subsequent ones will be LastnameYYYYb, LastnameYYYYc etc...
%
% Assumptions:
%   This routine assumes that the text references are of the form:
%
%   Lastname, F., Lastname, F., & Lastname F. (YYYY). Title. Journal, 
%   Volume(Number), Pages, DOI
%
%   where Lastname is a palcehold for an author's last name and F. is the
%   first letter of an authors first name (e.g. Kristoffer = K.), YYYY is
%   the year that the article was published, title is the title of the 
%   article, Journal is the journal name, Volume is the volume of the
%   journal, Number is the (optional and not used) number of the journal,
%   Pages are the pages of the article specified as (e.g.) 57-63 for pages
%   57 to 63, DOI is the digital object identifier specified as a link of
%   the form https://doi.org/10.1017/S0962492910000061 where the number 
%   10.1017/S0962492910000061 corresponds to the DOI. The script
%   accomodates the fact that some articles may have so many authors that
%   the author list is truncated by "et al."
%   Although most references will be journal articles, the routine also
%   detects if an entry is a book which corresponds to entries that don't
%   have a volume, pages, and possibly not a DOI but instead includes a
%   publsiher.
%
%   See refs.txt for an example of an input file.
%
%   N.B. This has only been tested on a linux OS (ubuntu) and may need some
%   tuning for Windows or Mac. 
%
%   Matlab savy users should also relatively easily be able to adapt the
%   code to cover other formats for the input text file. 
%
%   Code by: Kristoffer Aalstad (April 2022).

% Create the output bibtex file, delete it if it already exists.
if any(exist(writef,'file'))
    system(sprintf('rm %s',writef));
end
system(sprintf('touch %s',writef));

% Open files for reading and writing.
fidr=fopen(readf);
fidw=fopen(writef,'w');
k=0;
while ~feof(fidr)
    
    l=fgetl(fidr);
    ls=strsplit(l,').');
    
    ay=ls{1};
    ay=strsplit(ay,'(');
    authors=ay{1};
    year=ay{2};
    year=strtrim(year);
    authors=strrep(authors,'et al.','others');
    authors=strrep(authors,'&','');
    authors=strrep(authors,'.,','. and');
    % Convert accents (may need to add more) to bibtex format
    authors=strrep(authors,'á','\''{a}');
    authors=strrep(authors,'ó','\''{o}');
    authors=strrep(authors,'í','\''{i}');
    authors=strrep(authors,'é','\''{e}');
    authors=strtrim(authors);
    lead=strsplit(authors,','); lead=lead{1};
    lead=strrep(lead,'\''{','');
    lead=strrep(lead,'}','');
    lead=strrep(lead,'-','');
    lead=strrep(lead,' ','');
    name=[lead year];
    
    
    tj=ls{2}; % title and journal info
    tjs=strsplit(tj,'.');
    title=strtrim(tjs{1});
    title=strtrim(title);
    title=strrep(title,'_','\_');
    doistr='https://doi.org/';
    isdoi=any(strfind(l,doistr));
    
    % Split should be (year). not just ).
    dosplit=sprintf('(%s).',year);
    ls=strsplit(l,dosplit);
    ls=ls{2};
    
    if ~isdoi % These will all be books (or reports, but they usually fit under book in bibtex)
        %disp(in);
        lss=strsplit(ls,'.');
        pubinfo=lss{end};
        pubinfo=strtrim(pubinfo);
        
        % Now you have enough to generate the bib entry
        citation=sprintf('@book{%s,',name);
        fprintf(fidw,'%s \n',citation);
        %disp(citation);
        authors=sprintf('author={%s},',authors);
        fprintf(fidw,'%s \n',authors);
        title=sprintf('title={{%s}},',title);
        fprintf(fidw,'%s \n',title);
        year=sprintf('year={%s},',year);
        fprintf(fidw,'%s \n',year);
        pubinfo=sprintf('publisher={%s},',pubinfo);
        fprintf(fidw,'%s \n',pubinfo);
        fprintf(fidw,'}\n \n');
        
    else % Has doi (work backwards)
        
        ls=strtrim(ls);
        ls=strsplit(ls,doistr);
        doi=ls{end};
        ls=ls{1};
        doi=sprintf('DOI={%s},',doi);
        %disp(ls);
        lss=strsplit(ls,',');
        
        if numel(lss)==1 % In this case it's a book with a doi (no volume or pages info)
            isart=0;
            citation=sprintf('@book{%s,',name);
            lss=strsplit(lss{1},'.');
            pubinfo=lss{end};
            if isempty(strtrim(pubinfo))
                pubinfo=lss{end-1};
            end
            pubinfo=strtrim(pubinfo);
            pubinfo=sprintf('publisher={%s},',pubinfo);
            
            fprintf(fidw,'%s \n',citation);
            authors=sprintf('author={%s},',authors);
            fprintf(fidw,'%s \n',authors);
            title=sprintf('title={{%s}},',title);
            fprintf(fidw,'%s \n',title);
            year=sprintf('year={%s},',year);
            fprintf(fidw,'%s \n',year);
            fprintf(fidw,'%s \n',pubinfo);
            fprintf(fidw,'%s \n',doi);
            fprintf(fidw,'}\n \n');
            
        else % It's an article
            isart=1;
            if any(exist('citation'))
                oldcitation=citation;
            else
                oldcitation='';
            end
            citation=sprintf('@article{%s,',name);
            if any(strcmp(citation,oldcitation))
                citation=sprintf('@article{%sb,',name); % If the citation already exists, at "b" at the end
            end
            pp=lss{end};
            pp=strrep(pp,'.','');
            pp=strtrim(pp);
            vol=lss{end-1}; % Set limit on length to identify those that are not volumes...
            if numel(vol)>20 % Limit length of volume string (>15 or so indicates a journal name or something else)
                tmp=vol;
                tmp=strsplit(tmp,'.');
                tmp=tmp{end};
                journal=tmp;
                journal=strtrim(journal);
                vol='';
            else
                tmp=lss{end-2};
                tmp=strsplit(tmp,'.');
                tmp=tmp{end};
                journal=tmp;
                journal=strtrim(journal);
            end
            vol=strsplit(vol,'('); % Remove the issue part if it exists.
            vol=vol{1};
            vol=strtrim(vol);
            
            fprintf(fidw,'%s \n',citation);
            authors=sprintf('author={%s},',authors);
            fprintf(fidw,'%s \n',authors);
            title=sprintf('title={{%s}},',title);
            fprintf(fidw,'%s \n',title);
            year=sprintf('year={%s},',year);
            fprintf(fidw,'%s \n',year);
            journal=sprintf('journal={%s},',journal);
            fprintf(fidw,'%s \n',journal);
            volume=sprintf('volume={%s},',vol);
            fprintf(fidw,'%s \n',volume);
            pages=sprintf('pages={%s},',pp);
            fprintf(fidw,'%s \n',pages);
            fprintf(fidw,'%s \n',doi);
            fprintf(fidw,'}\n \n');
            
        end
    end
    
    k=k+1;
    
end

if feof(fidr)
    fprintf('Converted %d references to bibtex format \n',k);
    fprintf('Successfully generated the BibTeX file %s, enjoy LaTeX \n',writef);
    status=true;
end


end