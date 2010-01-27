function predictions = eval_pca(money_front_holdout, money_rear_holdout, labels, do5or10)

	docreate = 1;
	
	if docreate
		fprintf('Creating Image Regions... ');
		tic;
		load all_labels.mat
		load all_money_front.mat
		load all_money_rear.mat
		all_money_front_regions = genImageRegions(all_money_front,1);
		clear all_money_front
		save all_money_front_regions.mat all_money_front_regions;
		all_money_rear_regions = genImageRegions(all_money_rear,2);
		clear all_money_rear
		save all_money_rear_regions.mat all_money_rear_regions;
		toc;
	else
		fprintf('Loading Image Regions... \n');
		tic;
		load all_labels.mat
		load all_money_front_regions.mat
		load all_money_rear_regions
		toc;
	end


	predictions = [];

	if (do5or10 == 10)
		load T1_best_alpha_front.mat
		load T1_best_idx_front.mat
		load T1_best_model_front.mat
		load T1_best_eigen_front.mat eigen_front_regions

		load T1_best_alpha_rear.mat 
		load T1_best_idx_rear.mat 
		load T1_best_model_rear.mat 
		load T1_best_eigen_rear.mat eigen_rear_regions
	elseif (do5or10 == 5)
		load E1_best_alpha_front.mat
		load E1_best_idx_front.mat
		load E1_best_model_front.mat
		load E1_best_eigen_front.mat eigen_front_regions

		load E1_best_alpha_rear.mat 
		load E1_best_idx_rear.mat 
		load E1_best_model_rear.mat 
		load E1_best_eigen_rear.mat eigen_rear_regions
	end

	predictions = zeros(length(labels),1);
	
	for j=1:length(labels)
		
		testnote_front_regions = all_money_front_regions(j,:,:);
		testnote_rear_regions = all_money_rear_regions(j,:,:);
		
		
		recognized_front = AdaBoostSVMPredict(testnote_front_regions, ... 
											  eigen_front_regions, ... 
											  alpha1, modelIdx1, model_front);
		recognized_rear = AdaBoostSVMPredict(testnote_rear_regions, ... 
											 eigen_rear_regions, ... 
											 alpha2, modelIdx2, model_rear);
		
		
		% naive bayes approach for combining front and rear predictions
		class = 1-(1-recognized_front)*(1-recognized_rear); 
		
		% storing predictions
		predictions(j) = class;
		
	end
end
