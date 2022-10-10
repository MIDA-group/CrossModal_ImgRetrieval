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
    bof = getBOF(fullfile('data',mod1), vocab, features, verbose);
    query_folder = fullfile('data', mod2);

else    %%% assume SIFT or RESNET, precomputed csvs needed
    bof = getBOF(fullfile("data",mod1,'features', features), vocab, features, verbose);
    query_folder = fullfile('data', mod2, 'features', features);

end

%%% RETRIEVAL (and EVAL) + SAVE RESULTS:
%[matches, whereis] = TestWrapper(query_folder, bof, hits, savename=savename, verbose=verbose, saveit=saveit, saveto=save_to);
matches = RetrieveMatches(query_folder, bof, hits, verbose=verbose);
if saveit
    writetable(matches, fullfile(save_to, strcat('matches_for_',savename,'.csv')), 'WriteRowNames', true);
    fprintf("* Retrieval results saved in  %s/matches_for_%s.csv\n", save_to, savename);
end


if evlt
    [correct, alla] = EvalMatches(matches, verbose=verbose);
    L = size(matches, 1);

    if saveit 
        writetable(correct, fullfile(save_to, strcat('success_',savename,'.csv')), 'WriteRowNames', true); 
        fprintf("* Retrieval evaluation results saved in  %s/success_%s.csv", save_to, savename);
    end
    fprintf("\n---> The query correctly retrieved (within %d-hits) in:  %d/%d  cases.", hits, alla, L);
end
fprintf("\n \n");

