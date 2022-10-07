addpath('./utils/'); %for the utility functions

%%SET VARIABLES
%vocab = 20000;
%hits = 15;

%features='surf';
%mod1='mod1'; %/patches
%mod2='mod2'; 
%%OBS: requires a csv with first N matches to be reranked to exist: matches_for_mod2_in_mod1_features.csv !!!
%%      (Makefile will make sure it's done first if it doesn't, but if running by hand make sure it exists!) 

%%if saving desired:
%saveit=true;
%save_to='resultsfolder';

%%intermediate reporting verbosity:
%verbose=false;

%%what to do; only reranking or also eval?
%evlt=false;


%TODO: to allow eval on top, reranking function should return a table with row names (queries) again. Patches can be saved by imgname_PATCHNR, 
%   and eval will still work. 

%   The query needs to be read in (only the first one suffices, we assume all queries are same sized?) and then its size will be the size 
%   of the patches for retrieval.

%   RetrieveMatches can be used within reranking too.
%   So basically:   * get names of all queries (either from folder or csv)
%                   * for each query find all patches that are cut of its highly ranked hits
%                   * create new Bof on all of these new patch imges
%                   * call retrieveal function with new bof
%                   * call eval function on results, if desired


%Get all guery names from old savename csv
oldmatches = readtable(fullfile(save_to, strcat('matches_for_', mod2, '_in_', mod1, '_', features,'.csv')), 'ReadVariableNames', true, 'ReadRowNames', true, 'Delimiter', ',', 'VariableNamingRule', 'preserve');

%get suffix (if csv, folder whould be features instead of img), or just check feature type 
if strcmp(features, 'surf')
    %%% using SURF
    bof_folder = fullfile('data', mod1, 'patches');
    query_folder = fullfile('data', mod2);
   
else    %%% assume SIFT or RESNET, precomputed csvs needed
    bof_folder = fullfile('data', mod1, 'patches', 'features', features);
    query_folder = fullfile('data', mod2, 'features', features);
    
end


matches = RerankRetrievals(oldmatches, query_folder, bof_folder, features, vocab, hits, verbose=verbose);



savename = strcat(mod2, '_in_', mod1, '_', features, '_reranked');
if saveit
    writetable(matches, fullfile(save_to, strcat('matches_for_',savename,'.csv')), 'WriteRowNames', true);
    fprintf("* Reranked retrieval results saved in  %s/matches_for_%s.csv\n", save_to, savename);
end

%do eval on new matches table if desired 
if evlt
    [correct, alla] = EvalMatches(matches, verbose=verbose);

    if saveit 
        writetable(correct, fullfile(save_to, strcat('success_',savename,'.csv')), 'WriteRowNames', true); 
        fprintf("* Reranked retrieval evaluation results saved in  %s/success_%s.csv", save_to, savename);
    end
    fprintf("\n---> After reranking, the query correctly retrieved in:  %d/%d  cases.", alla, height(matches));
end
fprintf("\n \n");
