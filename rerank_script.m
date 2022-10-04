%%SET VARIABLES
%vocab = 20000;
%hits = 15;

%%OBS: for reranking, SURF is used to build BOF!  <- TODO: allow for others too? 
%%           Then reranking needs ot be split into cutting the patches and calculating features and then reranking. 
%mod1='mod1';
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
%   The saving in this case will mean not only to save the final csv of first (patch) matches but also the patches themselves? Or?

%   The query needs to be read in (only the first one suffices, we assume all queries are same sized?) and then its size will be the size 
%   of the patches for retrieval.

%   RetrieveMatches fucniton now accepts an array of strings (query names), so it can be used within reranking too.
%   So basically:   * read 1st query, get size
%                   * for each im in the matches for first query, cut the image to query sized patches
%                   * create new Bof on all of these new patch imges
%                   * call retrieveal function with new bof
%                   * call eval function on results, if desired

