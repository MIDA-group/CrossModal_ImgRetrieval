function imageIndex = getBOF(feature_csvs, vocabulary_size, extractor_type, verbose)
% GETBOF generates bag of features on features in feature_csvs, with
%   vocabulary_size. It outputs searchable image index. 
%   OBS: Works only on csvs, in our case extracted by sift or resnet.
%   extractor_type = sift or resnet. Other currently not implemented.
    arguments
        feature_csvs string
        vocabulary_size uint32
        extractor_type string 
        verbose logical = false
    end

if strcmp(extractor_type, 'sift')
    customExtractor = @customBagOfFeaturesExtractor;
    saveFeatLocs = true;
else %assume extractor_type=='resnet'
    customExtractor = @customBagOfFeaturesExtractorRESNET;
    saveFeatLocs = false;
end

%do bag of features
imds = imageDatastore(feature_csvs,'FileExtensions',{'.csv'}, 'ReadFcn', @customReader);
csvBag = bagOfFeatures(imds, 'VocabularySize', vocabulary_size, 'CustomExtractor', customExtractor, 'Verbose', verbose);

%index all images
imageIndex = indexImages(imds, csvBag, 'SaveFeatureLocations', saveFeatLocs);

end

