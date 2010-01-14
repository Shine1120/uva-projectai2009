function [ testData, trainMean, trainCov, histogramSum ] =...
  CEsplitTrainTest(type,allData,randIndex,foldIter,itemsInFold,...
  histogramSum,doPlot,numberOfFolds,histBins, lastOfMultMethods,...
  runNumberMin1,runs )

  trainCount=0;
  testCount=0;
%    testData=zeros(itemsInFold,1);
%    trainData=zeros(length(allData)-itemsInFold,1);
  for i=1:length(randIndex)
    if i > (itemsInFold*(foldIter-1)) &...
        i<=itemsInFold*foldIter
      %get items for the Kth fold given by foldIter from allResults
      testCount = testCount+1;
      testData(:,testCount) = allData(:,randIndex(i));
    else
      %item belongs to train set
      trainCount = trainCount+1;
      trainData(:,trainCount) = allData(:,randIndex(i));
    end
  end
%   if (foldIter==1 & lastOfMultMethods>=1)
%     fprintf('\t\t%d %s train images \n\t\t%d %s test images\n',...
%     trainCount,type,testCount,type)
%  end

  %calculate mean and covariance of traininsdata
  trainMean = mean(trainData(1,:));
  trainCov = cov(trainData(1,:));

  if (doPlot>=1 & foldIter==numberOfFolds & runNumberMin1+1==runs)
    %calculate and plot histogram
    figure(lastOfMultMethods+3)
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