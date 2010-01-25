function [trainSetCombi,testSetCombi,modelsCombi,holdoutSetCombi ] =...
			IESplitTrainTest(allDataE,allDataI,testset,trainset,...
			holdoutSetE,holdoutSetI,trainLabels,doMethods,modelCount)

	trainsetE    = [];
	testsetE     = [];
	trainsetI    = [];
	testsetI     = [];

	if (doEdge)
		testsetE  = allDataE(testset,:);
		trainsetE = allDataE(trainset,:);
	end
	if (doIntensity)
		testsetI  = allDataI(testset,:);
		trainsetI = allDataI(trainset,:);
	end

	[EModels,IModels] = IEgetModels(doMethods,...
		trainLabels,trainsetE,trainsetI,modelCount);

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

