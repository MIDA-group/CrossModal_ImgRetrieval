function imageIndex = getBOF(bof_files, vocabulary_size, extractor_type, verbose)
% GETBOF generates bag of features on features in bof_files, with
%   vocabulary_size. It outputs searchable image index. 
%   OBS: Works only on csvs, as extracted by sift or resnet, or images.
%   extractor_type = sift or resnet or surf. Other currently not implemented.
    arguments
        bof_files string
        vocabulary_size uint32
        extractor_type string 
        verbose logical = false
    end

if strcmp(extractor_type, 'sift')
    customExtractor = @customBagOfFeaturesExtractor;
    args = {'VocabularySize', vocabulary_size, 'CustomExtractor', customExtractor, 'Verbose', verbose};
    imdargs = {'FileExtensions', {'.csv'}, 'ReadFcn', @customReader};
    saveFeatLocs = true;

elseif strcmp(extractor_type, 'surf')
    args = {'VocabularySize', vocabulary_size, 'Verbose', verbose};
    imdargs = {};
    saveFeatLocs = true;

else %assume extractor_type=='resnet'
    customExtractor = @customBagOfFeaturesExtractorRESNET;
    args = {'VocabularySize', vocabulary_size, 'CustomExtractor', customExtractor, 'Verbose', verbose};
    imdargs = {'FileExtensions', {'.csv'}, 'ReadFcn', @customReader};
    saveFeatLocs = false;
    
end

%do bag of features
imds = imageDatastore(bof_files, imdargs{:});
csvBag = bagOfFeatures(imds, args{:});

%index all images
imageIndex = indexImages(imds, csvBag, 'SaveFeatureLocations', saveFeatLocs);

end
