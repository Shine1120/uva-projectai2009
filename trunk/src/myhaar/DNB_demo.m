function DNB_demo(docreate)%(all_money_front, all_money_rear, all_labels)


dotrain = 1;

T				= 10;	% number of hypothesis for AdaBoost	
leave_n_out		= 50;	% size of test-set
hold_n_out		= 100;  % size of validation-set
trials			= 2;	% 20 fold experiment
repetitions		= 1;	% 20 for repeating the k-fold experiment
unfitaccept		= 0.04; % ensures better than 5% error on unfit class
nr_random_loc	= 2;





hcorrect_front = [0 0];
hcorrect_rear = [0 0];
hcorrectbayes = [0 0];
hn = [0 0];

best_model_list1 = [];
best_alpha_list1 = [];
best_model_list2 = [];
best_alpha_list2 = [];

fprintf('Loading Images... ');
tic;
load all_labels.mat
load all_money_front.mat
load all_money_rear.mat
toc;

if (docreate)
	fprintf('Generate Rectangle Patterns... \n')
	patterns = save_patterns(190,350); %generate the patterns
else
	fprintf('Loading Rectangle Patterns... \n')
	load patterns.mat
end

size(all_money_front)
size(all_money_rear)

for q=1:repetitions
	if q ~= 1
		load all_money_front.mat
		load all_money_rear.mat
	end

	fprintf('Run %d of %d\n', q, repetitions);

	if (dotrain)
		money_front = []; money_rear = []; eigen_front = []; eigen_rear = [];
		trainProjection_front = []; trainProjection_rear = [];
	end

	
	
	allidx = randperm(length(all_labels));
	holdoutset = allidx(1:hold_n_out);
	allidx = allidx(hold_n_out+1:end);


	money_front_holdout = all_money_front(:,:,holdoutset);
	money_rear_holdout = all_money_rear(:,:,holdoutset);

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
		if i ~= 1
			load all_money_front.mat
			load all_money_rear.mat
		end
		
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
		end

		money_front_train = all_money_front(:,:,trainset);
		money_rear_train = all_money_rear(:,:,trainset);
		
		money_front_test = all_money_front(:,:,testset);
		money_rear_test = all_money_rear(:,:,testset);

		train_labels = all_labels(trainset);
		test_labels = all_labels(testset);
		
		clear all_money_front
		clear all_money_rear

		
		%labels = all_labels(trainset);

		% determine EigenMoney - from the fit class or from all data?
		%l = find(labels==1, EigenConstructFrom);		
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%  ADABOOST  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		% for each image region, calculate the eigen faces
		fprintf('Generate Haar-Features... \n')
		
		[Ny , Nx , P] = size(money_front_train);		
		F = generate_features(Ny, Nx, patterns, nr_random_loc);
		
		fprintf('AdaBoost using SVM for %d hypothesis... \n', T)		
		tic;		
		[alpha1, modelIdx1, model1] = adaboost(F, money_front_train, T, patterns, train_labels);
		[alpha2, modelIdx2, model2] = adaboost(F, money_rear_train, T, patterns, train_labels);
		toc;

		model_front = struct('model',model1,'weights',alpha1,'best_feature_id', ...
			modelIdx1,'patterns',patterns,'features',F);
		
		model_rear = struct('model',model2,'weights',alpha2,'best_feature_id', ...
			modelIdx2,'patterns',patterns,'features',F);

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		


		%% -------------- TEST PART ----------------

		for j=1:length(test_labels)
			testlabel = test_labels(j);
			testnote_front = money_front_test(:,:,j);
			testnote_rear = money_rear_test(:,:,j);
						
			recognized_front = eval_bills(model_front, testlabel, testnote_front);		
			recognized_rear = eval_bills(model_rear, testlabel, testnote_rear);		

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
				best_model_front = model_front;
				best_model_rear = model_rear;
				best_alpha1 = alpha1;
				best_alpha2 = alpha2;
				best_modelIdx1 = modelIdx1;
				best_modelIdx2 = modelIdx2;
				Best_F = F;
				
				best_model_list1 = [best_model_list1; modelIdx1];
				best_alpha_list1 = [best_alpha_list1; alpha1];
				best_model_list2 = [best_model_list2; modelIdx2];
				best_alpha_list2 = [best_alpha_list2; alpha2];
			end;
		else
			if (thisbayes(2) < correctbest(2))
				correctbest = thisbayes;
				best_model_front = model_front;
				best_model_rear = model_rear;
				best_alpha1 = alpha1;
				best_alpha2 = alpha2;
				best_modelIdx1 = modelIdx1;
				best_modelIdx2 = modelIdx2;
				Best_F = F;

				best_model_list1 = [best_model_list1; modelIdx1];
				best_alpha_list1 = [best_alpha_list1; alpha1];
				best_model_list2 = [best_model_list2; modelIdx2];
				best_alpha_list2 = [best_alpha_list2; alpha2];
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

	F = Best_F;
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
		testnote_front = money_front_holdout(:,:,j);
		testnote_rear = money_rear_holdout(:,:,j);
		
		recognized_front = eval_bills(model_front, testlabel, testnote_front);		
		recognized_rear = eval_bills(model_rear, testlabel, testnote_rear);		
		
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
Model_Front = best_model_list1
Alpha_Front = best_alpha_list1
Model_Rear = best_model_list2
Alpha_Rear = best_alpha_list2

n=hn
%error_naive_Bayes_all = 1-hcorrectall./hn
error_naive_Bayes = 1-hcorrectbayes./hn
error_front = 1-hcorrect_front./hn
error_rear = 1-hcorrect_rear./hn
%error_both = 1-correct_both./n
end