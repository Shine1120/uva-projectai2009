function [ output_args ] = IErunAda( )

	close all;

	do5Euro           = 1;
	do10Euro          = 0;

	doWholeNote       = 1;
	doWholeNotePB     = 0;
	doWhitePatchNote  = 0;

	path = '../moneyDivided/';
	if (doWholeNote)
		path      = [path 'whole/'];
	elseif (doWholeNotePB)
		path      = [path 'wholeplusborder/'];
	elseif (doWhitePatchNote)
		path      = [path 'whitepatch/'];
	end
	if (do5Euro)
		path      = [path 'neur05/'];
	elseif (do10Euro)
		path	  = [path 'neur10/'];
	end
	pathFit		  = [path 'fit/'];
	pathUnfit	  = [path 'unfit/'];

	sizeHoldoutSet    = 75;
	leave_n_out		  = 35;	% size of test-set
% 	sizeHoldoutSet    = 100;
% 	leave_n_out		  = 50;	% size of test-set
	repetitions		  = 5;
	trials			  = 20;
	hypotheses 		  = 30;
	
	doEdge			  = 1;
	doIntensity		  = 1;

	doMethods(1)	  = doEdge;
	doMethods(2)	  = doIntensity;

	invariant         = 0;

	cannyThresh 	  = 0.0355;

	useFront		  = 1;
	useRear			  = 1;

	xSegms			  = 5;
	ySegms			  = 12;
	
	modelCount		  = xSegms*ySegms*(useFront+useRear);
	
	allDataE          = [];
	allDataI          = [];
	nrIndxesFit       = 0;
	nrIndxesUnfit     = 0;

    holdoutSetE       = [];
    holdoutSetI       = [];
	
	modelsVotes       = [];
	
	tic
	fprintf('\nconstructing data set...\n')
	if doEdge==1
		allDataFitE      = IEgetDataSet( 'edge', pathFit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms);
		allDataUnfitE    = IEgetDataSet( 'edge', pathUnfit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms);

		allDataE         = [allDataFitE;allDataUnfitE];
		nrIndxesFit      = size(allDataFitE,1);
		nrIndxesUnfit    = size(allDataUnfitE,1);
	end
	if doIntensity==1
		allDataFitI		 = IEgetDataSet( 'Intensity', pathFit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms);
		allDataUnfitI    = IEgetDataSet( 'Intensity', pathUnfit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms);

		allDataI         = [allDataFitI;allDataUnfitI];
		nrIndxesFit      = size(allDataFitI,1);
		nrIndxesUnfit    = size(allDataUnfitI,1);
	end
	toc

	allDataClasses   = [ones(nrIndxesFit,1); zeros(nrIndxesUnfit,1)];
	
	sumTPRate = 0;
	sumTNRate = 0;
	
	overAllBestHOResults = 0;
	
	for r=1:repetitions
		randIndexAll     = randperm(nrIndxesFit+nrIndxesUnfit)';
		randIndexHOAll   = randIndexAll(1:sizeHoldoutSet);
		randIndexTTAll   = randIndexAll(sizeHoldoutSet+1:size(randIndexAll,1));
		
		if (doEdge)
			holdoutSetE     = allDataE(randIndexHOAll,:);
		end
		if (doIntensity)
			holdoutSetI     = allDataI(randIndexHOAll,:);
		end
		
		holdoutSetClasses	= allDataClasses(randIndexHOAll);

		sumModelsOverTrials = zeros(4,modelCount*(doEdge+doIntensity));
		
		for trial=1:trials
			fprintf('repetition %d/%d\t trial %d/%d\n',r,repetitions,trial,trials)
			randIndexTT  = randperm(length(randIndexTTAll));
			testset		 = randIndexTTAll(randIndexTT(1:leave_n_out));
			trainset	 = randIndexTTAll(randIndexTT(leave_n_out+1:end));
			testLabels   = allDataClasses(testset);
			trainLabels  = allDataClasses(trainset);
			
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
			sumModelsOverTrials = sumModelsOverTrials+modelsCombi;

			%%%%%%%%%%%%%%%%%%%%%%%DO ADABOOST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			[bestModels, alpha] = IEAdaboost(trainLabels, hypotheses,...
									trainSetCombi,modelsCombi);
			%%%%%%%%%%%%%%%%%%%%%%TESTING TEST SET%%%%%%%%%%%%%%%%%%%%%%%%%
			[ignore, testTPRate, testTNRate, testGoodClassified] =...
					IErunModels(modelsCombi,bestModels,testSetCombi,...
					testLabels,alpha,ones(size(alpha,2)));
			%%%%%%%%%%%%%%%%%%%FINISHED TESTING TEST SET%%%%%%%%%%%%%%%%%%%
			
			for i=1:length(bestModels(:,1))
				if bestModels(i,1)> size(modelsVotes,2) 
					modelsVotes(1,bestModels(i,1)) = (length(bestModels(:,1))+1-i);
					modelsVotes(2,bestModels(i,1)) = 1;
					modelsVotes(3,bestModels(i,1)) = bestModels(i,2);	 %alpha
					modelsVotes(4,bestModels(i,1)) = testGoodClassified; %goodClassified
					modelsVotes(5,bestModels(i,1)) = bestModels(i,1);	 %idx
				elseif numel(modelsVotes(:,bestModels(i,1)))<4
					modelsVotes(1,bestModels(i,1)) = (length(bestModels(:,1))+1-i);
					modelsVotes(2,bestModels(i,1)) = 1;
					modelsVotes(3,bestModels(i,1)) = bestModels(i,2);	 %alpha
					modelsVotes(4,bestModels(i,1)) = testGoodClassified; %goodClassified
					modelsVotes(5,bestModels(i,1)) = bestModels(i,1);	 %idx
				else
					modelsVotes(1,bestModels(i,1)) =...
						modelsVotes(1,bestModels(i,1)) +...
						(length(bestModels(:,1))+1-i);
					modelsVotes(2,bestModels(i,1)) =...
						modelsVotes(2,bestModels(i,1)) + 1;
					modelsVotes(3,bestModels(i,1)) =...
						modelsVotes(3,bestModels(i,1)) + bestModels(i,2);
					%not all indexes are in here when the algo gets here...
					modelsVotes(4,bestModels(i,1)) =...
						modelsVotes(4,bestModels(i,1)) + testGoodClassified; %error
					modelsVotes(5,bestModels(i,1)) =...
						bestModels(i,1); %idx
				end
			end
		end %trials

		averageModelsOverTrials = sumModelsOverTrials./trials;
		
		%sort:
		% modelsVotes(1,:) stores a sum of the weighted occurence in the
		% chosen model list (chosen by adaboost). If an item is on the first
		% place in a list it gets weight of the size of the list. 
		% If it is last it gets one. modelsVotes(2,:) is a sum of the 
		% occurences of a model in the chosen models (by adaboost)
		[ignore modelsHighestVotesIds] = sort(modelsVotes(4,:),'descend');
		chosenModelsAlphas = modelsVotes(3,modelsHighestVotesIds(1:hypotheses))./...
			modelsVotes(2,modelsHighestVotesIds(1:hypotheses));
		averageGoodClassified = modelsVotes(4,modelsHighestVotesIds(1:hypotheses))./...
			modelsVotes(2,modelsHighestVotesIds(1:hypotheses));
		chosenModelsIdx    = modelsVotes(5,modelsHighestVotesIds(1:hypotheses));

		%%%%%%%%%%%%%%%%%%%%%%%TESTING HOLDOUT SET%%%%%%%%%%%%%%%%%%%%%%%%%
		
		[WinnerModels, HOTPRate, HOTNRate, HOGoodClassified] =...
				IErunModels(averageModelsOverTrials,chosenModelsIdx',...
				holdoutSetCombi,holdoutSetClasses,chosenModelsAlphas,...
				averageGoodClassified);

		sumTPRate	 = sumTPRate + HOTPRate;
		sumTNRate	 = sumTNRate + HOTNRate;
			
		fprintf('HOResults::  fitGood: %4.4g \t unfitGood: %4.4g \t-->  error: %4.4g\n',...
			HOTPRate,HOTNRate,1-HOGoodClassified)
		
		if HOGoodClassified > overAllBestHOResults 
			overallBestModels  = WinnerModels;
			overallBestIndexes = chosenModelsIdx;
		end
		%%%%%%%%%%%%%%%%%%%FINISHED TESTING HOLDOUT SET%%%%%%%%%%%%%%%%%%%%
	end %repetitions

	%%%%%%%%%%%%%%%%%%%%%%RUNNING MODELS FOR PLOT %%%%%%%%%%%%%%%%%%%%%%%%%

	sumLabels = zeros(sizeHoldoutSet,1);
	
	for modelNr=1:size(overallBestModels,2)
		modelToUse				   = overallBestModels(:,1:modelNr);
		chosenModelsAlphasToUse	   = chosenModelsAlphas(1:modelNr);
		averageGoodClassifiedToUse = averageGoodClassified(1:modelNr);
		chosenModelsIdxToUse	   = chosenModelsIdx(1:modelNr);

		for bestModel=1:size(modelToUse,2)
			BMlabels =...
				IEgetLabelsByGauss(holdoutSetCombi(:,chosenModelsIdxToUse(bestModel)),...
				modelToUse(:,bestModel));
			mask = BMlabels==0;
			BMlabels(mask) = -1;
			sumLabels = sumLabels +...
				(BMlabels.*chosenModelsAlphasToUse(bestModel).*...
				averageGoodClassifiedToUse(bestModel));
		end

		resultLabels		= sign(sumLabels);
		mask				= resultLabels<=0;
		resultLabels(mask)  = 0;

		fitHO				= holdoutSetClasses==1;
		unfitHO				= holdoutSetClasses==0;

		fitResults			= resultLabels(fitHO);
		unfitResults		= resultLabels(unfitHO);

		TP		= fitResults==1;
		TPRate	= sum(TP)/size(TP,1);
		TN		= unfitResults==0;
		TNRate	= sum(TN)/size(TN,1);

		GoodClassified(modelNr,1) = modelNr;
		GoodClassified(modelNr,2) = (sum(TP)+sum(TN))/(size(TP,1)+size(TN,1));
		GoodClassified(modelNr,3) = TPRate;
		GoodClassified(modelNr,4) = TNRate;
	end
	%%%%%%%%%%%%%%%%%%%FINISHED RUNNING MODELS FOR PLOT %%%%%%%%%%%%%%%%%%%

	figure(1)
	plot(GoodClassified(:,1),GoodClassified(:,2),'b',...
		 GoodClassified(:,1),GoodClassified(:,3),'r',...
		 GoodClassified(:,1),GoodClassified(:,4),'g')
	legend('overall','good fit','good unfit',3,'location','SouthEast');
	xlabel('weak classifiers used')
	ylabel('good classification rate')
	title('results good classified')

	fprintf('\n\nresults for %d repetitions:\n',repetitions)
	fprintf('fit right:   \t%4.4g%%\n',(sumTPRate/(repetitions))*100)
	fprintf('fit wrong:   \t%4.4g%%\n',(1-(sumTPRate/(repetitions)))*100)
	fprintf('unfit right: \t%4.4g%%\n',(sumTNRate/(repetitions))*100)
	fprintf('unfit wrong: \t%4.4g%%\n',(1-(sumTNRate/(repetitions)))*100)
	
	numberOfMethods = doEdge + doIntensity;
	overallBestIndexes
	IEshowAreasOnBill( xSegms, ySegms,...
	useFront,useRear,numberOfMethods,overallBestIndexes)

%	save(fileName matrix)
end

function p = randperm(n)
    [ignore,p] = sort(rand(1,n));
end