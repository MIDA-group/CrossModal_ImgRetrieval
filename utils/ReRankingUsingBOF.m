top10not1 = (1 < hit_idx) & (hit_idx < (hits+1));
RefinedHits_BOF = hit_idx;
tf = ["not the right one", "the right one"];
for i = find(top10not1) % indices of all the query images we want
    qimg_dir = query_imgs(i); % this is a dir-struct
    % use filesep to work on windows
    qimg = imread([qimg_dir.folder, filesep(), qimg_dir.name]);
    % build imageDatastore from all images in top_hits for query
    db_store = imageDatastore(top_hits(i, top_hits(i,:) ~= ""));
    % index the BoW
    img_idx = indexImages(db_store, bagOfFeatures(db_store, 'VocabularySize', vocab), ...
                          'SaveFeatureLocations', true);
    % query the img_idx using the current queryimage
    ranked_indices = retrieveImages(qimg, img_idx, 'NumResults', Inf);
    % we know that the previous image has the highest index, hence just max
    [~, new_i] = max(ranked_indices);
    RefinedHits_BOF(i) = new_i;
end

