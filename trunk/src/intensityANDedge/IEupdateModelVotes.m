function modelsVotes = IEupdateModelVotes(modelsVotes,bestModels,...
	goodClassified)
	
	for i=1:length(bestModels(:,1))
		index = bestModels(i,1);
		modelsVotes(1,index) = modelsVotes(1,index) +...
								(length(bestModels(:,1))+1-i);
		modelsVotes(2,index) = modelsVotes(2,index) + 1;
		modelsVotes(3,index) = modelsVotes(3,index) +... %alpha
								bestModels(i,2); 
		modelsVotes(4,index) = modelsVotes(4,index) +... %good classified rate
								goodClassified; 
		modelsVotes(5,index) = index; 
	end
end
