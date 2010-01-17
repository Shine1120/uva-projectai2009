%CLASSIFIES THE DATA BASED ON THE HAAR FEATURES AND USING ADABOOST CASCADE 
%FOR SELECTING THE BEST FEATURES TO BE USED
%INPUT:
%       T      -- number of features to be used (not too large :P)
%       rounds -- number of rounds for cross-validation
function classification_haar(T, rounds)
	close all;
	save_patterns(120,85) %generate the patterns
    % Do the CROSS-VALIDATION loop
    money_dir  = 'neur10'; % 'neur05';  
    fit        = [money_dir '/fit/'];
    unfit      = [money_dir '/unfit/'];	
	hold_n_out = 100;
	%define hold-out set 	
	dir_fit_rear    = dir([fit 'r*.bmp']);
	dir_unfit_rear  = dir([unfit 'r*.bmp']);
	dir_fit_front   = dir([fit 'f*.bmp']);
	dir_unfit_front = dir([unfit 'f*.bmp']);
	all_labels      = [ones(1,size(dir_fit_front,1)) zeros(1,size(dir_unfit_front,1))];
	all_id          = randperm(length(all_labels));		
	holdout_id      = all_id(1:hold_n_out);
	rest_id         = all_id(hold_n_out+1:end);	
	%make sure there is at least one unfit/fit in the holdout
	while ( sum(all_labels(holdout_id)==0)==0 || sum(all_labels(holdout_id)==1)==0)
		all_id     = randperm(length(all_labels));		
		holdout_id = all_id(1:hold_n_out);
		rest_id    = all_id(hold_n_out+1:end);	
	end	

	%get images front and images rear
	for i=1:size(dir_fit_rear,1)+size(dir_unfit_rear,1) %save images names for FIT (front/rear)
		if(i<=size(dir_fit_rear,1))
			names_rear{i}  = [fit dir_fit_rear(i).name];
			names_front{i} = [fit dir_fit_front(i).name];
		else
			names_rear{i}  = [unfit dir_unfit_rear(i-size(dir_fit_rear,1)).name];
			names_front{i} = [unfit dir_unfit_front(i-size(dir_fit_rear,1)).name];
		end
	end
	
	if (rounds==1)
		slice = 100;
	else
		slice = round(length(rest_id)/rounds);		
	end
    for i=1:rounds
		%TRAIN - COMMENT OUT WHEN THE MODELS ARE SAVED_________________________
		ids   = randperm(length(rest_id));
		train = rest_id(ids(1:slice));
		test  = rest_id(ids(slice+1:end));		
		%make sure there is at least one unfit/fit in the test
		while ( sum(all_labels(test)==0)==0 || sum(all_labels(test)==1)==0)
			ids   = randperm(length(rest_id));
			train = rest_id(ids(1:slice));
			test  = rest_id(ids(slice+1:end));		
		end	

        for j=1:2 % loop for front and rear            
			if (mod(j,2)==0) %rear		
				labels_train           = all_labels(train);
				labels_test_rear       = all_labels(test);
 				[ImgTrain, nx, ny]     = preprocess(1,names_rear(train)); 
				[ImgTest_rear, nx, ny] = preprocess(1,names_rear(test)); 
			else
				labels_train            = all_labels(train);
				labels_test_front       = all_labels(test);
				[ImgTrain, nx, ny]      = preprocess(1,names_front(train));
				[ImgTest_front, nx, ny] = preprocess(1,names_front(test)); 
			end;
            %the result structure retrieved from the AdaBoost cascade
            [alpha_weights, best_feature_indexs, rect_patterns, F, all_models] = train_haar(T, labels_train, ImgTrain);
            %save the obtained model(the weak classifiers corresponding to the features chosen)
            model = struct('model',all_models,'weights',alpha_weights,'best_feature_id', ...
					best_feature_indexs,'patterns',rect_patterns,'features',F);
		if (i==1 && j==1)
			voted_rear  = zeros(1, size(F,2)); 
			voted_front = zeros(1, size(F,2));
		end
		
		%EVALUATION ____________________________________________________________			
            %classify the new data using another cascade and evaluate             
            if (mod(j,2)==0)                 
                string_name = ['model_' money_dir sprintf('_rear%d.mat', i)];
                save(string_name, 'model');   
			    %load(string_name);
                [tp_rear(i),fp_rear(i),error_rear(i),classifier_rear]=eval_bills(model,labels_test_rear,ImgTest_rear,0);
            elseif (mod(j,2)~=0) 
                string_name = ['model_' money_dir sprintf('_front%d.mat', i)];
                save(string_name, 'model');
				%load(string_name);
                [tp_front(i),fp_front(i),error_front(i),classifier_front]=eval_bills(model,labels_test_front,ImgTest_front,0);
			end
			
		%VOTE THE BEST FEATURES TO BUILD THE BEST MODEL EVER_____________________
 			if (mod(j,2)==0)
 				voted_rear(best_feature_indexs) = voted_rear(best_feature_indexs)+1;   
 			else
 				voted_front(best_feature_indexs) = voted_front(best_feature_indexs)+1;
			end;
 		end

		%test rear&front classifier -- just labels matter because the predications are already made
		both_val(i,:) = 1-(1-classifier_front).*(1-classifier_rear); 				
		[tp_both(i),fp_both(i),error_both(i),both_val(i,:)]=eval_bills(model,...
				labels_test_front, ImgTest_front, both_val(i,:));		
	end	
	true_positive_rear  = mean(tp_rear)
    false_positive_rear = mean(fp_rear)
    error_rear          = mean(error_rear)
    
	true_positive_front  = mean(tp_front)
	false_positive_front = mean(fp_rear)
	error_front          = mean(error_front)
    
	true_positive_both  = mean(tp_both)   
	false_positive_both = mean(fp_both)
    error_both          = mean(error_both)	
	
    %EVAL THE BEST MODEL FRONT, THE BEST MODEL REAR AND THE BEST MODEL BOTH
	%Test on the hold out
	labels_holdout             = all_labels(holdout_id);
	[ImgHoldout_front, nx, ny] = preprocess(1,names_front(holdout_id));
	[ImgHoldout_rear, nx, ny]  = preprocess(1,names_rear(holdout_id)); 
	
	
	
	[sorted_rear indexes_rear]   = sort(voted_rear,'descend'); 
 	[sorted_front indexes_front] = sort(voted_front,'descend');
	sorted_rear(1:T)
	indexes_rear(1:T)
	sorted_front(1:T)
	indexes_front(1:T)
	model = struct('model', all_models, 'weights', [T-1:-1:1 0.5]./T, 'best_feature_id', ...
					indexes_rear(1:T),'patterns',rect_patterns,'features',F);
	save(['model_' money_dir '_handout_rear'], 'model');
	[true_positive_holdout_rear, false_postive_holdout_rear, error_holdout_rear, ...
		classifier_holdout_rear] = eval_bills(model,labels_holdout,ImgHoldout_rear,0);

	model = struct('model', all_models, 'weights', [T-1:-1:1 0.5]./T, 'best_feature_id', ...
					indexes_front(1:T),'patterns',rect_patterns,'features',F);
	save(['model_' money_dir '_handout_front'], 'model');
	[true_positive_holdout_front, false_postive_holdout_front, error_holdout_front, ...
		classifier_holdout_front] = eval_bills(model,labels_holdout,ImgHoldout_front,0);
	
	%test rear&front classifier -- just labels matter because the predications are already made
	both_holdout = 1-(1-classifier_holdout_front).*(1-classifier_holdout_rear); 				
	[true_positive_holdout_both, false_postive_holdout_both, error_holdout_both, ...
		classifier_holdout_both] = eval_bills(model,labels_holdout,ImgHoldout_front,both_holdout);
	true_positive_holdout_rear
	false_postive_holdout_rear
	error_holdout_rear
	
	true_positive_holdout_front
	false_postive_holdout_front
	error_holdout_front

	true_positive_holdout_both	
	false_postive_holdout_both
	error_holdout_both
end