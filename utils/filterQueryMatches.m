function matcharray = filterQueryMatches(matchrow, hits)
% Helper function, takes a one row table of patch matches for a single query and 
%   filters it, to return 'hits' first matches in terms of whole images (instead of patches). 
% Again assumes patches are named (WHOLE IMAGE NAME)_(OLD HIT ID)_(PATCH ID).
% Returns 1 x hits string array.

wholeImgNames = regexprep(matchrow{1,:}, "_\d+_\d+$", "");
matcharray = unique(wholeImgNames, 'stable'); %unique keeps all <missing>s, so there should be enough elements to slice out first hits!
matcharray = matcharray(1:hits);

end