function [weights] = adaboostSVM(models, traindata, labels)

	mask = labels == 0;
	labels(mask) = -1;

	
	
	weights = models(2);











end