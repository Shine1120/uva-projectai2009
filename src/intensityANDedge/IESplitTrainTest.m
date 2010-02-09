function [trainSetCombi,testSetCombi,modelsCombi,holdoutSetCombi ] =...
			IESplitTrainTest(allDataE,allDataI,testset,trainset,...
			holdoutSetE,holdoutSetI,trainLabels,doMethods,modelCount)

	%initialize train and test matrix for intensity and edges
	trainsetE    = [];
	testsetE     = [];
	trainsetI    = [];
	testsetI     = [];

	%extraxt train and test set according to method chosen
	if (doEdge)
		testsetE  = allDataE(testset,:);
		trainsetE = allDataE(trainset,:);
	end
	if (doIntensity)
		testsetI  = allDataI(testset,:);
		trainsetI = allDataI(trainset,:);
	end

	% calculate models with train and test set for chosen mthods
	[EModels,IModels] = IEgetModels(doMethods,...
		trainLabels,trainsetE,trainsetI,modelCount);

	%combine models
	if doEdge & doIntensity
		trainSetCombi     = [trainsetE trainsetI];
		testSetCombi      = [testsetE testsetI];
		modelsCombi       = [EModels IModels];
		holdoutSetCombi   = [holdoutSetE holdoutSetI];
	elseif doEdge
		trainSetCombi     = trainsetE;
		testSetCombi      = testsetE;
		modelsCombi       = EModels;
		holdoutSetCombi   = holdoutSetE;
	elseif doIntensity
		trainSetCombi     = trainsetI;
		testSetCombi      = testsetI;
		modelsCombi       = IModels;
		holdoutSetCombi   = holdoutSetI;
	end
end

