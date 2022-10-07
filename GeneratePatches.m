function GeneratePatches(matchtable, query_folder, bof_folder, NameValueArgs)
% GENERATEPATCHES uses the matchtable and for every query (row) from query_folder
% generates query-sized patches of all the retrieved matches from bof_folder. 
%   OBS: it will save the created patches (or whole images, if full size image 
%   retrieval is done) into bof_folder/patches
%   SOME MAY BE DUPLICATED, IF THEY APPEAR IN FIRST HITS FOR MULTIPLE QUERIES!


    arguments
        matchtable table
        query_folder string
        bof_folder string 
        NameValueArgs.saveto string = fullfile(bof_folder, 'patches')
        NameValueArgs.verbose logical = false
    end


[~, ~] = mkdir(NameValueArgs.saveto);

fprintf("\n Generating query-sized patches for reranking...\n");

[nrqueries, nrhits] = size(matchtable);
for querynr=1:nrqueries
    fullqueryname = matchtable.Properties.RowNames{querynr};
    [~,queryname,~] = fileparts(fullqueryname); %get rid of suffix, since it could be csv
    tmp = dir(fullfile(query_folder, strcat(queryname,'*'))); %find the actual image file with this name
    [~, ~, suffix] = fileparts(tmp.name); %get the image suffix
    query = imread(fullfile(query_folder, strcat(queryname,suffix)));
    %open first query img to get size %<- can be omitted, simply specify desired patch_size in that case
    patch_size = size(query);

    if NameValueArgs.verbose
        fprintf("\t Cutting up the matches for %s \n", queryname);
    end

    for hitnr=1:nrhits
        hitname = matchtable{fullqueryname, hitnr}{:};
        hit = imread(fullfile(bof_folder, strcat(hitname, suffix)));
        ndim = ndims(hit);
        S.type='()';
        S.subs = repmat({':'}, 1, ndim); % can be 2 or 3 dim (if rgb)
        
        [patches, gridsize] = splitImageIntoPatches(hit, patch_size);
        for k = 1:(gridsize(1)*gridsize(2))
            % filename is imgname_hit-index_patch-index
            S.subs{ndim} = k;
            imwrite(subsref(patches,S), fullfile(NameValueArgs.saveto, strcat(hitname,'_', num2str(k), suffix)));
        end
    end

end
fprintf("DONE. \n");
end
