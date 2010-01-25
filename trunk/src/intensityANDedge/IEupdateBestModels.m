function finalModels =...
	IEupdateBestModels(finalModels,allModels,chosenModelsIdx,chosenModelsAlphas)
	for i=1:size(chosenModelsIdx,2)

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

