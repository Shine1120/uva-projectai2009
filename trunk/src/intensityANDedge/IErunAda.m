function [ output_args ] = IErunAda( )

	close all;

	do5Euro           = 1;
	do10Euro          = 0;

	doWholeNote       = 0;
	doWholeNotePB     = 1;
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
	repetitions		  = 10;
	trials			  = 50;
	hypotheses 		  = 25;
	
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
	
	modelsVotes       = zeros(5,modelCount*(doEdge+doIntensity));
	finalModels		  = zeros(7,modelCount*(doEdge+doIntensity));
	uberModels		  = zeros(7,modelCount*(doEdge+doIntensity));
	
	fprintf('\nconstructing data set...\n')
	tic
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
	overAllBestHOFitGoodClass = 0;
	overAllBestHOUnfitGoodClass = 0;
	
	for r=1:repetitions
		tic
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
			[ignore, ignore, ignore, testGoodClassified] =...
					IErunModels(modelsCombi,bestModels,testSetCombi,...
					testLabels,alpha,0);
			%%%%%%%%%%%%%%%%%%%FINISHED TESTING TEST SET%%%%%%%%%%%%%%%%%%%
			
			modelsVotes = IEupdateModelVotes(modelsVotes,...
								bestModels,testGoodClassified);

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
% 		averageGoodClassified = modelsVotes(4,modelsHighestVotesIds(1:hypotheses))./...
% 								modelsVotes(2,modelsHighestVotesIds(1:hypotheses));
		chosenModelsIdx    = modelsVotes(5,modelsHighestVotesIds(1:hypotheses));

		%%%%%%%%%%%%%%%%%%%%%%%TESTING HOLDOUT SET%%%%%%%%%%%%%%%%%%%%%%%%%
		
		[WinnerModels, HOTPRate, HOTNRate, HOGoodClassified] =...
				IErunModels(averageModelsOverTrials,chosenModelsIdx',...
				holdoutSetCombi,holdoutSetClasses,chosenModelsAlphas,0);

		sumTPRate	 = sumTPRate + HOTPRate;
		sumTNRate	 = sumTNRate + HOTNRate;
			
		fprintf('HOResults::  fitGood: %4.4g \t unfitGood: %4.4g \t-->  error: %4.4g\n',...
			HOTPRate,HOTNRate,1-HOGoodClassified)
		
		if HOGoodClassified > overAllBestHOResults 
			fprintf('new overall Model\n')
			overAllBestHOResults = HOGoodClassified;
			%reinitialize bestmodel list
			finalModels = zeros(7,modelCount*(doEdge+doIntensity));
			finalModels = IEupdateBestModels(finalModels,modelsCombi,...
				chosenModelsIdx,chosenModelsAlphas);
		elseif HOGoodClassified == overAllBestHOResults 
			fprintf('overall Models updated\n')
			%update bestModel list
			finalModels = IEupdateBestModels(finalModels,modelsCombi,...
				chosenModelsIdx,chosenModelsAlphas);
		end
		
		if HOTNRate > overAllBestHOUnfitGoodClass
			fprintf('new uber model\n')
			%if unfit good classified is better then current best results,
			%clear uberModels and update it with the newest model
			overAllBestHOUnfitGoodClass = HOTNRate;
			overAllBestHOFitGoodClass   = HOTPRate;
			uberModels = zeros(7,modelCount*(doEdge+doIntensity));
			uberModels = IEupdateBestModels(uberModels,modelsCombi,...
				chosenModelsIdx,chosenModelsAlphas);
		elseif HOTNRate == overAllBestHOUnfitGoodClass
			%if unfit good classified is as good as the current one
			%check if fit bills are classified better then the current best
			%results. If so, clear uberModel and reinitialize it with
			%current model
			
			if HOTPRate > overAllBestHOFitGoodClass
				fprintf('new uber model\n')
				overAllBestHOFitGoodClass = HOTPRate;
				uberModels = zeros(7,modelCount*(doEdge+doIntensity));
				uberModels = IEupdateBestModels(uberModels,modelsCombi,...
					chosenModelsIdx,chosenModelsAlphas);
			elseif HOTPRate == overAllBestHOFitGoodClass
				fprintf('uber models updated\n')
				%if unfit and fit bills are classified as good ad the
				%current best model, update uberModel with the corrent
				%model (to average on it later on)
				uberModels = IEupdateBestModels(uberModels,modelsCombi,...
					chosenModelsIdx,chosenModelsAlphas);
			end
		end
		%%%%%%%%%%%%%%%%%%%FINISHED TESTING HOLDOUT SET%%%%%%%%%%%%%%%%%%%%
		toc
	end %repetitions
	
	%%%%%%%%%%%%%%%%%%%%%%RUNNING MODELS FOR PLOT %%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%RUNNING finalModels %%%%%%%%%%%%%%%%%%%%%%%%%
	finalModels(2,:) = finalModels(2,:)./finalModels(1,:);
	finalModels(3,:) = finalModels(3,:)./finalModels(1,:);
	finalModels(4,:) = finalModels(4,:)./finalModels(1,:);
	finalModels(5,:) = finalModels(5,:)./finalModels(1,:);
	finalModels(6,:) = finalModels(6,:)./finalModels(1,:);

	finalModelsMask			     = isnan(finalModels);
	finalModels(finalModelsMask) = 0;

	[ignore finalModelsSortedIdxs] = sort(finalModels(2,:),'descend');
	finalModelsToUse = finalModels(:,finalModelsSortedIdxs(1:hypotheses));
	
	GoodClassified1 = zeros(size(finalModelsToUse,2),4);
	for modelNr=1:size(finalModelsToUse,2)
		modelToUse				= finalModelsToUse(3:6,1:modelNr);
		chosenModelsAlphasToUse	= finalModelsToUse(2,1:modelNr);
		chosenModelsIdxToUse	= finalModelsSortedIdxs(1:modelNr);

		[ignore, PlotTPRate1 PlotTNRate1, PlotGoodClassified1] =...
				IErunModels(modelToUse,chosenModelsIdxToUse',...
				holdoutSetCombi,holdoutSetClasses,chosenModelsAlphasToUse,1);		

		GoodClassified1(modelNr,1) = modelNr;
		GoodClassified1(modelNr,2) = PlotGoodClassified1;
		GoodClassified1(modelNr,3) = PlotTPRate1;
		GoodClassified1(modelNr,4) = PlotTNRate1;
	end

	%%%%%%%%%%%%%%%%%%%%%%RUNNING uberModels %%%%%%%%%%%%%%%%%%%%%%%%%
	uberModels(2,:)  = uberModels(2,:)./uberModels(1,:);
	uberModels(3,:)  = uberModels(3,:)./uberModels(1,:);
	uberModels(4,:)  = uberModels(4,:)./uberModels(1,:);
	uberModels(5,:)  = uberModels(5,:)./uberModels(1,:);
	uberModels(6,:)  = uberModels(6,:)./uberModels(1,:);

	uberModelsMask			   = isnan(uberModels);
	uberModels(uberModelsMask) = 0;

	[ignore uberModelsSortedIdxs] = sort(uberModels(2,:),'descend');
	uberModelsToUse = uberModels(:,uberModelsSortedIdxs(1:hypotheses));
	
	GoodClassified2 = zeros(size(uberModelsToUse,2),4);
	for modelNr=1:size(uberModelsToUse,2)
		
		modelToUse				= uberModelsToUse(3:6,1:modelNr);
		chosenModelsAlphasToUse	= uberModelsToUse(2,1:modelNr);
		chosenModelsIdxToUse	= uberModelsSortedIdxs(1:modelNr);
		
		[ignore, PlotTPRate2, PlotTNRate2, PlotGoodClassified2] =...
				IErunModels(modelToUse,chosenModelsIdxToUse',...
				holdoutSetCombi,holdoutSetClasses,chosenModelsAlphasToUse,1);		

		GoodClassified2(modelNr,1) = modelNr;
		GoodClassified2(modelNr,2) = PlotGoodClassified2;
		GoodClassified2(modelNr,3) = PlotTPRate2;
		GoodClassified2(modelNr,4) = PlotTNRate2;
	end
	%%%%%%%%%%%%%%%%%%%FINISHED RUNNING MODELS FOR PLOT %%%%%%%%%%%%%%%%%%%

	figure
	plot(GoodClassified1(:,1),GoodClassified1(:,2),'b',...
		 GoodClassified1(:,1),GoodClassified1(:,3),'r',...
		 GoodClassified1(:,1),GoodClassified1(:,4),'g')
	legend('overall','good fit','good unfit',3,'location','SouthEast');
	xlabel('weak classifiers used')
	ylabel('good classification rate')
	title('results good classified')

	IEshowAreasOnBill( xSegms, ySegms,useFront,useRear,...
		finalModelsToUse(7,:),do5Euro,do10Euro, 'best overall models')

	figure
	plot(GoodClassified2(:,1),GoodClassified2(:,2),'b',...
		 GoodClassified2(:,1),GoodClassified2(:,3),'r',...
		 GoodClassified2(:,1),GoodClassified2(:,4),'g')
	legend('overall','good fit','good unfit',3,'location','SouthEast');
	xlabel('weak classifiers used')
	ylabel('good classification rate')
	title('results uber models')

	IEshowAreasOnBill( xSegms, ySegms,useFront,useRear,...
		uberModelsToUse(7,:),do5Euro,do10Euro, 'bestUnfit models')

	fprintf('\n\nresults for %d repetitions:\n',repetitions)
	fprintf('fit right:   \t%4.4g%%\n',(sumTPRate/(repetitions))*100)
	fprintf('fit wrong:   \t%4.4g%%\n',(1-(sumTPRate/(repetitions)))*100)
	fprintf('unfit right: \t%4.4g%%\n',(sumTNRate/(repetitions))*100)
	fprintf('unfit wrong: \t%4.4g%%\n',(1-(sumTNRate/(repetitions)))*100)
	
	
	save resultModels.mat finalModelsToUse
	save uberModels.mat uberModelsToUse
end

function p = randperm(n)
    [ignore,p] = sort(rand(1,n));
end