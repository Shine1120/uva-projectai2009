function [eModels,iModels,iofeModels] =...
	IEgetModels(doMethods,trainLabels,trainSetE,trainSetI,trainSetIofE,modelCount)

	doEdge = doMethods(1);
	doIntensity = doMethods(2);
	doIntensityOfEdge = doMethods(3);

	eModels    = zeros(4,modelCount);
	iModels    = zeros(4,modelCount);
	iofeModels = zeros(4,modelCount);
	
	if (doEdge)
		[meanEFit, covEFit, meanEUnfit, covEUnfit] =...
			getMeanCov(trainLabels, trainSetE);

		eModels(1,:) = meanEFit;
		eModels(2,:) = covEFit;
		eModels(3,:) = meanEUnfit;
		eModels(4,:) = covEUnfit;
	end

	if (doIntensity)
		[meanIFit, covIFit, meanIUnfit, covIUnfit] =...
			getMeanCov(trainLabels, trainSetI);
		iModels(1,:) = meanIFit;
		iModels(2,:) = covIFit;
		iModels(3,:) = meanIUnfit;
		iModels(4,:) = covIUnfit;
	end

	if (doIntensityOfEdge)
		[meanIofEFit, covIofEFit, meanIofEUnfit, covIofEUnfit] =...
			getMeanCov(trainLabels, trainSetIofE);

		iofeModels(1,:) = meanIofEFit;
		iofeModels(2,:) = covIofEFit;
		iofeModels(3,:) = meanIofEUnfit;
		iofeModels(4,:) = covIofEUnfit;
	end
end

function [meanFit, covFit, meanUnfit, covUnfit] =...
					getMeanCov(trainLabels, trainData)

	trainFitMask         = trainLabels==1;
	trainUnfitMask       = trainLabels==0;

	trainDataFit         = trainData(trainFitMask,:);
	trainDataUnfit       = trainData(trainUnfitMask,:);
	trainDataForCovFit   = trainDataFit';
	trainDataForCovUnfit = trainDataUnfit';
	
	meanFit   = mean(trainDataFit,1);
	meanUnfit = mean(trainDataUnfit,1);
	
	covFit = zeros(1,size(trainDataForCovFit,1));
	for covIdx = 1:size(trainDataForCovFit,1)
		covFit(1,covIdx) = cov(trainDataForCovFit(covIdx,:));
	end
	covUnfit = zeros(1,size(trainDataForCovUnfit,1));
	for covIdx = 1:size(trainDataForCovUnfit,1)
		covUnfit(1,covIdx) = cov(trainDataForCovUnfit(covIdx,:));
	end
end