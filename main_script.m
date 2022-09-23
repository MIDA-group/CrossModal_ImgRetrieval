addpath('./utils/'); %for the utility functions


%%SET VARIABLES
%vocab = 20000;
%hits = 15;

%features='sift';  %surf/resnet/sift
%mod1='modality1folder'; 
%mod2='modality2folder'; 

%%if saving desired:
%saveit=true;
%save_to='resultsfolder';

%%intermediate reporting verbosity:
%verbose=false;

%%what to do; only retrieval or also eval?
%evlt=false;

savename = strcat(mod2, '_in_', mod1, '_', features);
if strcmp(features, 'surf')
    %%% using SURF
    imgstorage = imageDatastore(fullfile('data',mod1)); %, 'FileExtensions', {'.tif'}); %TODO: read extension automatically, raise eror if not supported?
    bof = indexImages(imgstorage, bagOfFeatures(imgstorage, 'VocabularySize', vocab, 'Verbose', verbose), 'SaveFeatureLocations', true);
    query_folder = fullfile('data', mod2);

else    %%% assume SIFT or RESNET, precomputed csvs needed
    bof = getBOF(fullfile("data",mod1,'features', features), vocab, features, verbose);
    query_folder = fullfile('data', mod2, 'features', features);

end

%%% RETRIEVAL and EVAL+SAVE RESULTS:
%[matches, whereis] = TestWrapper(query_folder, bof, hits, savename=savename, verbose=verbose, saveit=saveit, saveto=save_to);
matches = RetrieveMatches(query_folder, bof, hits, savename, savematches=saveit, saveto=save_to, verbose=verbose);

if evlt
    [correct, alla] = EvalMatches(matches, query_folder, savename, saveit=saveit, saveto=save_to, verbose=verbose);
    L = size(matches, 1);

    if saveit 
        fprintf("\nIntermediate results saved in %s/matches_%s.csv   and   %s/success_%s.csv\n", saveto, savename, save_to, savename);
    end
    fprintf("---> The query correctly retrieved in:  %d/%d  cases.", alla, L);
end
fprintf("\n \n");

