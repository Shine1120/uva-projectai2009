function [ output_args ] = CErun( input_args )

  close all

  %windows
 pathFit = '..\money\wholeplusborder\neur10\fit\';
 pathUnfit = '..\money\wholeplusborder\neur10\unfit\';

%  pathFit = '..\money\whitepatch\neur05\fit\';
%  pathUnfit = '..\money\whitepatch\neur05\unfit\';

%  pathFit = '..\money\whole\neur10\fit\';
%  pathUnfit = '..\money\whole\neur10\unfit\';

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
  doColorOfEdge=0;
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
  if doEdge==1 & doColor==0
    do = 'edge';
  end
  if doEdge==0 & doColor==1
    do = 'color';
  end
  if doEdge==0 & doColor==0 & doColorOfEdge==1
    do = 'colorOfEdge';
  end
  if doEdge==1 & doColor==1
    do = 'edge and color';
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
    %%%%%%%%%%FIT%%%%%%%%%%%%%%%%%%%
    if doEdge==1 & doColor==0 & doColorOfEdge==0
      [ testDataFitE, meanFitE, covFitE, histogramSumFitE ] =...
        CEsplitTrainTest('fit',allResultsFitE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitE,doPlot,numberOfFolds,histBins,1);
    end
    if doEdge==0 & doColor==1 & doColorOfEdge==0
      [ testDataFitC, meanFitC, covFitC, histogramSumFitC ] =...
        CEsplitTrainTest('fit',allResultsFitC,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitC,doPlot,numberOfFolds,histBins,1);
    end
    if doEdge==0 & doColor==0 & doColorOfEdge==1
      [ testDataFitCofE, meanFitCofE, covFitCofE, histogramSumFitCofE ] =...
        CEsplitTrainTest('fit',allResultsFitCofE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitCofE,doPlot,numberOfFolds,histBins,1);
    end
    if doEdge==1 & doColor==1 & doColorOfEdge==0
      [ testDataFitE, meanFitE, covFitE, histogramSumFitE ] =...
        CEsplitTrainTest('fit',allResultsFitE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitE,doPlot,numberOfFolds,histBins,0);
      [ testDataFitC, meanFitC, covFitC, histogramSumFitC ] =...
        CEsplitTrainTest('fit',allResultsFitC,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitC,doPlot,numberOfFolds,histBins,2);
    end
    if doEdge==1 & doColor==0 & doColorOfEdge==1
      [ testDataFitE, meanFitE, covFitE, histogramSumFitE ] =...
        CEsplitTrainTest('fit',allResultsFitE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitE,doPlot,numberOfFolds,histBins,0);
      [ testDataFitCofE, meanFitCofE, covFitCofE, histogramSumFitCofE ] =...
        CEsplitTrainTest('fit',allResultsFitCofE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitCofE,doPlot,numberOfFolds,histBins,2);
    end
    if doEdge==0 & doColor==1 & doColorOfEdge==1
      [ testDataFitC, meanFitC, covFitC, histogramSumFitC ] =...
        CEsplitTrainTest('fit',allResultsFitC,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitC,doPlot,numberOfFolds,histBins,0);
      [ testDataFitCofE, meanFitCofE, covFitCofE, histogramSumFitCofE ] =...
        CEsplitTrainTest('fit',allResultsFitCofE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitCofE,doPlot,numberOfFolds,histBins,2);
    end
    if doEdge==1 & doColor==1 & doColorOfEdge==1
      [ testDataFitE, meanFitE, covFitE, histogramSumFitE ] =...
        CEsplitTrainTest('fit',allResultsFitE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitE,doPlot,numberOfFolds,histBins,-1);
      [ testDataFitC, meanFitC, covFitC, histogramSumFitC ] =...
        CEsplitTrainTest('fit',allResultsFitC,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitC,doPlot,numberOfFolds,histBins,0);
      [ testDataFitCofE, meanFitCofE, covFitCofE, histogramSumFitCofE ] =...
        CEsplitTrainTest('fit',allResultsFitCofE,randIndexFit,foldIter,...
        countFoldFit,histogramSumFitCofE,doPlot,numberOfFolds,histBins,2);
    end
    %%%%%%%%%END FIT%%%%%%%%%%%%%
    
    %%%%%%%%%%UNFIT%%%%%%%%%%%%%
    if doEdge==1 & doColor==0 & doColorOfEdge==0
      [ testDataUnfitE, meanUnfitE, covUnfitE, histogramSumUnfitE ] =...
        CEsplitTrainTest('unfit',allResultsUnfitE,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitE,doPlot,numberOfFolds,histBins,1);
    end
    if doEdge==0 & doColor==1 & doColorOfEdge==0
      [ testDataUnfitC, meanUnfitC, covUnfitC, histogramSumUnfitC ] =...
        CEsplitTrainTest('unfit',allResultsUnfitC,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitC,doPlot,numberOfFolds,histBins,1);
    end
    if doEdge==0 & doColor==0 & doColorOfEdge==1
      [ testDataUnfitCofE, meanUnfitCofE, covUnfitCofE, histogramSumUnfitCofE ] =...
        CEsplitTrainTest('unfit',allResultsUnfitCofE,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitCofE,doPlot,numberOfFolds,histBins,1);
    end
    if doEdge==1 & doColor==1 & doColorOfEdge==0
      [ testDataUnfitE, meanUnfitE, covUnfitE, histogramSumUnfitE ] =...
        CEsplitTrainTest('unfit',allResultsUnfitE,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitE,doPlot,numberOfFolds,histBins,0);
      [ testDataUnfitC, meanUnfitC, covUnfitC, histogramSumUnfitC ] =...
        CEsplitTrainTest('unfit',allResultsUnfitC,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitC,doPlot,numberOfFolds,histBins,2);
    end
    if doEdge==1 & doColor==0 & doColorOfEdge==1
      [ testDataUnfitE, meanUnfitE, covUnfitE, histogramSumUnfitE ] =...
        CEsplitTrainTest('unfit',allResultsUnfitE,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitE,doPlot,numberOfFolds,histBins,0);
      [ testDataUnfitCofE, meanUnfitCofE, covUnfitCofE, histogramSumUnfitCofE] =...
        CEsplitTrainTest('unfit',allResultsUnfitCofE,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitCofE,doPlot,numberOfFolds,histBins,2);
    end
    if doEdge==0 & doColor==1 & doColorOfEdge==1
      [ testDataUnfitC, meanUnfitC, covUnfitC, histogramSumUnfitC ] =...
        CEsplitTrainTest('unfit',allResultsUnfitC,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitC,doPlot,numberOfFolds,histBins,0);
      [ testDataUnfitCofE, meanUnfitCofE, covUnfitCofE, histogramSumUnfitCofE] =...
        CEsplitTrainTest('unfit',allResultsUnfitCofE,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitCofE,doPlot,numberOfFolds,histBins,2);
    end
    if doEdge==1 & doColor==1 & doColorOfEdge==1
      [ testDataUnfitE, meanUnfitE, covUnfitE, histogramSumUnfitE ] =...
        CEsplitTrainTest('unfit',allResultsUnfitE,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitE,doPlot,numberOfFolds,histBins,-1);
      [ testDataUnfitC, meanUnfitC, covUnfitC, histogramSumUnfitC ] =...
        CEsplitTrainTest('unfit',allResultsUnfitC,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitC,doPlot,numberOfFolds,histBins,0);
      [ testDataUnfitCofE, meanUnfitCofE, covUnfitCofE, histogramSumUnfitCofE] =...
        CEsplitTrainTest('unfit',allResultsUnfitCofE,randIndexUnfit,foldIter,...
        countFoldUnfit,histogramSumUnfitCofE,doPlot,numberOfFolds,histBins,2);
    end
    %%%%%%%%%END UNFIT%%%%%%%%%%%%%
    
    if doEdge==1 & doColor==0 & doColorOfEdge==0
      probFitBeFit = CEgetGaussProb(testDataFitE,meanFitE,covFitE);
      probUnfitBeFit = CEgetGaussProb(testDataUnfitE,meanFitE,covFitE);
      probFitBeUnfit = CEgetGaussProb(testDataFitE,meanUnfitE,covUnfitE);
      probUnfitBeUnfit = CEgetGaussProb(testDataUnfitE,meanUnfitE,covUnfitE);
    end
    if doEdge==0 & doColor==1 & doColorOfEdge==0
      probFitBeFit = CEgetGaussProb(testDataFitC,meanFitC,covFitC);
      probUnfitBeFit = CEgetGaussProb(testDataUnfitC,meanFitC,covFitC);
      probFitBeUnfit = CEgetGaussProb(testDataFitC,meanUnfitC,covUnfitC);
      probUnfitBeUnfit = CEgetGaussProb(testDataUnfitC,meanUnfitC,covUnfitC);
    end
    if doEdge==0 & doColor==0 & doColorOfEdge==1
      probFitBeFit = CEgetGaussProb(testDataFitCofE,meanFitCofE,covFitCofE);
      probUnfitBeFit = CEgetGaussProb(testDataUnfitCofE,meanFitCofE,covFitCofE);
      probFitBeUnfit = CEgetGaussProb(testDataFitCofE,meanUnfitCofE,covUnfitCofE);
      probUnfitBeUnfit = CEgetGaussProb(testDataUnfitCofE,meanUnfitCofE,covUnfitCofE);
    end
    if doEdge==1 & doColor==1 & doColorOfEdge==0
      probFitBeFitE = CEgetGaussProb(testDataFitE,meanFitE,covFitE);
      probUnfitBeFitE = CEgetGaussProb(testDataUnfitE,meanFitE,covFitE);
      probFitBeUnfitE = CEgetGaussProb(testDataFitE,meanUnfitE,covUnfitE);
      probUnfitBeUnfitE = CEgetGaussProb(testDataUnfitE,meanUnfitE,covUnfitE);

      probFitBeFitC = CEgetGaussProb(testDataFitC,meanFitC,covFitC);
      probUnfitBeFitC = CEgetGaussProb(testDataUnfitC,meanFitC,covFitC);
      probFitBeUnfitC = CEgetGaussProb(testDataFitC,meanUnfitC,covUnfitC);
      probUnfitBeUnfitC = CEgetGaussProb(testDataUnfitC,meanUnfitC,covUnfitC);
      
      probFitBeFit = probFitBeFitE.*probFitBeFitC;
      probUnfitBeFit = probUnfitBeFitE.*probUnfitBeFitC;
      probFitBeUnfit = probFitBeUnfitE.*probFitBeUnfitC;
      probUnfitBeUnfit = probUnfitBeUnfitE.*probUnfitBeUnfitC;
    end
    if doEdge==1 & doColor == 0 & doColorOfEdge==1
      probFitBeFitE = CEgetGaussProb(testDataFitE,meanFitE,covFitE);
      probUnfitBeFitE = CEgetGaussProb(testDataUnfitE,meanFitE,covFitE);
      probFitBeUnfitE = CEgetGaussProb(testDataFitE,meanUnfitE,covUnfitE);
      probUnfitBeUnfitE = CEgetGaussProb(testDataUnfitE,meanUnfitE,covUnfitE);

      probFitBeFitCofE = CEgetGaussProb(testDataFitCofE,meanFitCofE,covFitCofE);
      probUnfitBeFitCofE = CEgetGaussProb(testDataUnfitCofE,meanFitCofE,covFitCofE);
      probFitBeUnfitCofE = CEgetGaussProb(testDataFitCofE,meanUnfitCofE,covUnfitCofE);
      probUnfitBeUnfitCofE = CEgetGaussProb(testDataUnfitCofE,meanUnfitCofE,covUnfitCofE);
      
      probFitBeFit = probFitBeFitE.*probFitBeFitCofE;
      probUnfitBeFit = probUnfitBeFitE.*probUnfitBeFitCofE;
      probFitBeUnfit = probFitBeUnfitE.*probFitBeUnfitCofE;
      probUnfitBeUnfit = probUnfitBeUnfitE.*probUnfitBeUnfitCofE;
    end
    if doEdge==0 & doColor == 1 & doColorOfEdge==1
      probFitBeFitC = CEgetGaussProb(testDataFitC,meanFitC,covFitC);
      probUnfitBeFitC = CEgetGaussProb(testDataUnfitC,meanFitC,covFitC);
      probFitBeUnfitC = CEgetGaussProb(testDataFitC,meanUnfitC,covUnfitC);
      probUnfitBeUnfitC = CEgetGaussProb(testDataUnfitC,meanUnfitC,covUnfitC);

      probFitBeFitCofE = CEgetGaussProb(testDataFitCofE,meanFitCofE,covFitCofE);
      probUnfitBeFitCofE = CEgetGaussProb(testDataUnfitCofE,meanFitCofE,covFitCofE);
      probFitBeUnfitCofE = CEgetGaussProb(testDataFitCofE,meanUnfitCofE,covUnfitCofE);
      probUnfitBeUnfitCofE = CEgetGaussProb(testDataUnfitCofE,meanUnfitCofE,covUnfitCofE);
      
      probFitBeFit = probFitBeFitC.*probFitBeFitCofE;
      probUnfitBeFit = probUnfitBeFitC.*probUnfitBeFitCofE;
      probFitBeUnfit = probFitBeUnfitC.*probFitBeUnfitCofE;
      probUnfitBeUnfit = probUnfitBeUnfitC.*probUnfitBeUnfitCofE;
    end
    if doEdge==1 & doColor == 1 & doColorOfEdge==1
      probFitBeFitE = CEgetGaussProb(testDataFitE,meanFitE,covFitE);
      probUnfitBeFitE = CEgetGaussProb(testDataUnfitE,meanFitE,covFitE);
      probFitBeUnfitE = CEgetGaussProb(testDataFitE,meanUnfitE,covUnfitE);
      probUnfitBeUnfitE = CEgetGaussProb(testDataUnfitE,meanUnfitE,covUnfitE);

      probFitBeFitC = CEgetGaussProb(testDataFitC,meanFitC,covFitC);
      probUnfitBeFitC = CEgetGaussProb(testDataUnfitC,meanFitC,covFitC);
      probFitBeUnfitC = CEgetGaussProb(testDataFitC,meanUnfitC,covUnfitC);
      probUnfitBeUnfitC = CEgetGaussProb(testDataUnfitC,meanUnfitC,covUnfitC);

      probFitBeFitCofE = CEgetGaussProb(testDataFitCofE,meanFitCofE,covFitCofE);
      probUnfitBeFitCofE = CEgetGaussProb(testDataUnfitCofE,meanFitCofE,covFitCofE);
      probFitBeUnfitCofE = CEgetGaussProb(testDataFitCofE,meanUnfitCofE,covUnfitCofE);
      probUnfitBeUnfitCofE = CEgetGaussProb(testDataUnfitCofE,meanUnfitCofE,covUnfitCofE);
      
      probFitBeFit = (probFitBeFitC.*probFitBeFitCofE).*probFitBeFitE;
      probUnfitBeFit = (probUnfitBeFitC.*probUnfitBeFitCofE).*probUnfitBeFitE;
      probFitBeUnfit = (probFitBeUnfitC.*probFitBeUnfitCofE).*probFitBeUnfitE;
      probUnfitBeUnfit = (probUnfitBeUnfitC.*probUnfitBeUnfitCofE).*probUnfitBeUnfitE;
    end


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