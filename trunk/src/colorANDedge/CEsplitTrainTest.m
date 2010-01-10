function [ testData, trainMean, trainCov, histogramSum ] =...
  CEsplitTrainTest(type,allData,randIndex,foldIter,itemsInFold,...
  histogramSum,doPlot,numberOfFolds,histBins )

  trainCount=0;
  testCount=0;
  for i=1:size(allData,2)
    if randIndex(i) > (itemsInFold*(foldIter-1)) &...
        randIndex(i)<=itemsInFold*foldIter
      %get items for the Kth fold given by foldIter from allResults
      testCount = testCount+1;
      testData(:,testCount) = allData(:,i);
    else
      %item belongs to train set
      trainCount = trainCount+1;
      trainData(:,trainCount) = allData(:,i);
    end
  end
  if foldIter==1
    fprintf('\t\t%d fit train images \n\t\t%d fit test images\n',...
    trainCount,testCount)
  end

  %calculate mean and covariance of traininsdata
  trainMean = mean(trainData(1,:));
  trainCov = cov(trainData(1,:));

  if (doPlot>=1 & foldIter==numberOfFolds)
    %calculate and plot histogram
    figure(1)
    if strcmp(type,'fit')
      plotNr=1;
    end
    if strcmp(type,'unfit')
      plotNr=2;
    end
    subplot(1,2,plotNr)
    [hist, binSize,mini] = constrHistogram(trainData(1,:),histBins);
    histogramSum = histogramSum + hist;
    histogramSum = histogramSum/numberOfFolds;
    x = 1:histBins;
    x = (x.*binSize)+mini;
    bar(x,histogramSum);
    title(['Histogram ' type ' train'])
  else
    [hist, binSize,mini] = constrHistogram(trainData(1,:),histBins);
    histogramSum = histogramSum + hist;
  end

end

