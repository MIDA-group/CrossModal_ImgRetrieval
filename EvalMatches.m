function [correct, alla] = EvalMatches(matches, query_folder, savename, NameValueArgs)
%EVALMATCHES evaluates the correctness of the retrieved matches for the queries in query_folder. 
%   Returns an array containing (for every query) the rank of the correct match within the chosen nr of 
%   retrieved objects. 0 for those where correct match was not found within the provided few retrievals.
%   OBS: requires the query and its perfect match to share the same name. 
%       If saveit=true, saves the output in a csv file inside saveto folder.  

    arguments
        matches (:,:) string
        query_folder string
        savename string 
        NameValueArgs.saveit logical = false 
        NameValueArgs.saveto string = "results"
        NameValueArgs.verbose logical = false
    end

fprintf("\nEvaluating retrieval success...\n-------------------------\n");
queries = dir(query_folder);
itemgetter = @(x) x(1);
queries = queries((~cellfun(@isempty, {queries.date})) & ~cellfun(itemgetter, {queries.isdir})); %remove any folders and the like

L = length(queries);
hits = size(matches, 2);

correct = zeros(L,1);
for filnr=1:L
    for hitnr=1:hits
        fil = queries(filnr).name;
        if contains(fil,  matches(filnr, hitnr)) %query name should contain the match. matches (as output by RetrieveMatches) are suffix free!
            correct(filnr,1) = hitnr;
            break
        end
    end
end

if NameValueArgs.saveit
    tmp = array2table(correct, RowNames={queries.name});
    writetable(tmp, fullfile(NameValueArgs.saveto, strcat('success_',savename,'.csv')), 'WriteRowNames', true); 
    %'correct' contains 0 if correct match not found within HITS retrievals, else the ranking of the correct match within the first HITS retrievals.
end



if NameValueArgs.verbose
    for filnr=1:L
        if correct(filnr)==0
            matchy="NOT FOUND";
        else %correct match ranked within HITS 
            matchy=strcat("ranked ", num2str(correct(filnr)));
        end
        fprintf(strcat("Match for ", queries(filnr).name, ": \t ", matchy, "\n"));
    end
end

alla=0;
for filnr=1:L
    if correct(filnr)>0
        alla = alla+1;
    end
end

fprintf("DONE.\n");

end