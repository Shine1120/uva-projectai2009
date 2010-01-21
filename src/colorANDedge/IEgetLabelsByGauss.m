function [ labels ] = IEgetLabelsByGauss(data,models)

		meanFit   = models(1,:);
		covFit    = models(2,:);
		meanUnfit = models(3,:);
		covUnfit  = models(4,:);
		
% 	testFitMask    = testClasses==1;
% 	testUnfitMask  = testClasses==0;

% 	if isempty(data)
% 		dataFit    = [];
% 		dataUnfit  = [];
% 	else
% 		dataFit    = data(testFitMask,:);
% 		dataUnfit  = data(testUnfitMask,:);
% 	end

	labels = zeros(size(data,1),size(data,2));
	if ~isempty(data)
		for x=1:size(models,2)
			for y=1:size(data,1)
				probBeFit   = gaussProb(meanFit(x),covFit(x),data(y,x));
				probBeUnfit = gaussProb(meanUnfit(x),covUnfit(x),data(y,x));
				if probBeFit>probBeUnfit
					labels(y,x) = 1;
				else
					labels(y,x) = 0;
				end
			end
		end
	end
% 	probUnfitBeTrain = ones(sum(sum(testUnfitMask)), modelCount);
% 	if ~isempty(dataUnfit)
% 		for x=1:size(models,2)
% 			for y=1:size(dataUnfit,1)
% 				%for test images in test set:
% 				% calculate and store probability of x according to mean and covariance
% 				probUnfitBeTrain(y,x) = gaussProb(meanTrain(x),covTrain(x),dataUnfit(y,x));
% 			end
% 		end
% 	end
end

function p = gaussProb(mu,c,x)
	a = 2 * pi * sqrt(det(c));
	b = (x - mu) * inv(c) * (x - mu)';
	p = (1/a) * exp(-b/2);
end