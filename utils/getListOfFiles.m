function pathlist = getListOfFiles(folderpath, topnamelist)
%Helper function, making a list of paths to all files in folderpath 
%   whose name begins with one of the entries in topnamelist. 
%   Used for getting a lost of files for building a BOF per query.

pathlist = [];
for topname = topnamelist
    [~, name, suffix] = fileparts(topname);
    pathlist = [pathlist, strcat(folderpath, name, '_*', suffix)];
end

end