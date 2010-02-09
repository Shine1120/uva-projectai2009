function [eModels,iModels] =...
	IEgetModels(doMethods,trainLabels,trainSetE,trainSetI,modelCount)

	% define what methods to do
	doEdge = doMethods(1);
	doIntensity = doMethods(2);

	eModels    = zeros(4,modelCount);
	iModels    = zeros(4,modelCount);
	
	%for edges
	if (doEdge)
		%get edge models (mean and covatiance for fit and unfit)
		[meanEFit, covEFit, meanEUnfit, covEUnfit] =...
			getMeanCov(trainLabels, trainSetE);

		eModels(1,:) = meanEFit;
		eModels(2,:) = covEFit;
		eModels(3,:) = meanEUnfit;
		eModels(4,:) = covEUnfit;
	end

	%for intensity
	if (doIntensity)
		%get intensity models (mean and covatiance for fit and unfit)
		[meanIFit, covIFit, meanIUnfit, covIUnfit] =...
			getMeanCov(trainLabels, trainSetI);
		iModels(1,:) = meanIFit;
		iModels(2,:) = covIFit;
		iModels(3,:) = meanIUnfit;
		iModels(4,:) = covIUnfit;
	end
end

function [meanFit, covFit, meanUnfit, covUnfit] =...
					getMeanCov(trainLabels, trainData)

	%define on that items to learn fit and unfit gaussian on
	trainFitMask         = trainLabels==1;
	trainUnfitMask       = trainLabels==0;

	%prepare data to get mean and covariance
	trainDataFit         = trainData(trainFitMask,:);
	trainDataUnfit       = trainData(trainUnfitMask,:);
	trainDataForCovFit   = trainDataFit';
	trainDataForCovUnfit = trainDataUnfit';
	
	%mean is extracted in one simple calculation
	meanFit   = mean(trainDataFit,1);
	meanUnfit = mean(trainDataUnfit,1);
	
	%covariance needs to be calculated rule by rule
	covFit = zeros(1,size(trainDataForCovFit,1));
	for covIdx = 1:size(trainDataForCovFit,1)
		covFit(1,covIdx) = cov(trainDataForCovFit(covIdx,:));
	end
	covUnfit = zeros(1,size(trainDataForCovUnfit,1));
	for covIdx = 1:size(trainDataForCovUnfit,1)
		covUnfit(1,covIdx) = cov(trainDataForCovUnfit(covIdx,:));
	end
end