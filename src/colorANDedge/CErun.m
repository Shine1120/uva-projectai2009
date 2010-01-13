function [ percFitGood, percUnfitGood,allDataFitE,...
	allDataFitC,allDataFitCofE,allDataUnfitE,allDataUnfitC,...
	allDataUnfitCofE,nrIndxesFit,nrIndxesUnfit ] = CErun( allDataFitE,...
	allDataFitC,allDataFitCofE,allDataUnfitE,allDataUnfitC,...
	allDataUnfitCofE,nrIndxesFit,nrIndxesUnfit,dataKnown )

  close all

  %windows
	pathFit = '..\money\wholeplusborder\neur10\fit\';
	pathUnfit = '..\money\wholeplusborder\neur10\unfit\';

% 	pathFit = '..\money\whitepatch\neur10\fit\';
% 	pathUnfit = '..\money\whitepatch\neur10\unfit\';
% 
% 	pathFit = '..\money\whole\neur05\fit\';
% 	pathUnfit = '..\money\whole\neur05\unfit\';
% 
% 	linux
% 	pathFit = '../money/wholeplusborder/neur10/fit/';
% 	pathUnfit = '../money/wholeplusborder/neur10/unfit/';
% 
% 	pathFit = '../money/whole/neur05/fit/';
% 	pathUnfit = '../money/whole/neur05/unfit/';
% 
% 	pathFit = '../money/whitepatch/neur10/fit/';
% 	pathUnfit = '../money/whitepatch/neur10/unfit/';

	sizeHoldoutSetFit = round(rand(1)*98)+1;
	sizeHoldoutSetUnfit = 100-sizeHoldoutSetFit;

	numberOfFolds = 10;

	doEdge=1;
	doColor=1;
	doColorOfEdge=0;
	
	cannyThresh=0.0355;

	useFront=1;
	useRear=1;

	% doPlot = 0: no plot
	% doPlot = 1: plots histogram of trainingdata
	% doPlot = 2: plots also all the testData (1 plot per iteration)
	doPlot=1;

	histBins = 25;
	histogramSumFitE      = zeros(histBins,1);
	histogramSumUnfitE    = zeros(histBins,1);
	histogramSumFitC      = zeros(histBins,1);
	histogramSumUnfitC    = zeros(histBins,1);
	histogramSumFitCofE   = zeros(histBins,1);
	histogramSumUnfitCofE = zeros(histBins,1);

	sumTP = 0;
	sumTN = 0;
	sumFP = 0;
	sumFN = 0;

	fprintf('\n==================STARTING==================\n')
	do = [];
	if doEdge==1
		do = [do 'edge '];
	end
	if doColor==1
		if ~isempty(do)
			do = [do 'and ' ];
		end
		do = [do 'color '];
	end
	if doColorOfEdge==1
		if ~isempty(do)
			do = [do 'and ' ];
		end
		do = [do 'colorOfEdge '];
	end
	fprintf('\nstarting to run classification by %s...\n',do)
	fprintf('\nconstructing data set...\n')

	%construct train and test set for Fit
	fprintf('processing data...\n')
    holdoutSetFitE      = [];
    holdoutSetFitC      = [];
    holdoutSetFitCofE   = [];
	holdoutSetUnfitE    = [];
	holdoutSetUnfitC    = [];
	holdoutSetUnfitCofE = [];
	
	%construct vector (length = amount of images) with randome
    %numbers between 1 and the amout of images
	if ~(dataKnown)
		if doEdge==1
			allDataFitE      = CEgetDataSet( 'edge', pathFit,cannyThresh,...
							   useFront, useRear);
			allDataUnfitE    = CEgetDataSet( 'edge', pathUnfit,cannyThresh,...
							   useFront, useRear);

			nrIndxesFit      = length(allDataFitE);
			nrIndxesUnfit    = length(allDataUnfitE);
		end
		if doColor==1
			allDataFitC		 = CEgetDataSet( 'color', pathFit,cannyThresh,...
							   useFront, useRear);
			allDataUnfitC    = CEgetDataSet( 'color', pathUnfit,cannyThresh,...
							   useFront, useRear);

			nrIndxesFit      = length(allDataFitC);
			nrIndxesUnfit    = length(allDataUnfitC);
		end
		if doColorOfEdge==1
			allDataFitCofE   = CEgetDataSet( 'colorOfEdge', pathFit,cannyThresh,...
							   useFront, useRear);
			allDataUnfitCofE = CEgetDataSet( 'colorOfEdge', pathUnfit,cannyThresh,...
							   useFront, useRear);

			nrIndxesFit      = length(allDataFitCofE);
			nrIndxesUnfit    = length(allDataUnfitCofE);
		end
	end
  
	randIndexFit     = randperm(nrIndxesFit);
	randIndexUnfit   = randperm(nrIndxesUnfit);
	randIndexHOFit   = randIndexFit(1:sizeHoldoutSetFit);
	randIndexTTFit   = randIndexFit(sizeHoldoutSetFit+1:length(randIndexFit));
	randIndexHOUnfit = randIndexUnfit(1:sizeHoldoutSetUnfit);
	randIndexTTUnfit = randIndexUnfit(sizeHoldoutSetUnfit+1:length(randIndexUnfit));
    
	countFoldFit     = round(length(randIndexTTFit)/numberOfFolds);
	countFoldUnfit   = round(length(randIndexTTUnfit)/numberOfFolds);

	%construct train and test set for Unfit
	fprintf('processing unfit data...\n')
	if doEdge==1
		holdoutSetFitE      = allDataFitE(randIndexHOFit);
		holdoutSetUnfitE    = allDataUnfitE(randIndexHOUnfit);
	end
	if doColor==1
		holdoutSetFitC      = allDataFitC(randIndexHOFit);
		holdoutSetUnfitC    = allDataUnfitC(randIndexHOUnfit);
	end
	if doColorOfEdge==1
		holdoutSetFitCofE   = allDataFitCofE(randIndexHOFit);
		holdoutSetUnfitCofE = allDataUnfitCofE(randIndexHOUnfit);
	end

	bestTP         = 0;
	bestTN         = 0;
	bestTPlistE    = [];
	bestTNlistE    = [];
	bestTPlistC    = [];
	bestTNlistC    = [];
	bestTPlistCofE = [];
	bestTNlistCofE = [];
  
  for foldIter=1:numberOfFolds
%    fprintf('\n%d of %d-fold cross validation running...\n',...
%      foldIter, numberOfFolds)

    sizeTestDataFit = 0;
    sizeTestDataUnfit = 0;

    testDataFitE = [];
    meanFitE = 0;
    covFitE = 0;
    testDataUnfitE = [];
    meanUnfitE = 0;
    covUnfitE = 0;
    if doEdge==1
      [ testDataFitE, meanFitE, covFitE, histogramSumFitE ] =...
        CEsplitTrainTest('fit',allDataFitE,randIndexTTFit,foldIter,...
        countFoldFit,histogramSumFitE,doPlot,numberOfFolds,histBins,1);
      [ testDataUnfitE, meanUnfitE, covUnfitE, histogramSumUnfitE ] =...
        CEsplitTrainTest('unfit',allDataUnfitE,randIndexTTUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitE,doPlot,numberOfFolds,histBins,1);
      sizeTestDataFit = length(testDataFitE);
      sizeTestDataUnfit = length(testDataUnfitE);
    end
    testDataFitC = [];
    meanFitC = 0;
    covFitC = 0;
    testDataUnfitC = [];
    meanUnfitC = 0;
    covUnfitC = 0;
    if doColor==1
      [ testDataFitC, meanFitC, covFitC, histogramSumFitC ] =...
        CEsplitTrainTest('fit',allDataFitC,randIndexTTFit,foldIter,...
        countFoldFit,histogramSumFitC,doPlot,numberOfFolds,histBins,-1);
      [ testDataUnfitC, meanUnfitC, covUnfitC, histogramSumUnfitC ] =...
        CEsplitTrainTest('unfit',allDataUnfitC,randIndexTTUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitC,doPlot,numberOfFolds,histBins,-1);
      sizeTestDataFit = length(testDataFitC);
      sizeTestDataUnfit = length(testDataUnfitC);
	end
    testDataFitCofE = [];
    meanFitCofE = 0;
    covFitCofE = 0;
    testDataUnfitCofE = [];
    meanUnfitCofE = 0;
    covUnfitCofE = 0;
    if doColorOfEdge==1
      [ testDataFitCofE, meanFitCofE, covFitCofE, histogramSumFitCofE ] =...
        CEsplitTrainTest('fit',allDataFitCofE,randIndexTTFit,foldIter,...
        countFoldFit,histogramSumFitCofE,doPlot,numberOfFolds,histBins,-2);
      [ testDataUnfitCofE, meanUnfitCofE, covUnfitCofE, histogramSumUnfitCofE ] =...
        CEsplitTrainTest('unfit',allDataUnfitCofE,randIndexTTUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitCofE,doPlot,numberOfFolds,histBins,-2);
      sizeTestDataFit = length(testDataFitCofE);
      sizeTestDataUnfit = length(testDataUnfitCofE);
	end
    
	probFitBeFitE = CEgetGaussProb(testDataFitE,meanFitE,covFitE,sizeTestDataFit);
	probUnfitBeFitE = CEgetGaussProb(testDataUnfitE,meanFitE,covFitE,sizeTestDataUnfit);
	probFitBeUnfitE = CEgetGaussProb(testDataFitE,meanUnfitE,covUnfitE,sizeTestDataFit);
	probUnfitBeUnfitE = CEgetGaussProb(testDataUnfitE,meanUnfitE,covUnfitE,sizeTestDataUnfit);

	probFitBeFitC = CEgetGaussProb(testDataFitC,meanFitC,covFitC,sizeTestDataFit);
	probUnfitBeFitC = CEgetGaussProb(testDataUnfitC,meanFitC,covFitC,sizeTestDataUnfit);
	probFitBeUnfitC = CEgetGaussProb(testDataFitC,meanUnfitC,covUnfitC,sizeTestDataFit);
	probUnfitBeUnfitC = CEgetGaussProb(testDataUnfitC,meanUnfitC,covUnfitC,sizeTestDataUnfit);

	probFitBeFitCofE = CEgetGaussProb(testDataFitCofE,meanFitCofE,covFitCofE,sizeTestDataFit);
	probUnfitBeFitCofE = CEgetGaussProb(testDataUnfitCofE,meanFitCofE,covFitCofE,sizeTestDataUnfit);
	probFitBeUnfitCofE = CEgetGaussProb(testDataFitCofE,meanUnfitCofE,covUnfitCofE,sizeTestDataFit);
	probUnfitBeUnfitCofE = CEgetGaussProb(testDataUnfitCofE,meanUnfitCofE,covUnfitCofE,sizeTestDataUnfit);

	probFitBeFit = (probFitBeFitC.*probFitBeFitCofE).*probFitBeFitE;
	probUnfitBeFit = (probUnfitBeFitC.*probUnfitBeFitCofE).*probUnfitBeFitE;
	probFitBeUnfit = (probFitBeUnfitC.*probFitBeUnfitCofE).*probFitBeUnfitE;
	probUnfitBeUnfit = (probUnfitBeUnfitC.*probUnfitBeUnfitCofE).*probUnfitBeUnfitE;

	%initialize variables to calculate results
	fitGood=0;
	fitNotGood=0;
	unfitGood=0;
	unfitNotGood=0;

    %for the fit test data
    for x=1:size(probFitBeFit,2)
      if probFitBeFit(x) >= probFitBeUnfit(x);
        %if probability of a fit image beeing fit is higher then fit image
        % beeing unfit, the classification is right
        fitGood = fitGood +1;
      else
        %else it is wrong classified
        fitNotGood = fitNotGood +1;
      end
    end

    for x=1:size(probUnfitBeUnfit,2)
      if probUnfitBeUnfit(x) >= probUnfitBeFit(x);
        %if probability of a unfit image beeing unfit is higher then unfit 
        % image beeing fit, the classification is right
        unfitGood = unfitGood +1;
      else
        %else it is wrong classified
        unfitNotGood = unfitNotGood +1;
      end
    end

    %calculate results
    percFitGood = fitGood/(fitGood+fitNotGood)*100;
    percFitWrong = fitNotGood/(fitGood+fitNotGood)*100;
    percUnfitGood = unfitGood/(unfitGood+unfitNotGood)*100;
    percUnfitWrong = unfitNotGood/(unfitGood+unfitNotGood)*100;

%     fprintf('\nresults:\n')
%     fprintf('TP: %4.4g%% of the fit test data is classified good\n',...
%       percFitGood)
%     fprintf('FN: %4.4g%% of the fit test data is classified wrong\n',...
%       percFitWrong)
%     fprintf('TN: %4.4g%% of the unfit test data is classified good\n',...
%       percUnfitGood)
%     fprintf('FP: %4.4g%% of the unfit test data is classified wrong\n',...
%       percUnfitWrong)
    
    sumTP = sumTP + percFitGood;
    sumFN = sumFN + percFitWrong;
    sumTN = sumTN + percUnfitGood;
    sumFP = sumFP + percUnfitWrong;
    
	if percFitGood>bestTP
		bestTPlistE=[meanFitE covFitE];
		bestTPlistC=[meanFitC covFitC];
		bestTPlistCofE=[meanFitCofE covFitCofE];
		bestTP = percFitGood;
    elseif percFitGood==bestTP
		bestTPlistE=[bestTPlistE; meanFitE covFitE];
		bestTPlistC=[bestTPlistC; meanFitC covFitC];
		bestTPlistCofE=[bestTPlistCofE; meanFitCofE covFitCofE];
	end
    if percUnfitGood>bestTN
		bestTNlistE=[meanUnfitE covUnfitE];
		bestTNlistC=[meanUnfitC covUnfitC];
		bestTNlistCofE=[meanUnfitCofE covUnfitCofE];
        bestTN = percUnfitGood;
    elseif percUnfitGood==bestTN
        bestTNlistE=[bestTNlistE; meanUnfitE covUnfitE];
        bestTNlistC=[bestTNlistC; meanUnfitC covUnfitC];
        bestTNlistCofE=[bestTNlistCofE; meanUnfitCofE covUnfitCofE];
    end
    
  end
  fprintf('\naverage result:\n')
  fprintf('TP: %4.4g%% of the fit test data is classified good\n',...
    sumTP/foldIter)
  fprintf('FN: %4.4g%% of the fit test data is classified wrong\n',...
    sumFN/foldIter)
  fprintf('TN: %4.4g%% of the unfit test data is classified good\n',...
    sumTN/foldIter)
  fprintf('FP: %4.4g%% of the utfit test data is classified wrong\n',...
    sumFP/foldIter)

  fprintf('\n\nbest TP: %d times %d\n',length(bestTPlistC),bestTP);
  if size(bestTPlistE,1)>1 | size(bestTPlistC,1)>1 | size(bestTPlistCofE,1)>1
	  bestEvarsTP    = mean(bestTPlistE);
	  bestCvarsTP    = mean(bestTPlistC);
	  bestCofEvarsTP = mean(bestTPlistCofE);
  else
	  bestEvarsTP    = bestTPlistE;
	  bestCvarsTP    = bestTPlistC;
	  bestCofEvarsTP = bestTPlistCofE;
  end
  
  fprintf('best TN: %d times %d\n',length(bestTNlistC),bestTN);
  if size(bestTNlistE,1)>1 | size(bestTNlistC,1)>1 | size(bestTNlistCofE,1)>1
	  bestEvarsTN    = mean(bestTNlistE);
	  bestCvarsTN    = mean(bestTNlistC);
	  bestCofEvarsTN = mean(bestTNlistCofE);
  else
	  bestEvarsTN    = bestTNlistE;
	  bestCvarsTN    = bestTNlistC;
	  bestCofEvarsTN = bestTNlistCofE;
  end

    fprintf('\n==================FINISHED==================\n')
	
  %%%%%%%%%%%%%%%%TESTING HOLDOUT SET%%%%%%%%%%%%%%%%%%%%%%%%%

    probFitBeFitE = CEgetGaussProb(holdoutSetFitE,bestEvarsTP(1),bestEvarsTP(2),sizeHoldoutSetFit);
    probUnfitBeFitE = CEgetGaussProb(holdoutSetUnfitE,bestEvarsTP(1),bestEvarsTP(2),sizeHoldoutSetUnfit);
    probFitBeUnfitE = CEgetGaussProb(holdoutSetFitE,bestEvarsTN(1),bestEvarsTN(2),sizeHoldoutSetFit);
    probUnfitBeUnfitE = CEgetGaussProb(holdoutSetUnfitE,bestEvarsTN(1),bestEvarsTN(2),sizeHoldoutSetUnfit);

    probFitBeFitC = CEgetGaussProb(holdoutSetFitC,bestCvarsTP(1),bestCvarsTP(2),sizeHoldoutSetFit);
    probUnfitBeFitC = CEgetGaussProb(holdoutSetUnfitC,bestCvarsTP(1),bestCvarsTP(2),sizeHoldoutSetUnfit);
    probFitBeUnfitC = CEgetGaussProb(holdoutSetFitC,bestCvarsTN(1),bestCvarsTN(2),sizeHoldoutSetFit);
    probUnfitBeUnfitC = CEgetGaussProb(holdoutSetUnfitC,bestCvarsTN(1),bestCvarsTN(2),sizeHoldoutSetUnfit);

    probFitBeFitCofE = CEgetGaussProb(holdoutSetFitCofE,bestCofEvarsTP(1),bestCofEvarsTP(2),sizeHoldoutSetFit);
    probUnfitBeFitCofE = CEgetGaussProb(holdoutSetUnfitCofE,bestCofEvarsTP(1),bestCofEvarsTP(2),sizeHoldoutSetUnfit);
    probFitBeUnfitCofE = CEgetGaussProb(holdoutSetFitCofE,bestCofEvarsTN(1),bestCofEvarsTN(2),sizeHoldoutSetFit);
    probUnfitBeUnfitCofE = CEgetGaussProb(holdoutSetUnfitCofE,bestCofEvarsTN(1),bestCofEvarsTN(2),sizeHoldoutSetUnfit);

    probFitBeFit = (probFitBeFitC.*probFitBeFitCofE).*probFitBeFitE;
    probUnfitBeFit = (probUnfitBeFitC.*probUnfitBeFitCofE).*probUnfitBeFitE;
    probFitBeUnfit = (probFitBeUnfitC.*probFitBeUnfitCofE).*probFitBeUnfitE;
    probUnfitBeUnfit = (probUnfitBeUnfitC.*probUnfitBeUnfitCofE).*probUnfitBeUnfitE;
    
    %initialize variables to calculate results
    fitGood=0;
    fitNotGood=0;
    unfitGood=0;
    unfitNotGood=0;

    %for the fit test data
    for x=1:size(probFitBeFit,2)
      if probFitBeFit(x) >= probFitBeUnfit(x);
        %if probability of a fit image beeing fit is higher then fit image
        % beeing unfit, the classification is right
        fitGood = fitGood +1;
      else
        %else it is wrong classified
        fitNotGood = fitNotGood +1;
      end
    end

    for x=1:size(probUnfitBeUnfit,2)
      if probUnfitBeUnfit(x) >= probUnfitBeFit(x);
        %if probability of a unfit image beeing unfit is higher then unfit 
        % image beeing fit, the classification is right
        unfitGood = unfitGood +1;
      else
        %else it is wrong classified
        unfitNotGood = unfitNotGood +1;
      end
    end

    %calculate results
    percFitGood = fitGood/(fitGood+fitNotGood)*100;
    percFitWrong = fitNotGood/(fitGood+fitNotGood)*100;
    percUnfitGood = unfitGood/(unfitGood+unfitNotGood)*100;
    percUnfitWrong = unfitNotGood/(unfitGood+unfitNotGood)*100;

    fprintf('\nresults of holdout set (%d fit %d unfit):\n',sizeHoldoutSetFit,sizeHoldoutSetUnfit)
    fprintf('TP: %4.4g%% of the fit test data is classified good\n',...
      percFitGood)
    fprintf('FN: %4.4g%% of the fit test data is classified wrong\n',...
      percFitWrong)
    fprintf('TN: %4.4g%% of the unfit test data is classified good\n',...
      percUnfitGood)
    fprintf('FP: %4.4g%% of the unfit test data is classified wrong\n',...
      percUnfitWrong)
	%%%%%%%%%%%%%%%FINISHED TESTING HOLDOUT SET%%%%%%%%%%%%%%%%%%%%
end

function p = randperm(n)
    [ignore,p] = sort(rand(1,n));
end