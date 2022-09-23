function [matches, correct] = TestWrapper(query_folder, imageIndex, firsthits, NameValueArgs)
%TESTWRAPPER a function for testing the BOF. It first retrieves specified nr of best matches for the queries
%   (through RETRIEVEMATCHES), then evaluates the success of the retrieval (using EVALMATCHES). 
%
    arguments
        query_folder string
        imageIndex invertedImageIndex
        firsthits uint16
        NameValueArgs.savename string = "?"
        NameValueArgs.saveit logical = false 
        NameValueArgs.saveto string = "results"
        NameValueArgs.verbose logical = false
    end

savename = NameValueArgs.savename;
if strcmp(NameValueArgs.savename, "?") %ie not given
    query_folder_list = strsplit(query_folder,filesep);
    query_folder_list = query_folder_list(~cellfun('isempty', query_folder_list)); %for the off chance that the given query folder is a path
    savename = strjoin(query_folder_list, '-');
end
matches = RetrieveMatches(query_folder, imageIndex, firsthits, savename, savematches=NameValueArgs.saveit, saveto=NameValueArgs.saveto, verbose=NameValueArgs.verbose);
[correct, alla] = EvalMatches(matches, query_folder, savename, saveit=NameValueArgs.saveit, saveto=NameValueArgs.saveto, verbose=NameValueArgs.verbose);
L = size(matches, 1);

%this below we print regardless of verbosity (?)
fprintf("\n>>>> Testing module finished.\n");
if NameValueArgs.saveit 
    fprintf("Intermediate results saved in %s/matches_%s.csv   and   %s/success_%s.csv\n", NameValueArgs.saveto, savename, NameValueArgs.saveto, savename);
end
fprintf(">>> The query correctly retrieved in:  %d/%d  cases.\n \n", alla, L);


end