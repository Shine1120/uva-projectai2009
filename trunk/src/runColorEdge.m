function [] = runEdge2()


    close all
    %windows
     pathFit = '..\DirtyMoney2010\wholeplusborder\neur05\fit\';
     pathUnFit = '..\DirtyMoney2010\wholeplusborder\neur05\unfit\';

%      pathFit = '..\DirtyMoney2010\whitepatch\neur05\fit\';
%      pathUnFit = '..\DirtyMoney2010\whitepatch\neur05\unfit\';

%    pathFit = '..\DirtyMoney2010\whole\neur05\fit\';
%    pathUnFit = '..\DirtyMoney2010\whole\neur05\unfit\';

    %linux
%    pathFit = 'DirtyMoney2010/wholeplusborder/neur05/fit/';
%    pathUnFit = 'DirtyMoney2010/wholeplusborder/neur05/unfit/';

%    pathFit = 'DirtyMoney2010/whole/neur05/fit/';
%    pathUnFit = 'DirtyMoney2010/whole/neur05/unfit/';

%    pathFit = 'DirtyMoney2010/whitepatch/neur05/fit/';
%    pathUnFit = 'DirtyMoney2010/whitepatch/neur05/unfit/';

%    pathFit = 'DirtyMoney2010/wholeplusborder/neur10/fit/';
%    pathUnFit = 'DirtyMoney2010/wholeplusborder/neur10/unfit/';

    maxNrImg = 250;
    trainImg = 150;

    do = 'edge';
%    do = 'color';
%    do = 'edgeColor';

    cannyThresh=0.03;
    
    for loop=1:2
        %loop over fit and unfit
        if loop==1 %fit
            path=pathFit;
            type='fit'
        elseif loop==2 %unfit
            path=pathUnFit;
            type='unfit'
        end
        
        numTrainImages=1;
        numTestImages=1;
        trainResults=[0,0];
        testResults=[0,0];
        
        for i = 1:trainImg
            nextImageNameFront = [path 'f' num2str(i,'%01d') '.bmp'];
            nextImageNameRear = [path 'r' num2str(i,'%01d') '.bmp'];
            if exist(nextImageNameFront,'file') &&...
                    exist(nextImageNameRear,'file')
                
                nextImageFront = imread(nextImageNameFront);
                nextImageRear = imread(nextImageNameRear);

                if strcmp(do,'edge')
                    frontImageCount = doEdge(nextImageFront,cannyThresh);
                    rearImageCount  = doEdge(nextImageRear,cannyThresh);
                end
                if strcmp(do,'color')
                    frontImageCount = doColor(nextImageFront);
                    rearImageCount  = doColor(nextImageRear);
                end
                if strcmp(do,'edgeColor')
                    frontImageCount = doEdgeColor(nextImageFront,cannyThresh);
                    rearImageCount  = doEdgeColor(nextImageRear,cannyThresh);
                end

                trainResults(1,numTrainImages)=rearImageCount+...
                    frontImageCount;
                trainResults(2,numTrainImages)=i;
                numTrainImages=numTrainImages+1;
            end
        end
        for j = trainImg+1:maxNrImg
            nextImageNameFront = [path 'f' num2str(j,'%01d') '.bmp'];
            nextImageNameRear = [path 'r' num2str(j,'%01d') '.bmp'];
            if exist(nextImageNameFront,'file') &&...
                    exist(nextImageNameRear,'file')
                
                nextImageFront = imread(nextImageNameFront);
                nextImageRear = imread(nextImageNameRear);

                if strcmp(do,'edge')
                    frontImageCount = doEdge(nextImageFront,cannyThresh);
                    rearImageCount  = doEdge(nextImageRear,cannyThresh);
                end
                if strcmp(do,'color')
                    frontImageCount = doColor(nextImageFront);
                    rearImageCount  = doColor(nextImageRear);
                end
                if strcmp(do,'edgeColor')
                    frontImageCount = doEdgeColor(nextImageFront,cannyThresh);
                    rearImageCount  = doEdgeColor(nextImageRear,cannyThresh);
                end

                testResults(1,numTestImages)=rearImageCount+...
                    frontImageCount;
                
                testResults(2,numTestImages)=j;
                numTestImages=numTestImages+1;
            end
        end
        
%         figure('Name',type)
%         plot(trainResults(1,:))
%         hold on
%         plot(1:maxNrImg,mean(trainResults(1,:)),'r')
        if loop==1
            trainResultsFit = trainResults;
            testResultsFit = testResults;
            mR1 = mean(trainResultsFit(1,:));
            cR1 = cov(trainResultsFit(1,:));
        end
        if loop==2
            trainResultsUnfit = trainResults;
            testResultsUnfit = testResults;
            mR2 = mean(trainResultsUnfit(1,:));
            cR2 = cov(trainResultsUnfit(1,:));
        end
    end
    figure('name','Probabilities')
    
    for x=1:size(testResultsFit,2)
        %for all edge counts in 1 (fit) do:
        %get probability of x according to mean and covariance of 
        % results 1 (edges of fit bills)
        probFitBeFit(x) = bigauss(mR1,cR1,testResultsFit(1,x));
    end
    %normalize
    probFitBeFit = probFitBeFit./max(probFitBeFit);
    
    subplot(2,2,1); 
    plot(1:size(probFitBeFit,2),probFitBeFit)
    title('Fit beeing Fit')
    hold on
    plot(1:size(probFitBeFit,2),mean(probFitBeFit),'r')
    hold off

    for x=1:size(testResultsUnfit,2)
        %for all edge counts in 2 (unfit) do:
        %get probability of x according to mean and covariance of 
        % results 1 (edges of fit bills)
        probUnfitBeFit(x) = bigauss(mR1,cR1,testResultsUnfit(1,x));
    end
    probUnfitBeFit = probUnfitBeFit./max(probUnfitBeFit);
    subplot(2,2,2); 
    plot(1:size(probUnfitBeFit,2),probUnfitBeFit)
    title('UnFit beeing Fit')
    hold on
    plot(1:size(probUnfitBeFit,2),mean(probUnfitBeFit),'r')
    hold off

    for x=1:size(testResultsFit,2)
        %for all edge counts in 1 (fit) do:
        %get probability of x according to mean and covariance of 
        % results 2 (edges of unfit bills)
        probFitBeUnfit(x) = bigauss(mR2,cR2,testResultsFit(1,x));
    end
    probFitBeUnfit = probFitBeUnfit./max(probFitBeUnfit);
    subplot(2,2,3); 
    plot(1:size(probFitBeUnfit,2),probFitBeUnfit)
    title('Fit beeing UnFit')
    hold on
    plot(1:size(probFitBeUnfit,2),mean(probFitBeUnfit),'r')
    hold off

    for x=1:size(testResultsUnfit,2)
        %for all edge counts in 2 (unfit) do:
        %get probability of x according to mean and covariance of 
        % results 2 (edges of unfit bills)
        probUnfitBeUnfit(x) = bigauss(mR2,cR2,testResultsUnfit(1,x));
    end
    probUnfitBeUnfit = probUnfitBeUnfit./max(probUnfitBeUnfit);
    subplot(2,2,4); 
    plot(1:size(probUnfitBeUnfit,2),probUnfitBeUnfit)
    title('UnFit beeing UnFit')
    hold on
    plot(1:size(probUnfitBeUnfit,2),mean(probUnfitBeUnfit),'r')
    hold off

    fitGood=0;
    fitNotGood=0;
    unfitGood=0;
    unfitNotGood=0;
    
	for x=1:size(testResultsFit,2)
        if probFitBeFit(x) >= probFitBeUnfit(x);
            fitGood = fitGood +1;
        else
            fitNotGood = fitNotGood +1;
        end
    end
    
	for x=1:size(testResultsUnfit,2)
        if probUnfitBeUnfit(x) >= probUnfitBeFit(x);
            unfitGood = unfitGood +1;
        else
            unfitNotGood = unfitNotGood +1;
        end
    end
   
    percentageFitGood = fitGood/(fitGood+fitNotGood)*100
    percentageUnfitGood = unfitGood/(unfitGood+unfitNotGood)*100

end

function edgeCount = doEdge(image,cannyThresh)
    edgeImageFront = edge(image,'canny',cannyThresh);
    edgeCount=sum(sum(edgeImageFront));
end

function avgColor = doColor(image)
	avgColor=mean(mean(image));
end

function count = doEdgeColor(image,cannyThresh)
    count = doEdge(image,cannyThresh) + (doColor(image)*40);
end

function p = bigauss(mu,c,x)
	a = 2 * pi * sqrt(det(c));
	b = (x - mu) * inv(c) * (x - mu)';
	p = (1/a) * exp(-b/2);
end