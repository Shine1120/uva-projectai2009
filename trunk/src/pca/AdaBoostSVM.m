function [alpha, modelIdx, models] = AdaBoostSVM(models, traindata, eigen_regions, labels, T)

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
		
		recognized_list = zeros(1,size(traindata,1));
		best_recognized_list = [];
		% find the best model by minimizing the error (with respect to Dt)
		for j=1:length(models)
			model = models(j);
			error_j = 0;
			
			images_region = traindata(:,:,j);
			eigen_region = eigen_regions(:,:,j);
			
			imagesProjection = images_region * eigen_region;

			[recognized, accuracy, prob_est_front] = svmpredict(labels,imagesProjection, model, '-b 0');
						
			error_j = sum(Dt'.* (labels ~= recognized));
			
			
			
			
% 			for k=1:size(traindata,1)
% 				image_region = traindata(k,:,j);
% 				eigen_region = eigen_regions(:,:,j);
% 				imageProjection = image_region * eigen_region;
% 				
% 				[recognized, accuracy, prob_est_front] = svmpredict(1,imageProjection, model, '-b 0');
% 
% 				recognized_list(k) = recognized;
% 				
% 				% calculate total error for classifier k
% 				error_j = error_j + Dt(k)*(labels(k) ~= recognized);
% 				
% 			end
			fprintf('\t\tError model %d is %f\n',j,error_j)
			if (error_j < smallest_error)
				smallest_error = error_j;
				best_model = j;
				best_recognized_list = recognized;
			end
		end
		fprintf('\tBest model for t=%d is %d\n',i, best_model)
		fprintf('\t\tUpdate weights\n')
		modelIdx(i) = best_model;
		
		% update alpha weights
		alpha(i) = 0.5*log((1-smallest_error)/smallest_error); 
		
		% update instance weights
		
		for n=1:size(traindata,1)
			Dt(n) = (Dt(n)*exp(-alpha(i)*labels_masked(n)*best_recognized_list(n)));
		end
		
		% normalize Dt so it will be a probability distribution (it sums up
		% to 1)
		Dt = Dt./sum(Dt);

	end

	fprintf('\tFound best models and alpha:\n')
	modelIdx
	alpha
end