function [ output_args ] = IErunAda( )

	close all;

	do5Euro           = 0;
	do10Euro          = 1;

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
	repetitions		  = 40;
	trials			  = 40;
	hypotheses 		  = 40;
	
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
	
	overlap			  = 1;
	
	modelCount		  = xSegms*ySegms*(useFront+useRear);
	if (overlap)
		modelCount	  = ((xSegms*2)-1)*((ySegms*2)-1)*(useFront+useRear);
	end
	
	allDataE          = [];
	allDataI          = [];
	nrIndxesFit       = 0;
	nrIndxesUnfit     = 0;

    holdoutSetE       = [];
    holdoutSetI       = [];
	
	modelsVotes       = zeros(5,modelCount*(doEdge+doIntensity));
	finalModels		  = zeros(7,modelCount*(doEdge+doIntensity));
	uberModels		  = zeros(7,modelCount*(doEdge+doIntensity));
	
	plotData1 = zeros(hypotheses,4);
	plotData2 = zeros(hypotheses,4);
	
	fprintf('\nconstructing data set...\n')
	tic
	if doEdge==1
		allDataFitE      = IEgetDataSet( 'edge', pathFit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms,overlap);
		allDataUnfitE    = IEgetDataSet( 'edge', pathUnfit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms,overlap);

		allDataE         = [allDataFitE;allDataUnfitE];
		nrIndxesFit      = size(allDataFitE,1);
		nrIndxesUnfit    = size(allDataUnfitE,1);
	end
	if doIntensity==1
		allDataFitI		 = IEgetDataSet( 'Intensity', pathFit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms,overlap);
		allDataUnfitI    = IEgetDataSet( 'Intensity', pathUnfit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms,overlap);

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
	
		
		if r==1
			%just to fill up in case no run is under 5% unfit error
			uberModels = IEupdateBestModels(uberModels,modelsCombi,...
				chosenModelsIdx,chosenModelsAlphas);		
		end
		if HOTNRate > 0.95
			%if unfit error is smaller then 5%
			if HOTPRate>overAllBestHOFitGoodClass
				%if fit error is smaller then smallest until now
				fprintf('new uber model\n')
				%if unfit good classified is better then current best results,
				%clear uberModels and update it with the newest model
				uberModels  = zeros(7,modelCount*(doEdge+doIntensity));
				uberModels  = IEupdateBestModels(uberModels,modelsCombi,...
					chosenModelsIdx,chosenModelsAlphas);
				overAllBestHOFitGoodClass = HOTPRate;
			elseif HOTPRate==overAllBestHOFitGoodClass
				%if fit error is smaller then smallest until now
				fprintf('uber model updated\n')
				%if unfit good classified is better then current best results,
				%clear uberModels and update it with the newest model
				uberModels  = IEupdateBestModels(uberModels,modelsCombi,...
					chosenModelsIdx,chosenModelsAlphas);
			end
		end
		%%%%%%%%%%%%%%%%%%%FINISHED TESTING HOLDOUT SET%%%%%%%%%%%%%%%%%%%%
		
		toc
		
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

		for modelNr=1:hypotheses
			modelToUse				= finalModelsToUse(3:6,1:modelNr);
			chosenModelsAlphasToUse	= finalModelsToUse(2,1:modelNr);
			chosenModelsIdxToUse	= finalModelsSortedIdxs(1:modelNr);

			[ignore, PlotTPRate1 PlotTNRate1, PlotGoodClassified1] =...
					IErunModels(modelToUse,chosenModelsIdxToUse',...
					holdoutSetCombi,holdoutSetClasses,chosenModelsAlphasToUse,1);		

			%goodClassified now holds the errors
			plotData1(modelNr,1) = modelNr;
			plotData1(modelNr,2) = plotData1(modelNr,2)+(1-PlotGoodClassified1);
			plotData1(modelNr,3) = plotData1(modelNr,3)+(1-PlotTPRate1);
			plotData1(modelNr,4) = plotData1(modelNr,4)+(1-PlotTNRate1);
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

		for modelNr=1:hypotheses

			modelToUse				= uberModelsToUse(3:6,1:modelNr);
			chosenModelsAlphasToUse	= uberModelsToUse(2,1:modelNr);
			chosenModelsIdxToUse	= uberModelsSortedIdxs(1:modelNr);

			[ignore, PlotTPRate2, PlotTNRate2, PlotGoodClassified2] =...
					IErunModels(modelToUse,chosenModelsIdxToUse',...
					holdoutSetCombi,holdoutSetClasses,chosenModelsAlphasToUse,1);		

			%goodClassified now holds the errors
			plotData2(modelNr,1) = modelNr;
			plotData2(modelNr,2) = plotData2(modelNr,2)+(1-PlotGoodClassified2);
			plotData2(modelNr,3) = plotData2(modelNr,3)+(1-PlotTPRate2);
			plotData2(modelNr,4) = plotData2(modelNr,4)+(1-PlotTNRate2);
		end
	%%%%%%%%%%%%%%%%%%%FINISHED RUNNING MODELS FOR PLOT %%%%%%%%%%%%%%%%%%%		
	end %repetitions
	
	plotData1(:,2) = plotData1(:,2)./repetitions;
	plotData1(:,3) = plotData1(:,3)./repetitions;
	plotData1(:,4) = plotData1(:,4)./repetitions;

	plotData2(:,2) = plotData2(:,2)./repetitions;
	plotData2(:,3) = plotData2(:,3)./repetitions;
	plotData2(:,4) = plotData2(:,4)./repetitions;

	figure
	plot(plotData1(:,1),plotData1(:,2),'b',...
		 plotData1(:,1),plotData1(:,3),'r',...
		 plotData1(:,1),plotData1(:,4),'g')
	legend('overall error','fit error','unfit error',3,'location','SouthEast');
	xlabel('weak classifiers used')
	ylabel('classification error')
	title('results classification error model1 (overall best)')

	IEshowAreasOnBill( xSegms, ySegms,useFront,useRear,...
		finalModelsToUse(7,:),do5Euro,do10Euro, 'best overall models',overlap)

	figure
	plot(plotData2(:,1),plotData2(:,2),'b',...
		 plotData2(:,1),plotData2(:,3),'r',...
		 plotData2(:,1),plotData2(:,4),'g')
	legend('overall error','fit error','unfit error',3,'location','SouthEast');
	xlabel('weak classifiers used')
	ylabel('classification error')
	title('results classification error model2 (best fit, unfit<5)')

	IEshowAreasOnBill( xSegms, ySegms,useFront,useRear,...
		uberModelsToUse(7,:),do5Euro,do10Euro, 'bestUnfit models',overlap)

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