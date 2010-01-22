function [ probTestData ] = CEgetGaussProb( testData, meanTrain, covTrain,...
  sizeTestData)

  probTestData = ones(sizeTestData);
  if ~isempty(testData)
    for x=1:size(testData,2)
      %for test images in test set:
      % calculate and store probability of x according to mean and covariance
      probTestData(x) = gaussProb(meanTrain,covTrain,testData(1,x));
    end
  end
end

function p = gaussProb(mu,c,x)
	a = 2 * pi * sqrt(det(c));
	b = (x - mu) * inv(c) * (x - mu)';
	p = (1/a) * exp(-b/2);
end