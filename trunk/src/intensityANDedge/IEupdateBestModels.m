function finalModels =...
	IEupdateBestModels(finalModels,allModels,chosenModelsIdx,chosenModelsAlphas)
	
	%when the first best model is found or a better new model is found
	%finalModels were set to zeros and here the new model is added to this.
	%when a model is found that has the exact same results as the best up
	%to that point, finalModels is updated with these new found models

	for i=1:size(chosenModelsIdx,2)
		%for all models do
		finalModels(1,chosenModelsIdx(i)) =... %occurence
			finalModels(1,chosenModelsIdx(i)) + 1;
		finalModels(2,chosenModelsIdx(i)) =... %alphas
			finalModels(2,chosenModelsIdx(i)) + chosenModelsAlphas(i);
		finalModels(3,chosenModelsIdx(i)) =... %meanFit
			finalModels(3,chosenModelsIdx(i)) + allModels(1,chosenModelsIdx(i));
		finalModels(4,chosenModelsIdx(i)) =... %covFit
			finalModels(4,chosenModelsIdx(i)) + allModels(2,chosenModelsIdx(i));
		finalModels(5,chosenModelsIdx(i)) =... %meanUnfit
			finalModels(5,chosenModelsIdx(i)) + allModels(3,chosenModelsIdx(i));
		finalModels(6,chosenModelsIdx(i)) =... %covUnfit
			finalModels(6,chosenModelsIdx(i)) + allModels(4,chosenModelsIdx(i));
		finalModels(7,chosenModelsIdx(i)) = chosenModelsIdx(i);
	end
end

