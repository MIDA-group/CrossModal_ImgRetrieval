function [features, featureMetrics, varargout] = customBagOfFeaturesExtractor(I)
% This function implements SIFT feature extraction, to be used in
% bagOfFeatures.
%
% [features, featureMetrics] = exampleBagOfFeaturesExtractor(I) returns
% SIFT features extracted apriori by fiji.
%
% [..., featureLocations] = exampleBagOfFeaturesExtractor(I) optionally
% return the feature locations. This is used by the indexImages function
% for creating a searchable image index.
%
% Example: Using custom features in bagOfFeatures
% ------------------------------------------------
% % Define a set of images
% setDir = fullfile(toolboxdir('vision'),'visiondata','imageSets');
% imgDs = imageDatastore(setDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
% 
% % Specify a custom extractor function
% extractor = @customBagOfFeaturesExtractor;
% customBag = bagOfFeatures(imgDs, 'CustomExtractor', extractor)
%
% See also bagOfFeatures, retrieveImages, indexImages
 
%% Step 1: Take only features from the input feature array
features = I(:, 5:end); %3:end (scale and orientation are I think not needed. Used only during calculation of SIFT points...

%% Step 2: Extract Point Locations of Features
locations = [I(:,1) I(:,2)];

%% Step 3: Compute the Feature Metric
% The feature metrics indicate the strength of each feature, where larger
% metric values are given to stronger features. The feature metrics are
% used to remove weak features before bagOfFeatures learns a visual
% vocabulary. You may use any metric that is suitable for your feature
% vectors.
%
% Use the variance of the SURF features as the feature metric.
featureMetrics = var(features,[],2);  %should we force scale and orientation to have large strength? <- OR SHOULD WE JUST AVOIND REMOVING WEAK 20% OF FEATS?
%featureMetrics=ones(1,size(features,1))/size(features,1);

%% Step 4: Optionally return the feature location information. The feature location
% information is used for image search applications. See the retrieveImages
% and indexImages functions.

if nargout > 2
    % Return feature location information
    varargout{1} = locations;
end

end
