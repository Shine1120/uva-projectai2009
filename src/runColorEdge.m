function [] = runColorEdge()

  close all

  %windows
  pathFit = '..\DirtyMoney2010\wholeplusborder\neur05\fit\';
  pathUnFit = '..\DirtyMoney2010\wholeplusborder\neur05\unfit\';

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
  trainImgPercentage = 66;

  do = 'edge';
%  do = 'color';
%  do = 'edge and color';

  histogramBins = 25;

  cannyThresh=0.03;

  fprintf('\n\n===========STARTING==========================\n')
  fprintf('\nstarting to run classification by %s...\n\n',do)
  for loop=1:2
    %loop over fit and unfit
    if loop==1 %fit
      path=pathFit;
      fprintf('processing fit data...\n')
    elseif loop==2 %unfit
      path=pathUnFit;
      fprintf('processing unfit data...\n')
    end

    numImages=1;
    allResults=[0,0];

    fprintf('\tconstructing the data set\n')
    for i = 1:maxNrImg
      %for all images: extract the data
      
      %construct front and rear image name
      nextImageNameFront = [path 'f' num2str(i,'%01d') '.bmp'];
      nextImageNameRear = [path 'r' num2str(i,'%01d') '.bmp'];
      %check if both exist in the dataset
      if exist(nextImageNameFront,'file') &&...
          exist(nextImageNameRear,'file')

        %load images
        nextImageFront = imread(nextImageNameFront);
        nextImageRear = imread(nextImageNameRear);

        %get the data for classification
        if strcmp(do,'edge')
          frontImageCount = doEdge(nextImageFront,cannyThresh);
          rearImageCount  = doEdge(nextImageRear,cannyThresh);
        end
        if strcmp(do,'color')
          frontImageCount = doColor(nextImageFront);
          rearImageCount  = doColor(nextImageRear);
        end
        if strcmp(do,'edge and color')
          frontImageCount = doEdgeColor(nextImageFront,cannyThresh);
          rearImageCount  = doEdgeColor(nextImageRear,cannyThresh);
        end
        
        %add count of front and rear image to results
        allResults(1,numImages)=rearImageCount+frontImageCount;
        %store image id
        allResults(2,numImages)=i;
        %raise image count
        numImages=numImages+1;
      end
    end

    if loop==1 %fit
      %calculate number of trainimages to use
      trainImg = round((trainImgPercentage/100)*size(allResults,2));
      fprintf('\t\t%d train images \n\t\t%d test images\n',trainImg,...
          size(allResults,2)-trainImg)
      %extract train and test set from allResults
      trainResultsFit = allResults(:,1:trainImg);
      testResultsFit = allResults(:,trainImg+1:size(allResults,2));
      
      %calculate mean and covariance of traininsdata
      meanFit = mean(trainResultsFit(1,:));
      covFit = cov(trainResultsFit(1,:));
      
      %calculate and plot histogram
      figure(1)
      subplot(1,2,1)
      [hist, binSize,mini] = histConstr(trainResultsFit(1,:),histogramBins);
      x = 1:histogramBins;
      x = (x.*binSize)+mini;
      bar(x,hist);
      title('Histogram Fit train')
    end
    if loop==2 %unfit
      % same as for fit (loop==1)
      trainImg = round((trainImgPercentage/100)*size(allResults,2));
      fprintf('\t\t%d train images \n\t\t%d test images\n',trainImg,...
          size(allResults,2)-trainImg)
      trainResultsUnfit = allResults(:,1:trainImg);
      testResultsUnfit = allResults(:,trainImg+1:size(allResults,2));
      meanUnfit = mean(trainResultsUnfit(1,:));
      covUnfit = cov(trainResultsUnfit(1,:));
      %Histogram calculation and plot
      figure(1)
      subplot(1,2,2)
      [hist, binSize,mini] = histConstr(trainResultsUnfit(1,:),histogramBins);
      x = 1:histogramBins;
      x = (x.*binSize)+mini;
      bar(x,hist);
      title('Histogram Unfit train')
    end
  end

  figure('name','Probabilities')

  for x=1:size(testResultsFit,2)
    %for test images in test set of fit do:
    % calculate and store probability of x according to mean and covariance
    probFitBeFit(x) = bigauss(meanFit,covFit,testResultsFit(1,x));
  end
  %normalize to get values between 0 and 1
  probFitBeFit = probFitBeFit./max(probFitBeFit);

  %plot resulting probabilities of test set
  subplot(2,2,1); 
  plot(1:size(probFitBeFit,2),probFitBeFit)
  title('Fit beeing Fit')
  hold on
  plot(1:size(probFitBeFit,2),mean(probFitBeFit),'r')
  hold off

  for x=1:size(testResultsUnfit,2)
    %same as first loop
    probUnfitBeFit(x) = bigauss(meanFit,covFit,testResultsUnfit(1,x));
  end
  probUnfitBeFit = probUnfitBeFit./max(probUnfitBeFit);
  
  subplot(2,2,2); 
  plot(1:size(probUnfitBeFit,2),probUnfitBeFit)
  title('UnFit beeing Fit')
  hold on
  plot(1:size(probUnfitBeFit,2),mean(probUnfitBeFit),'r')
  hold off

  for x=1:size(testResultsFit,2)
    %same as first loop
    probFitBeUnfit(x) = bigauss(meanUnfit,covUnfit,testResultsFit(1,x));
  end
  probFitBeUnfit = probFitBeUnfit./max(probFitBeUnfit);
  subplot(2,2,3); 
  plot(1:size(probFitBeUnfit,2),probFitBeUnfit)
  title('Fit beeing UnFit')
  hold on
  plot(1:size(probFitBeUnfit,2),mean(probFitBeUnfit),'r')
  hold off

  for x=1:size(testResultsUnfit,2)
    %same as first loop
    probUnfitBeUnfit(x) = bigauss(meanUnfit,covUnfit,testResultsUnfit(1,x));
  end
  probUnfitBeUnfit = probUnfitBeUnfit./max(probUnfitBeUnfit);
  subplot(2,2,4); 
  plot(1:size(probUnfitBeUnfit,2),probUnfitBeUnfit)
  title('UnFit beeing UnFit')
  hold on
  plot(1:size(probUnfitBeUnfit,2),mean(probUnfitBeUnfit),'r')
  hold off

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
  percUnfitGood = unfitGood/(unfitGood+unfitNotGood)*100;

  fprintf('\nresults:\n')
  fprintf('%6.4g%% of the fit test data is classified good\n',percFitGood)
  fprintf('%6.4g%% of the unfit test data is classified good\n',percUnfitGood)
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
    mask = list>=((binSize*(i-1))+mini) & list<=((binSize*(i))+mini);
    resultBinned(mask) = i;
  end
  for t=1:size(list,2)
     %add occurences to bar 
     histogram(resultBinned(t)) = histogram(resultBinned(t)) + 1;
  end
end