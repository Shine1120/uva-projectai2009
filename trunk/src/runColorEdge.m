function [] = runColorEdge()

  close all

  %windows
  pathFit = 'money\wholeplusborder\neur05\fit\';
  pathUnFit = 'money\wholeplusborder\neur05\unfit\';

%  pathFit = '..\DirtyMoney2010\whitepatch\neur05\fit\';
%  pathUnFit = '..\DirtyMoney2010\whitepatch\neur05\unfit\';

%  pathFit = '..\DirtyMoney2010\whole\neur05\fit\';
%  pathUnFit = '..\DirtyMoney2010\whole\neur05\unfit\';

  %linux
%  pathFit = '../DirtyMoney2010/wholeplusborder/neur05/fit/';
%  pathUnFit = '../DirtyMoney2010/wholeplusborder/neur05/unfit/';

%  pathFit = '../DirtyMoney2010/whole/neur05/fit/';
%  pathUnFit = '../DirtyMoney2010/whole/neur05/unfit/';

%  pathFit = '../DirtyMoney2010/whitepatch/neur05/fit/';
%  pathUnFit = '../DirtyMoney2010/whitepatch/neur05/unfit/';

%  pathFit = '../DirtyMoney2010/wholeplusborder/neur10/fit/';
%  pathUnFit = '../DirtyMoney2010/wholeplusborder/neur10/unfit/';

  maxNrImg = 250;
  numberOfFolds = 10;

%  do = 'edge';
%  do = 'color';
  do = 'edge and color';
  cannyThresh=0.0355;

  useFront=1;
  useRear=1;

  % doPlot = 0: no plot
  % doPlot = 1: plots histogram of trainingdata
  % doPlot = 2: plots also all the testData (1 plot per iteration)
  doPlot=1;

  histogramBins = 25;
  
  sumTP=0;
  sumTN=0;
  sumFP=0;
  sumFN=0;
  
  %constrDataSet becomes 0 after data set is built (to avoid dataset beeing
  %built every iteration of the K-fold
  constrDataSet=1;
  
  fprintf('\n\n===========STARTING==========================\n')
  fprintf('\nstarting to run classification by %s...\n',do)
  for foldIter=1:numberOfFolds
    tic
    fprintf('\n%d of %d-fold cross validation running...\n',...
      foldIter, numberOfFolds)
    for loop=1:2
      %loop over fit and unfit
      if loop==1 %fit
        path=pathFit;
        if foldIter==1
          fprintf('processing fit data...\n')
        end
      elseif loop==2 %unfit
        path=pathUnFit;
        if foldIter==1
          fprintf('processing unfit data...\n')
        end
      end

      numImages=1;
      allResults=[0,0];

      if (constrDataSet)
        fprintf('\tconstructing the data set\n')
        for i = 1:maxNrImg
          %for all images: extract the data

          %construct front and rear image name
          nextImageNameFront = [path 'f' num2str(i,'%01d') '.bmp'];
          nextImageNameRear = [path 'r' num2str(i,'%01d') '.bmp'];
          %check if both exist in the dataset
          if exist(nextImageNameFront,'file') &&...
              exist(nextImageNameRear,'file')

            %load images as required in the initialization at the top
            if (useFront)
              nextImageFront = im2double(imread(nextImageNameFront));
            end
            if (useRear)
              nextImageRear = im2double(imread(nextImageNameRear));
            end

            %get the data for classification
            if strcmp(do,'edge')
              if (useFront)
                frontImageCount = doEdge(nextImageFront,cannyThresh);
              end
              if (useRear)
                rearImageCount  = doEdge(nextImageRear,cannyThresh);
              end
            end
            if strcmp(do,'color')
              if (useFront)
                frontImageCount = doColor(nextImageFront);
              end
              if (useRear)
                rearImageCount  = doColor(nextImageRear);
              end
            end
            if strcmp(do,'edge and color')
              if (useFront)
                frontImageCount = doEdgeColor(nextImageFront,cannyThresh);
              end
              if (useRear)
                rearImageCount = doEdgeColor(nextImageRear,cannyThresh);
              end
            end

            %add count of front and rear image to results
            allResults(1,numImages)=0;
            if (useFront)
              allResults(1,numImages)=allResults(1,numImages)+frontImageCount;
            end
            if (useRear)
              allResults(1,numImages)=allResults(1,numImages)+rearImageCount;
            end
            %store image id
            allResults(2,numImages)=i;
            
            %raise image count
            numImages=numImages+1;
          end %if fileExists
        end %for imgaes
        if loop==1
          allResultsFit = allResults;
          %construct vector (length = amount of images) with randome
          %numbers between 1 and the amout of images
          randIndexFit = randperm(size(allResultsFit,2));
          %calculate how many images there are in every Kth fold
          countFoldFit = round(size(allResultsFit,2)/numberOfFolds);
        end
        if loop==2
          %same as for loop==1
          allResultsUnfit = allResults;
          randIndexUnfit = randperm(size(allResultsUnfit,2));
          countFoldUnfit = round(size(allResultsUnfit,2)/numberOfFolds);
        end
      end %if constrDataSet

      if loop==1 %fit
        trainCount=0;
        testCount=0;
        for i=1:size(allResultsFit,2)
          if randIndexFit(i) > (countFoldFit*(foldIter-1)) &...
              randIndexFit(i)<=countFoldFit*foldIter
            %get items for the Kth fold given by foldIter from allResults
            testCount = testCount+1;
            testResultsFit(:,testCount) = allResultsFit(:,i);
          else
            %item belongs to train set
            trainCount = trainCount+1;
            trainResultsFit(:,trainCount) = allResultsFit(:,i);
          end
        end
        if foldIter==1
          fprintf('\t\t%d fit train images \n\t\t%d fit test images\n',...
          trainCount,testCount)
        end

        %calculate mean and covariance of traininsdata
        meanFit = mean(trainResultsFit(1,:));
        covFit = cov(trainResultsFit(1,:));

        if (doPlot>=1 & foldIter==1)
          %calculate and plot histogram
          figure(1)
          subplot(1,2,1)
          [hist, binSize,mini] = histConstr(trainResultsFit(1,:),histogramBins);
          x = 1:histogramBins;
          x = (x.*binSize)+mini;
          bar(x,hist);
          title('Histogram Fit train')
        end
      end
      if loop==2 %unfit
        trainCount=0;
        testCount=0;
        % same as for fit (loop==1)
        for i=1:size(allResultsUnfit,2)
          if randIndexUnfit(i) > (countFoldUnfit*(foldIter-1)) &...
              randIndexUnfit(i)<=countFoldUnfit*foldIter
            testCount = testCount+1;
            testResultsUnfit(:,testCount) = allResultsUnfit(:,i);
          else
            trainCount = trainCount+1;
            trainResultsUnfit(:,trainCount) = allResultsUnfit(:,i);
          end
        end
        if foldIter==1
          fprintf('\t\t%d unfit train images \n\t\t%d unfit test images\n',...
            trainCount, testCount)
        end

        meanUnfit = mean(trainResultsUnfit(1,:));
        covUnfit = cov(trainResultsUnfit(1,:));
        
        if (doPlot>=1 & foldIter==1)
          %Histogram calculation and plot
          figure(1)
          subplot(1,2,2)
          [hist, binSize,mini] = histConstr(trainResultsUnfit(1,:),histogramBins);
          x = 1:histogramBins;
          x = (x.*binSize)+mini;
          bar(x,hist);
          title('Histogram Unfit train')
        end
        constrDataSet=0;
      end
    end


    for x=1:size(testResultsFit,2)
      %for test images in test set of fit do:
      % calculate and store probability of x according to mean and covariance
      probFitBeFit(x) = bigauss(meanFit,covFit,testResultsFit(1,x));
    end

    if (doPlot>=2)
      figure('name','Probabilities')
      %plot resulting probabilities of test set
      subplot(2,2,1); 
      plot(1:size(probFitBeFit,2),probFitBeFit)
      title('Fit beeing Fit')
      hold on
      plot(1:size(probFitBeFit,2),mean(probFitBeFit),'r')
      hold off
    end

    for x=1:size(testResultsUnfit,2)
      %same as first loop
      probUnfitBeFit(x) = bigauss(meanFit,covFit,testResultsUnfit(1,x));
    end

    if (doPlot>=2)
      subplot(2,2,2); 
      plot(1:size(probUnfitBeFit,2),probUnfitBeFit)
      title('UnFit beeing Fit')
      hold on
      plot(1:size(probUnfitBeFit,2),mean(probUnfitBeFit),'r')
      hold off
    end

    for x=1:size(testResultsFit,2)
      %same as first loop
      probFitBeUnfit(x) = bigauss(meanUnfit,covUnfit,testResultsFit(1,x));
    end

    if (doPlot>=2)
      subplot(2,2,3); 
      plot(1:size(probFitBeUnfit,2),probFitBeUnfit)
      title('Fit beeing UnFit')
      hold on
      plot(1:size(probFitBeUnfit,2),mean(probFitBeUnfit),'r')
      hold off
    end

    for x=1:size(testResultsUnfit,2)
      %same as first loop
      probUnfitBeUnfit(x) = bigauss(meanUnfit,covUnfit,testResultsUnfit(1,x));
    end

    if (doPlot>=2)
      subplot(2,2,4); 
      plot(1:size(probUnfitBeUnfit,2),probUnfitBeUnfit)
      title('UnFit beeing UnFit')
      hold on
      plot(1:size(probUnfitBeUnfit,2),mean(probUnfitBeUnfit),'r')
      hold off
    end

    %initialize variables to calculate results
    fitGood=0;
    fitNotGood=0;
    unfitGood=0;
    unfitNotGood=0;

    %for the fit test data
    for x=1:size(testResultsFit,2)
      if probFitBeFit(x) >= probFitBeUnfit(x);
        %if probability of a fit image beeing fit is higher then fit image
        % beeing unfit, the classification is right
        fitGood = fitGood +1;
      else
        %else it is wrong classified
        fitNotGood = fitNotGood +1;
      end
    end

    for x=1:size(testResultsUnfit,2)
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
    toc
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

function edgeCount = doEdge(image,cannyThresh)
  edgeImageFront = edge(image,'canny',cannyThresh);
  edgeCount=sum(sum(edgeImageFront));
end

function avgColor = doColor(image)
	avgColor=mean(mean(image));
end

function count = doEdgeColor(image,cannyThresh)
  factor = 40;
  %average color is raised by a factor to make it usefull for large count
  %of edges. This might not be the ideal way to do this.
  count = doEdge(image,cannyThresh) + (doColor(image)*factor);
end

function p = bigauss(mu,c,x)
	a = 2 * pi * sqrt(det(c));
	b = (x - mu) * inv(c) * (x - mu)';
	p = (1/a) * exp(-b/2);
end

function [histogram,binSize,mini] = histConstr(list,bins)

  mini = min(list);
  maxi = max(list);
  diff = maxi-mini;
  binSize = diff/bins;

  resultBinned = zeros(size(list));
  histogram = zeros(bins,1);
  for i=1:bins
    %get all items in list that have values that correspond to bin i
    mask = list>=((binSize*(i-1))+mini) & list<=((binSize*(i))+mini);
    resultBinned(mask) = i;
  end
  for t=1:size(list,2)
     %add occurences to bar 
     histogram(resultBinned(t)) = histogram(resultBinned(t)) + 1;
  end
end