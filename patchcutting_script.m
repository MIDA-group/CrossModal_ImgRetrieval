
%features='sift';

%mod1='modality1folder'; 
%mod2='modality2folder'; %folder with your queries

%save_to='resultsfolder'; %where your .csv intermediate results are saved, since we build on those

%%OBS: it will save the created patches (or whole images, if full size image retrieval is done) into data/mod1/patches

%read table from csv
matchtable = readtable(fullfile(save_to, strcat(mod2, '_in_', mod1, '_', features, '.csv')));
[nrqueries, nrhits] = size(matchtable);

mkdir('data', mod1, 'patches');
for queryname=matchtable.Properties.RowNames
    [~,~,suffix] = fileparts(queryname);
    query = imread(fullfile('data', mod2, queryname));
    %open first query img to get size %<- can be omitted, simply specify desired patch_size in that case
    patch_size = size(query);

    for hitnr=1:nrhits
        hitname = matchtable(queryname, hitnr);
        hit = imread(fullfile('data', mod1, strcat(hitname, suffix)));
        [patches, gridsize] = SplitImageIntoPatches(hit, patch_size);
        for k = 1:(gridsize(1)*gridsize(2))
            % filename is imgname_hit-index_patch-index
            imwrite(patches(:,:,k), fullfile('data', mod1, 'patches', strcat(hitname, '_',hitnr,'_', k, suffix)));
        end
    end

end

