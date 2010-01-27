function predictions = eval_IE(moneyFront, moneyRear,do5or10)

	overlap = 1;
	
	fprintf('constructing edge data set\n')
	edgeResults		 = IEgetDataSet('edge',moneyFront,moneyRear,0.0355,1,1,5,12,overlap);
	fprintf('constructing intensity data set\n')
	intensityResults = IEgetDataSet('Intensity',moneyFront,moneyRear,0.0355,1,1,5,12,overlap);

	dataSet = [edgeResults intensityResults];

	if do5or10 == 5
		load('IE_finalModels_5e');
	end
	if do5or10 == 10
		load('IE_finalModels_10e');
	end
	modelToUse				= finalModelsToUse(3:6,:);
	chosenModelsAlphasToUse	= finalModelsToUse(2,:);
	chosenModelsIdxToUse	= finalModelsToUse(7,:);
	
	predictions = IErunModels(modelToUse,chosenModelsIdxToUse',...
		dataSet,chosenModelsAlphasToUse);

end

