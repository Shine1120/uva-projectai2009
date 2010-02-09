% this function starts the intensity & edges learning.

% Remark: During learning fit bills have labels 1 and unfit bills have
% label 0. This is different from the combined phase where the labels are 
% the other way around. This does not influence the models learned.


function start( )

	close all;

	%select on what bills to learn
	do5Euro           = 0;
	do10Euro          = 1;

	%select on what area of bill to learn on
	doWhitePatchNote  = 0; % white patch
	doWholeNote       = 0; % whole bill
	doWholeNotePB     = 1; % whole bill plus border

	%select what side of the bill to learn on
	useFront		  = 1;
	useRear			  = 1;

	%select what method to use
	doEdge			  = 1;
	doIntensity		  = 1;
	doMethods(1)	  = doEdge;
	doMethods(2)	  = doIntensity;
	

	%path to images is constructed
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

	
	sizeValidationSet = 75; % size of validation set
	leave_n_out		  = 35;	% size of test set

	repetitions		  = 10; %number of repetitions of the test
	trials			  = 40; %number of Repeated random sub-sampling validation 
	hypotheses 		  = 20; %weak classifiers to be learned by adaBoost

	%if invariant set to one. The mean intensity of each bill will be
	%subtracted from the intensities of that bill
	invariant         = 0;

	%is used as threshold in canny edge detection
	cannyThresh 	  = 0.0355;

	%define number of segments to split the bill in
	xSegms			  = 3;
	ySegms			  = 7;
	%select if areas should overlap.
	%if overlap is set to 1 the overlapping segments will be added to the
	%xSegms and ySegms defined above.
	overlap			  = 1;
	
	%calculate number of models that will be handled
	modelCount		  = xSegms*ySegms*(useFront+useRear);
	if (overlap)
		modelCount	  = ((xSegms*2)-1)*((ySegms*2)-1)*(useFront+useRear);
	end

	%initialization of variables and lists to be used
	allDataE          = [];
	allDataI          = [];
	nrIndxesFit       = 0;
	nrIndxesUnfit     = 0;

    validationSetE       = [];
    validationSetI       = [];
	
	modelsVotes       = zeros(5,modelCount*(doEdge+doIntensity));
	finalModels		  = zeros(7,modelCount*(doEdge+doIntensity));
	
	plotData = zeros(hypotheses,4);
	
	fprintf('\nconstructing data set...\n')
	tic
	if doEdge==1
		% learning should be done on edges
		%get edge data of fit images
		allDataFitE      = IEgetDataSet( 'edge', pathFit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms,overlap);
		%get edge data of unfit images
		allDataUnfitE    = IEgetDataSet( 'edge', pathUnfit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms,overlap);

		%put the fit and unfit data under each other in one matrix
		allDataE         = [allDataFitE;allDataUnfitE];
		%remember number of fit items
		nrIndxesFit      = size(allDataFitE,1);
		%remember number of fit items
		nrIndxesUnfit    = size(allDataUnfitE,1);
	end
	if doIntensity==1
		%same as for edges (above)
		allDataFitI		 = IEgetDataSet( 'Intensity', pathFit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms,overlap);
		allDataUnfitI    = IEgetDataSet( 'Intensity', pathUnfit,cannyThresh,...
						   useFront, useRear, invariant,xSegms, ySegms,overlap);

		allDataI         = [allDataFitI;allDataUnfitI];
		nrIndxesFit      = size(allDataFitI,1);
		nrIndxesUnfit    = size(allDataUnfitI,1);
	end
	toc

	%construct groundtruth labels
	allDataClasses   = [ones(nrIndxesFit,1); zeros(nrIndxesUnfit,1)];
	
	% initialize  variables
	sumTPRate = 0;
	sumTNRate = 0;
	
	overAllBestHOFitGoodClass = 0;
	
	for r=1:repetitions
		tic
		%split data in train-test set and validation set
		randIndexAll    = randperm(nrIndxesFit+nrIndxesUnfit)';
		randIndexValAll = randIndexAll(1:sizeValidationSet);
		randIndexTTAll  = randIndexAll(sizeValidationSet+1:size(randIndexAll,1));
		
		%extract validation set
		if (doEdge)
			validationSetE   = allDataE(randIndexValAll,:);
		end
		if (doIntensity)
			validationSetI   = allDataI(randIndexValAll,:);
		end
		
		%get the groundtruth labels for validation set
		validationSetClasses = allDataClasses(randIndexValAll);

		sumModelsOverTrials  = zeros(4,modelCount*(doEdge+doIntensity));
		
		for trial=1:trials
			fprintf('repetition %d/%d\t trial %d/%d\n',r,repetitions,trial,trials)
			%split train and test set (split labels)
			randIndexTT  = randperm(length(randIndexTTAll));
			testset		 = randIndexTTAll(randIndexTT(1:leave_n_out));
			trainset	 = randIndexTTAll(randIndexTT(leave_n_out+1:end));
			testLabels   = allDataClasses(testset);
			trainLabels  = allDataClasses(trainset);
			
			%initialize lists to hold test and train set
			trainsetE    = [];
			testsetE     = [];
			trainsetI    = [];
			testsetI     = [];
			
			%get test and train set according splited labels
			if (doEdge)
				testsetE  = allDataE(testset,:);
				trainsetE = allDataE(trainset,:);
			end
			if (doIntensity)
				testsetI  = allDataI(testset,:);
				trainsetI = allDataI(trainset,:);
			end

			%calculate models from the train data
			[EModels,IModels] = IEgetModels(doMethods,...
				trainLabels,trainsetE,trainsetI,modelCount);

			%combine intensity and edges sets according to requested
			%methods to use (defined at the top)
			if doEdge && doIntensity
				trainSetCombi     = [trainsetE trainsetI];
				testSetCombi      = [testsetE testsetI];
				modelsCombi       = [EModels IModels];
				validationSetCombi   = [validationSetE validationSetI];
			elseif doEdge
				trainSetCombi     = trainsetE;
				testSetCombi      = testsetE;
				modelsCombi       = EModels;
				validationSetCombi   = validationSetE;
			elseif doIntensity
				trainSetCombi     = trainsetI;
				testSetCombi      = testsetI;
				modelsCombi       = IModels;
				validationSetCombi   = validationSetI;
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
			
			%updates the models returned by adaboost according to test
			%results
			modelsVotes = IEupdateModelVotes(modelsVotes,...
								bestModels,testGoodClassified);
		end %trials

		averageModelsOverTrials = sumModelsOverTrials./trials;
		
		%sort:
		%modelsVotes(1,:) stores a sum of the weighted occurence in the
		% chosen model list (chosen by adaboost). If an item is on the first
		% place in a list it gets weight of the size of the list. 
		% If it is last it gets one. 
		%modelsVotes(2,:) is a sum of the occurences of a model in the 
		% chosen models (by adaboost), one point for every occurence.
		%modelsVotes(3,:) stores the sum of the alphas assigned by adaboost
		%modelsVotes(4,:) stores the good classified rate
		[ignore modelsHighestVotesIds] = sort(modelsVotes(4,:),'descend');

		% select the best models. Number of models selected is the number
		% of hypotheses.
		chosenModelsAlphas = modelsVotes(3,modelsHighestVotesIds(1:hypotheses))./...
							 modelsVotes(2,modelsHighestVotesIds(1:hypotheses));
		chosenModelsIdx    = modelsVotes(5,modelsHighestVotesIds(1:hypotheses));

		%%%%%%%%%%%%%%%%%%%%%TESTING VALIDATION SET%%%%%%%%%%%%%%%%%%%%%%%%
		
		%run selected best models on the validation set
		[ignore, ValTPRate, ValTNRate, ValGoodClassified] =...
				IErunModels(averageModelsOverTrials,chosenModelsIdx',...
				validationSetCombi,validationSetClasses,chosenModelsAlphas,0);

		sumTPRate	 = sumTPRate + ValTPRate;
		sumTNRate	 = sumTNRate + ValTNRate;
			
		fprintf('HOResults::  fitGood: %4.4g \t unfitGood: %4.4g \t-->  error: %4.4g\n',...
			ValTPRate,ValTNRate,1-ValGoodClassified)
	
		if r==1
			%just to fill up in case no run is under 5% unfit error
			finalModels = IEupdateBestModels(finalModels,modelsCombi,...
				chosenModelsIdx,chosenModelsAlphas);		
		end
		if ValTNRate > 0.95
			%if unfit error is smaller then 5%
			if ValTPRate>overAllBestHOFitGoodClass
				%if fit error is smaller then smallest until now
				fprintf('new model\n')
				%if unfit good classified is better then current best results,
				%clear finalModels and update it with the newest model
				finalModels  = zeros(7,modelCount*(doEdge+doIntensity));
				finalModels  = IEupdateBestModels(finalModels,modelsCombi,...
					chosenModelsIdx,chosenModelsAlphas);
				overAllBestHOFitGoodClass = ValTPRate;
			elseif ValTPRate==overAllBestHOFitGoodClass
				%if fit error is smaller then smallest until now
				fprintf('model updated\n')
				%if unfit good classified is better then current best results,
				%clear finalModels and update it with the newest model
				finalModels  = IEupdateBestModels(finalModels,modelsCombi,...
					chosenModelsIdx,chosenModelsAlphas);
			end
		end
		%%%%%%%%%%%%%%%%%%%FINISHED TESTING VALIDATION SET%%%%%%%%%%%%%%%%%
		toc
		
		%%%%%%%%%%%%%%%%%%%%%%RUNNING MODELS FOR PLOT %%%%%%%%%%%%%%%%%%%%%
		% Every repetition the models are tested on the validation set to
		% see how good the n first models work. n=1:hypotheses
		% this is at the end averaged and plotted
		%%%%%%%%%%%%%%%%%%%%%%RUNNING finalModels %%%%%%%%%%%%%%%%%%%%%%%%%
		
		% average the final models by the number of times they were updated
		finalModels(2,:) = finalModels(2,:)./finalModels(1,:);
		finalModels(3,:) = finalModels(3,:)./finalModels(1,:);
		finalModels(4,:) = finalModels(4,:)./finalModels(1,:);
		finalModels(5,:) = finalModels(5,:)./finalModels(1,:);
		finalModels(6,:) = finalModels(6,:)./finalModels(1,:);

		%filter out NaN values, make them 0
		finalModelsMask			     = isnan(finalModels);
		finalModels(finalModelsMask) = 0;

		%order the final models by the alphas Adaboost assigned to them
		[ignore finalModelsSortedIdxs] = sort(finalModels(2,:),'descend');
		finalModelsToUse = finalModels(:,finalModelsSortedIdxs(1:hypotheses));

		for modelNr=1:hypotheses
			%get error for the first n models (n=1:number of hypotheses)
			modelToUse				= finalModelsToUse(3:6,1:modelNr);
			chosenModelsAlphasToUse	= finalModelsToUse(2,1:modelNr);
			chosenModelsIdxToUse	= finalModelsSortedIdxs(1:modelNr);

			[ignore, PlotTPRate PlotTNRate, PlotGoodClassified] =...
					IErunModels(modelToUse,chosenModelsIdxToUse',...
					validationSetCombi,validationSetClasses,chosenModelsAlphasToUse,1);		

			%Update the plotData with the error generated using the first n
			%models
			plotData(modelNr,1) = modelNr;
			plotData(modelNr,2) = plotData(modelNr,2)+(1-PlotGoodClassified);
			plotData(modelNr,3) = plotData(modelNr,3)+(1-PlotTPRate);
			plotData(modelNr,4) = plotData(modelNr,4)+(1-PlotTNRate);
		end

	%%%%%%%%%%%%%%%%%%%FINISHED RUNNING MODELS FOR PLOT %%%%%%%%%%%%%%%%%%%		
	end %repetitions
	
	%average plotData
	plotData(:,2) = plotData(:,2)./repetitions;
	plotData(:,3) = plotData(:,3)./repetitions;
	plotData(:,4) = plotData(:,4)./repetitions;

	%plot the errors
	figure
	plot(plotData(:,1),plotData(:,2),'b',...
		 plotData(:,1),plotData(:,3),'r',...
		 plotData(:,1),plotData(:,4),'g')
	legend('overall error','fit error','unfit error',3,'location','SouthEast');
	xlabel('weak classifiers used')
	ylabel('classification error')
	title('results classification error')

	%show used segments on the bill
	IEshowAreasOnBill( xSegms, ySegms,useFront,useRear,...
		finalModelsToUse(7,:),do5Euro,do10Euro, 'best models',overlap)

	fprintf('\n\nresults for %d repetitions:\n',repetitions)
	fprintf('fit right:   \t%4.4g%%\n',(sumTPRate/(repetitions))*100)
	fprintf('fit wrong:   \t%4.4g%%\n',(1-(sumTPRate/(repetitions)))*100)
	fprintf('unfit right: \t%4.4g%%\n',(sumTNRate/(repetitions))*100)
	fprintf('unfit wrong: \t%4.4g%%\n',(1-(sumTNRate/(repetitions)))*100)
	
	%save models
	save finalModels.mat finalModelsToUse
end

%on some computers randperm does not work, so just in case it is defined
%here:
function p = randperm(n)
    [ignore,p] = sort(rand(1,n));
end