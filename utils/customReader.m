function wholefile = customReader(name)
%CUSTOMREADER Custom reader for imds with csv-s. 
%   Can be used with BagOfFeatures, but only together with 
%   customBagOfFeatureExtractor. 

%wholefile = readmatrix(name, 'NumHeaderLines', 1);
wholefile = table2array(readtable(name));
end

