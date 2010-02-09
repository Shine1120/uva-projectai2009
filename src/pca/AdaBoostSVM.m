function [alpha, modelIdx, models] = AdaBoostSVM(models, traindata, eigen_regions, labels, T)
% ADABOOSTSVM - Adaptive Boosting using SVM models as weak classifiers. Every model
% represents a pca segment on the bill. 
%
% models:			SVM models trained on pca segments
% traindata:		image train data in format [imgIdx, data, regionIdx]
% eigen_regions:	components used for projection (based on regions)
% labels:			labels of the traindata [0 1]
% T:				number of models to find


	% mask labels to have the set [-1 1] 
	labels_masked = labels;
	mask = labels == 0;
	labels_masked(mask) = -1;
	m = length(labels);

	alpha = zeros(1,T);
	modelIdx = zeros(1,T);

	Dt = ones(1,m)*(1/m);

	% get the best T models
	for i=1:T
		fprintf('\tAdaBoost t=%d\n', i)
		
		best_model = 1; % initialize to some model
		smallest_error = 10000; % initialize error to some big number
		
		best_recognized_list = [];
		% find the best model by minimizing the error (with respect to Dt)
		for j=1:length(models)
			% get model of segment j
			model = models(j);
			
			% get correct traindata for segment j
			images_region = traindata(:,:,j);
			
			% get correct pca components for segment j
			eigen_region = eigen_regions(:,:,j);
			
			% project traindata onto the components
			imagesProjection = images_region * eigen_region;

			[recognized, accuracy, prob_est_front] = svmpredict(labels,imagesProjection, model, '-b 0');
						
			error_j = sum(Dt'.* (labels ~= recognized));
			
			if (error_j < smallest_error)
				smallest_error = error_j;
				best_model = j;
				best_recognized_list = recognized;
			end
		end
% 		fprintf('\tBest model for t=%d is %d\n',i, best_model)
% 		fprintf('\t\tUpdate weights\n')
		modelIdx(i) = best_model;

		% update alpha weights
		alpha(i) = 0.5*log((1-smallest_error)/smallest_error); 

		% update instance weights


		% TODO: in case the best_recognized_list is empty... how is this
		% possible?
		if numel(best_recognized_list) ~= 0
			for n=1:size(traindata,1)
				Dt(n) = (Dt(n)*exp(-alpha(i)*labels_masked(n)*best_recognized_list(n)));
			end
		end
		
		% normalize Dt so it will be a probability distribution (it sums up
		% to 1)
		Dt = Dt./sum(Dt);

	end

% 	fprintf('\tFound best models and alpha:\n')
% 	modelIdx
% 	alpha
end