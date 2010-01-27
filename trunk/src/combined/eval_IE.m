function predictions = eval_IE(moneyFront, moneyRear)

	overlap = 1;
	
	fprintf('constructing edge data set\n')
	edgeResults		 = IEgetDataSet('edge',moneyFront,moneyRear,0.0355,1,1,5,12,overlap);
	fprintf('constructing intensity data set\n')
	intensityResults = IEgetDataSet('Intensity',moneyFront,moneyRear,0.0355,1,1,5,12,overlap);

	dataSet = [edgeResults intensityResults];

	%%%% model of best overall error %%%%
	load('IE_finalModels');
	modelToUse				= finalModelsToUse(3:6,:);
	chosenModelsAlphasToUse	= finalModelsToUse(2,:);
	chosenModelsIdxToUse	= finalModelsToUse(7,:);
	
	finalModelLabels = IErunModels(modelToUse,chosenModelsIdxToUse',...
		dataSet,chosenModelsAlphasToUse);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%% model of best unfit error %%%%%
	load('IE_uberModels');
	modelToUse				= uberModelsToUse(3:6,:);
	chosenModelsAlphasToUse	= uberModelsToUse(2,:);
	chosenModelsIdxToUse	= uberModelsToUse(7,:);

	uberModelLabels = IErunModels(modelToUse,chosenModelsIdxToUse',...
		dataSet,chosenModelsAlphasToUse);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	diff = finalModelLabels == uberModelLabels;
	
	predictions = finalModelLabels;
end

