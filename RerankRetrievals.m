function matches = RerankRetrievals(oldmatches, query_folder, bof_folder, features, vocab, hits, NameValueArgs)
%RERANKRETRIEVALS reranks the retrievals in 'oldmatches', assuming queries reside in 'query_folder',
%   the data for building a bof resides in 'bof_folder', and bof is built using 'features' and a 
%   vocabulary of size 'vocab'. 
%   It retrieves the first 'hits' best-matching objects. Returns an array
%   of size nr.queries X hits, containing the first 'hits' retrieved 
%   matches' names for each query.
%       Use optional verbose=true for more verbosity

    arguments
        oldmatches table
        query_folder string
        bof_folder string
        features string
        vocab uint16
        hits uint16
        NameValueArgs.verbose logical = false
    end



fprintf("\nReranking matches...");
if NameValueArgs.verbose; fprintf("\n-------------------------\n"); end;

queries = oldmatches.Properties.RowNames;
[nrqueries, nrhitsold] = size(oldmatches); 

L = length(dir(bof_folder)); %will for sure be larger than nr of all matches PER query. Thus all matches made will be returned (by retrieveImages)
all_matches = strings(nrqueries, hits);
all_matches(:) = missing;
%for each query, find patches in patch (patch/features) folder, create bof depending on suffix/features, call RetrieveMatches
for querynr=1:nrqueries
    queryname = queries{querynr};
    query = fullfile(query_folder, queryname);

    
    fprintf("\nBuilding BagOfFeatures for %s...\n", queryname);
    
    %[~, bof] = evalc('getBOF(getListOfFiles(bof_folder, oldmatches(queryname,:)), vocab, features, false)'); %Can remove evalc, just here to avoid too much output in command line really...
    bof = getBOF(getListOfFiles(bof_folder, oldmatches(queryname,:)), vocab, features, NameValueArgs.verbose);

    querymatches = RetrieveMatches(query, bof, L, verbose=false); %get ALL hits, then take out first hits nr of image matches 

    %gather results for all queries and save to new MATCHES table
    all_matches(querynr,:) = filterQueryMatches(querymatches, hits); 

    if NameValueArgs.verbose
        fprintf(strcat("Newly reranked matches to ", queryname, ":\n"));
        allmatchesstring = all_matches(querynr, :);
        allmatchesstring(ismissing(allmatchesstring)) = "";
        fprintf(strjoin(repelem("%s ", hits)), allmatchesstring);
        fprintf("\n");
    end

end


matches = array2table(all_matches, RowNames=queries, VariableNames=string(1:hits));

fprintf("DONE.\n");
end