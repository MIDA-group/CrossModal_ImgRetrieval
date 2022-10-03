top10not1 = (1 < hit_idx) & (hit_idx < (hits+1));
patch_size = [256, 256];
RefinedHits_BOF = hit_idx;
tf = ["not the right one", "the right one"];
for i = find(top10not1) % indices of all the query images we want
    qimg_dir = query_imgs(i); % this is a dir-struct
    % use filesep to work on windows
    qimg = imread([qimg_dir.folder, filesep(), qimg_dir.name]);
    % unfortunately it seems imageDatastore only deals with files, not
    % [w,h,N]-matrices... so we write the patches to a temp folder
    tmp_dir = [tempdir(), 'imgDataStoreExperimentThatIsSafeToRemove/'];
    if (isfolder(tmp_dir))
        delete([tmp_dir, filesep(), '*']);
        rmdir(tmp_dir);
    end 
    mkdir(tmp_dir);
    for j = 1:hit_idx(i)
        [patches, sz] = SplitImageIntoPatches(imread(top_hits(i,j)), patch_size);
        [~, ~, ext] = fileparts(top_hits(i,j));
        for k = 1:(sz(1)*sz(2))
            % filename is hit-index_patch-index
            imwrite(patches(:,:,k), sprintf(['%s',filesep(),'%04d_%04d%s'], ...
                                            tmp_dir, j, k, ext));
        end
    end
    % build imageDatastore from all patches from all images in top_hits
    db_store = imageDatastore(tmp_dir);
    % index the BoW
    img_idx = indexImages(db_store, bagOfFeatures(db_store, 'VocabularySize', vocab), ...
                          'SaveFeatureLocations', true);
    % query the img_idx using the current queryimage
    patch_indices = retrieveImages(qimg, img_idx, 'NumResults', Inf);
    % convert ranked patch-index to ranked image-index
    rii = cellfun(@fn2rii, db_store.Files(patch_indices));
    % we know that the previous image has the highest index, hence just max
    [~, new_i] = max(rii);
    if (new_i > 1); new_i = length(unique(rii(1:(new_i-1))))+1; end
    RefinedHits_BOF(i) = new_i;
    delete([tmp_dir, filesep(), '*']);
    rmdir(tmp_dir);
end

function rii = fn2rii(fn)
    [~,nm] = fileparts(fn);
    rii = str2double(nm(1:4));
end