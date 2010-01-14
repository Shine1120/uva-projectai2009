function DNB_demo(docreate)%(all_money_front, all_money_rear, all_labels)


dotrain = 1;

T				= 15;	% number of hypothesis for AdaBoost	
leave_n_out		= 50;	% size of test-set
hold_n_out		= 100;  % size of validation-set
trials			= 20;	% 20 fold experiment
repetitions		= 1;	% 20 for repeating the k-fold experiment
unfitaccept		= 0.04; % ensures better than 5% error on unfit class

% how many eigenvectors to use
NumberOfEigenVectors = 30;
% how many images to construct eigenmoney
EigenConstructFrom = 50;
%EigenConstructFrom = 35; % doesn't change the results much...


hcorrect_front = [0 0];
hcorrect_rear = [0 0];
hcorrect_both = [0 0];
hcorrectbayes = [0 0];
%hcorrectall = [0 0];
hn = [0 0];


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
	fprintf('Loading Image Regions... ');
	tic;
	load all_labels.mat
	load all_money_front_regions.mat
	load all_money_rear_regions
	toc;
end


for q=1:repetitions

	fprintf('Run %d of %d\n', q, repetitions);

	if (dotrain)
		money_front = []; money_rear = []; eigen_front = []; eigen_rear = [];
		trainProjection_front = []; trainProjection_rear = [];
	end

	
	
	allidx = randperm(length(all_labels));
	holdoutset = allidx(1:hold_n_out);
	allidx = allidx(hold_n_out+1:end);


	money_front_holdout = all_money_front_regions(holdoutset,:,:);
	money_rear_holdout = all_money_rear_regions(holdoutset,:,:);

	holdout_labels = all_labels(holdoutset);

	%% ------------- TRAINING PART -------------------

	fprintf('Training models...\n');

	% leave-one-out...
	correct_front = [0 0];
	correct_rear = [0 0];
	correctbayes = [0 0];
	correctbest = [1 1];
	n = [0 0];

	for i=1:trials
		thisbayes = [0 0];
		thisn = [0 0];
		if (trials == length(allidx) && leave_n_out == 1)
			% do all (leave-one-out method)
			testset = allidx(i);
			trainset = allidx;
			trainset(i) = [];
		else
			% cross-val on random subset
			idx = randperm(length(allidx));
			testset = allidx(idx(1:leave_n_out));
			trainset = allidx(idx(leave_n_out+1:end));
		end;

		money_front_train = all_money_front_regions(trainset,:,:);
		money_rear_train = all_money_rear_regions(trainset,:,:);
		
		money_front_test = all_money_front_regions(testset,:,:);
		money_rear_test = all_money_rear_regions(testset,:,:);

		train_labels = all_labels(trainset);
		test_labels = all_labels(testset);
		
		
		
		%labels = all_labels(trainset);

		% determine EigenMoney - from the fit class or from all data?
		%l = find(labels==1, EigenConstructFrom);
		l = 1:EigenConstructFrom;
		
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%  ADABOOST  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		% for each image region, calculate the eigen faces
		fprintf('Generate Eigenface Regions... \n')
		eigen_front_regions = genEigenFaceRegions(money_front_train(l,:,:));
		eigen_rear_regions = genEigenFaceRegions(money_rear_train(l,:,:));

		% for each eigen region, train a model
		models_front = trainRegionsSVM(money_front_train, train_labels, eigen_front_regions, NumberOfEigenVectors);
		models_rear = trainRegionsSVM(money_rear_train, train_labels, eigen_rear_regions, NumberOfEigenVectors);
		
		%save models.mat models

		fprintf('AdaBoost using SVM for %d hypothesis... \n', T)		
		tic;		
		[alpha1 modelIdx1 model_front] = AdaBoostSVM(models_front, money_front_train, eigen_front_regions, train_labels, T);
		[alpha2 modelIdx2 model_rear] = AdaBoostSVM(models_rear, money_rear_train, eigen_rear_regions, train_labels, T);
		toc;
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		


		%% -------------- TEST PART ----------------

		for j=1:length(test_labels)
			testlabel = test_labels(j);
			testnote_front_regions = money_front_test(j,:,:);
			testnote_rear_regions = money_rear_test(j,:,:);
						
			recognized_front = AdaBoostSVMPredict(testnote_front_regions, eigen_front_regions, alpha1, modelIdx1, model_front);
			recognized_rear = AdaBoostSVMPredict(testnote_rear_regions, eigen_rear_regions, alpha2, modelIdx2, model_rear);

			n(testlabel+1) = n(testlabel+1)+1;
			thisn(testlabel+1) = thisn(testlabel+1)+1;

			class = recognized_front;
			correct_front(testlabel+1) = correct_front(testlabel+1) + (testlabel==class);

			class = recognized_rear;
			correct_rear(testlabel+1) = correct_rear(testlabel+1) + (testlabel==class);

			% naive Bayes: multiply probabilities for two-class problem
			%             prob_est = prob_est_front.*prob_est_rear;
			%             [mx class] = max(prob_est);
			%             class = (class==2);
			% for non-probabilistic svm:
			class = 1-(1-recognized_front)*(1-recognized_rear); % if not probabilistic svm
			%fprintf('naive Bayes: %d ', class);
			%prob_est

			correctbayes(testlabel+1) = correctbayes(testlabel+1) + (testlabel==class);
			thisbayes(testlabel+1) = thisbayes(testlabel+1) + (testlabel==class);

		end; % testset

		if (thisn(1) == 0)
			thisn(1) = 1;
		end;
		if (thisn(2) == 0)
			thisn(2) = 1;
		end;
		thisbayes = 1-thisbayes./thisn;
		if (thisbayes(2) < unfitaccept)
			if (thisbayes(1)<correctbest(1) || correctbest(2)>=unfitaccept)
				correctbest = thisbayes;
				best_eigen_front = eigen_front_regions;
				best_eigen_rear = eigen_rear_regions;
				best_model_front = model_front;
				best_model_rear = model_rear;
				best_alpha1 = alpha1;
				best_alpha2 = alpha2;
				best_modelIdx1 = modelIdx1
				best_modelIdx2 = modelIdx2				
			end;
		else
			if (thisbayes(2) < correctbest(2))
				correctbest = thisbayes;
				best_eigen_front = eigen_front_regions;
				best_eigen_rear = eigen_rear_regions;
				best_model_front = model_front;
				best_model_rear = model_rear;
				best_alpha1 = alpha1;
				best_alpha2 = alpha2;
				best_modelIdx1 = modelIdx1
				best_modelIdx2 = modelIdx2				
			end
		end
		
		clear money_front_train;
		clear money_rear_train;
		clear money_front_test;
		clear money_rear_test;
	end; % trials
	n
	%    error_naive_Bayes_all = 1-correctall./n
	error_naive_Bayes = 1-correctbayes./n
	error_front = 1-correct_front./n
	error_rear = 1-correct_rear./n
	error_best_classifier = correctbest
	%    error_both = 1-correct_both./n


	%% -------------- VALIDATION PART ----------------

	fprintf('testing model...\n');

	model_front = best_model_front;
	model_rear = best_model_rear;
	eigen_front_regions = best_eigen_front;
	eigen_rear_regions = best_eigen_rear;

	
	alpha1 = best_alpha1;
	alpha2 = best_alpha2;
	modelIdx1 = best_modelIdx1;
	modelIdx2 =	best_modelIdx2;
	
	correct_front = [0 0];
	correct_rear = [0 0];
	correctbayes = [0 0];
	n = [0 0];

	for j=1:length(holdout_labels)
		testlabel = holdout_labels(j);
		testnote_front_regions = money_front_holdout(j,:,:);
		testnote_rear_regions = money_rear_holdout(j,:,:);
		
		recognized_front = AdaBoostSVMPredict(testnote_front_regions, eigen_front_regions, alpha1, modelIdx1, model_front);
		recognized_rear = AdaBoostSVMPredict(testnote_rear_regions, eigen_rear_regions, alpha2, modelIdx2, model_rear);
		
		hn(testlabel+1) = hn(testlabel+1)+1;
		n(testlabel+1) = n(testlabel+1)+1;

		class = recognized_front;
		hcorrect_front(testlabel+1) = hcorrect_front(testlabel+1) + (testlabel==class);
		correct_front(testlabel+1) = correct_front(testlabel+1) + (testlabel==class);

		class = recognized_rear;
		hcorrect_rear(testlabel+1) = hcorrect_rear(testlabel+1) + (testlabel==class);
		correct_rear(testlabel+1) = correct_rear(testlabel+1) + (testlabel==class);

		% naive Bayes: multiply probabilities for two-class problem
		%         prob_est = prob_est_front.*prob_est_rear;
		%         [mx class] = max(prob_est);
		%         class = (class==2);
		% for non-probabilistic svm:
		class = 1-(1-recognized_front)*(1-recognized_rear); % if not probabilistic svm

		hcorrectbayes(testlabel+1) = hcorrectbayes(testlabel+1) + (testlabel==class);
		correctbayes(testlabel+1) = correctbayes(testlabel+1) + (testlabel==class);

	end; % holdoutset
	n
	if (n(1) == 0)
		n(1) = 1;
	end;
	if (n(2) == 0)
		n(2) = 1;
	end;
	%error_naive_Bayes_all = 1-correctall./n
	error_naive_Bayes = 1-correctbayes./n
	error_front = 1-correct_front./n
	error_rear = 1-correct_rear./n
end; % repetitions

fprintf( 'Final:\n' );

n=hn
%error_naive_Bayes_all = 1-hcorrectall./hn
error_naive_Bayes = 1-hcorrectbayes./hn
error_front = 1-hcorrect_front./hn
error_rear = 1-hcorrect_rear./hn
%error_both = 1-correct_both./n
end