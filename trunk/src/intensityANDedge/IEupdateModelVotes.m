function modelsVotes = IEupdateModelVotes(modelsVotes,bestModels,...
	goodClassified)
	
	for i=1:length(bestModels(:,1))
		%for all incomming models update the votes with them
		index = bestModels(i,1);
		modelsVotes(1,index) = modelsVotes(1,index) +... % weighted vote *
								(length(bestModels(:,1))+1-i);
		modelsVotes(2,index) = modelsVotes(2,index) + 1; %normal vote
		modelsVotes(3,index) = modelsVotes(3,index) +... %alpha
								bestModels(i,2); 
		modelsVotes(4,index) = modelsVotes(4,index) +... %good classified rate
								goodClassified; 
		modelsVotes(5,index) = index; 
	end
end

% * weighted vote is that the first in the list recieves a vote of the
% length of the list and the last recieves a vote of 1. In this way the
% notion of location in the list is taken into account
