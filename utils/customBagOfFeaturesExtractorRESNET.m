function [features, featureMetrics] = customBagOfFeaturesExtractorRESNET(I)

features = I(:, :); 
featureMetrics = sum(features,2);  %either based on largest element in feature map, or sum of all? Or avg element?
%featureMetrics=ones(1,size(features,1))/size(features,1);

end
