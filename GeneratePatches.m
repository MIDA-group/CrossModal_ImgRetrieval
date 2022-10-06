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
        NameValueArgs.verbose logical = false
    end


mkdir(bof_folder, 'patches');

fprintf("\n Generating query-sized patches for reranking...\n");
[nrqueries, nrhits] = size(matchtable);
for queryname=matchtable.Properties.RowNames
    [~,~,suffix] = fileparts(queryname);
    query = imread(fullfile(query_folder, queryname));
    %open first query img to get size %<- can be omitted, simply specify desired patch_size in that case
    patch_size = size(query);

    if NameValueArgs.verbose
        fprintf("\t Cutting up the matches for %s \n", queryname);
    end

    for hitnr=1:nrhits
        hitname = matchtable(queryname, hitnr);
        hit = imread(fullfile(bof_folder, strcat(hitname, suffix)));
        [patches, gridsize] = splitImageIntoPatches(hit, patch_size);
        for k = 1:(gridsize(1)*gridsize(2))
            % filename is imgname_hit-index_patch-index
            imwrite(patches(:,:,k), fullfile(bof_folder, 'patches', strcat(hitname, '_',hitnr,'_', k, suffix)));
        end
    end

end
fprintf("DONE. \n");
end
