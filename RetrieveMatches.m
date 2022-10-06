function matchestable = RetrieveMatches(query_folder, imageIndex, firsthits, NameValueArgs)
%RETRIEVEMATCHES tries to find all images from query_folder inside imageIndex, 
%   and retrieves the first firsthits best-matching objects. Returns a table
%   of size nr.queries X firsthits, containing the first firsthits retrieved 
%   matches' names for each query.
%       Use optional verbose=true for more verbosity

    arguments
        query_folder string
        imageIndex invertedImageIndex
        firsthits uint16
        NameValueArgs.verbose logical = false
    end

fprintf("\nRetrieving matches...\n-------------------------\n");
to_find = dir(query_folder);

itemgetter = @(x) x(1);
to_find = to_find((~cellfun(@isempty, {to_find.date})) & ~cellfun(itemgetter, {to_find.isdir})); %remove any folders and the like

L = length(to_find);


[ ~, ~, suffix] = fileparts(to_find(1).name);

if strcmp(suffix,".csv")
    reader = @customReader;
else
    reader = @imread; %assume that if it's not csvs, it's tiffs/other supported img format. 
end

all_matches = strings(L, firsthits);
all_matches(:) = missing;
for fil=1:L
    filname = to_find(fil).name;
    foldername = to_find(fil).folder;
    query_features = reader(fullfile(foldername, filname));
    
    indices = retrieveImages(query_features, imageIndex, 'NumResults', Inf);
    l = length(indices);

    for i=1:min(l,firsthits)
        match = imageIndex.ImageLocation{indices(i)};
        %now save successful hits.
        [~, tmpname] = fileparts(match); %only name without suffix
        all_matches(fil, i) = tmpname;
    end

    if NameValueArgs.verbose
        fprintf(strcat("Found matches to ", filname, ":\n"));
        allmatchesstring = all_matches(fil, :);
        allmatchesstring(ismissing(allmatchesstring)) = "";
        fprintf(strjoin(repelem("%s ", firsthits)), allmatchesstring);
        fprintf("\n");
    end
end

matchestable = array2table(all_matches, RowNames={to_find.name}, VariableNames=string(1:firsthits));

fprintf("DONE.\n");
end