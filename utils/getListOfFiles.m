function pathlist = getListOfFiles(folderpath, topnamelist)
%Helper function, making a list of paths to all files in (row table) folderpath 
%   whose name begins with one of the entries in topnamelist. 
%   Used for getting a lost of files for building a BOF per query.

pathlist = {};
L = width(topnamelist);
for entry = 1:L
    if ismissing(topnamelist(1, entry))
        break; %we've reached the end of the matches
    end
    topname = topnamelist{1, entry}{:};
    [~, name, suffix] = fileparts(topname);
    pathlist = [pathlist, fullfile(folderpath, strcat(name, '_*', suffix))];
end

end