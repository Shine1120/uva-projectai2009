function [ output_args ] = CErun( input_args )

  close all

  %windows
  pathFit = '..\money\wholeplusborder\neur05\fit\';
  pathUnfit = '..\money\wholeplusborder\neur05\unfit\';

%  pathFit = '..\money\whitepatch\neur05\fit\';
%  pathUnfit = '..\money\whitepatch\neur05\unfit\';

%  pathFit = '..\money\whole\neur05\fit\';
%  pathUnfit = '..\money\whole\neur05\unfit\';

  %linux
%  pathFit = '../DirtyMoney2010/wholeplusborder/neur05/fit/';
%  pathUnfit = '../DirtyMoney2010/wholeplusborder/neur05/unfit/';

%  pathFit = '../DirtyMoney2010/whole/neur05/fit/';
%  pathUnfit = '../DirtyMoney2010/whole/neur05/unfit/';

%  pathFit = '../DirtyMoney2010/whitepatch/neur05/fit/';
%  pathUnfit = '../DirtyMoney2010/whitepatch/neur05/unfit/';

  maxNrImg = 250;
  numberOfFolds = 10;

  doEdge=1;
  doColor=1;
  doColorOfEdge=1;
  cannyThresh=0.0355;

  useFront=1;
  useRear=1;

  % doPlot = 0: no plot
  % doPlot = 1: plots histogram of trainingdata
  % doPlot = 2: plots also all the testData (1 plot per iteration)
  doPlot=1;

  histBins = 25;
  histogramSumFitE = zeros(histBins,1);
  histogramSumUnfitE = zeros(histBins,1);
  histogramSumFitC = zeros(histBins,1);
  histogramSumUnfitC = zeros(histBins,1);
  histogramSumFitCofE = zeros(histBins,1);
  histogramSumUnfitCofE = zeros(histBins,1);
  histogramSumFitCE = zeros(histBins,1);
  histogramSumUnfitCE = zeros(histBins,1);
  
  sumTP=0;
  sumTN=0;
  sumFP=0;
  sumFN=0;
  
  fprintf('\n\n===========STARTING==========================\n')
  do = []
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
  fprintf('processing fit data...\n')
  if doEdge==1
    allResultsFitE = CEgetDataSet( 'edge', pathFit,cannyThresh,...
      maxNrImg, useFront, useRear );
    %construct vector (length = amount of images) with randome
    %numbers between 1 and the amout of images
    randIndexFit = randperm(size(allResultsFitE,2));
    %calculate how many images there are in every Kth fold
    countFoldFit = round(size(allResultsFitE,2)/numberOfFolds);
  end
  if doColor==1
    allResultsFitC = CEgetDataSet( 'color', pathFit,cannyThresh,...
      maxNrImg, useFront, useRear );
    randIndexFit = randperm(size(allResultsFitC,2));
    countFoldFit = round(size(allResultsFitC,2)/numberOfFolds);
  end
  if doColorOfEdge==1
    allResultsFitCofE = CEgetDataSet( 'colorOfEdge', pathFit,cannyThresh,...
      maxNrImg, useFront, useRear );
    randIndexFit = randperm(size(allResultsFitCofE,2));
    countFoldFit = round(size(allResultsFitCofE,2)/numberOfFolds);
  end

  %construct train and test set for Unfit
  fprintf('processing unfit data...\n')
  if doEdge==1
    allResultsUnfitE = CEgetDataSet( 'edge', pathUnfit,cannyThresh,...
      maxNrImg, useFront, useRear );
    %construct vector (length = amount of images) with randome
    %numbers between 1 and the amout of images
    randIndexUnfit = randperm(size(allResultsUnfitE,2));
    %calculate how many images there are in every Kth fold
    countFoldUnfit = round(size(allResultsUnfitE,2)/numberOfFolds);
  end
  if doColor==1
    allResultsUnfitC = CEgetDataSet( 'color', pathUnfit,cannyThresh,...
      maxNrImg, useFront, useRear );
    randIndexUnfit = randperm(size(allResultsUnfitC,2));
    countFoldUnfit = round(size(allResultsUnfitC,2)/numberOfFolds);
  end
  if doColorOfEdge==1
    allResultsUnfitCofE = CEgetDataSet( 'colorOfEdge', pathUnfit,cannyThresh,...
      maxNrImg, useFront, useRear );
    randIndexUnfit = randperm(size(allResultsUnfitCofE,2));
    countFoldUnfit = round(size(allResultsUnfitCofE,2)/numberOfFolds);
  end

  for foldIter=1:numberOfFolds
    tic
    fprintf('\n%d of %d-fold cross validation running...\n',...
      foldIter, numberOfFolds)

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
        CEsplitTrainTest('fit',allResultsFitE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitE,doPlot,numberOfFolds,histBins,1);
      [ testDataUnfitE, meanUnfitE, covUnfitE, histogramSumUnfitE ] =...
        CEsplitTrainTest('unfit',allResultsUnfitE,randIndexUnfit,foldIter,...
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
        CEsplitTrainTest('fit',allResultsFitC,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitC,doPlot,numberOfFolds,histBins,-1);
      [ testDataUnfitC, meanUnfitC, covUnfitC, histogramSumUnfitC ] =...
        CEsplitTrainTest('unfit',allResultsUnfitC,randIndexUnfit,foldIter,...
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
        CEsplitTrainTest('fit',allResultsFitCofE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitCofE,doPlot,numberOfFolds,histBins,-2);
      [ testDataUnfitCofE, meanUnfitCofE, covUnfitCofE, histogramSumUnfitCofE ] =...
        CEsplitTrainTest('unfit',allResultsUnfitCofE,randIndexUnfit,foldIter,...
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

    fprintf('\nresults:\n')
    fprintf('TP: %4.4g%% of the fit test data is classified good\n',...
      percFitGood)
    fprintf('FN: %4.4g%% of the fit test data is classified wrong\n',...
      percFitWrong)
    fprintf('TN: %4.4g%% of the unfit test data is classified good\n',...
      percUnfitGood)
    fprintf('FP: %4.4g%% of the unfit test data is classified wrong\n',...
      percUnfitWrong)
    
    sumTP = sumTP + percFitGood;
    sumFN = sumFN + percFitWrong;
    sumTN = sumTN + percUnfitGood;
    sumFP = sumFP + percUnfitWrong;

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
  
  fprintf('\n===========FINISHED==========================\n')

end