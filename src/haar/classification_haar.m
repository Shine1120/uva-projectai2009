%CLASSIFIES THE DATA BASED ON THE HAAR FEATURES AND USING ADABOOST CASCADE 
%FOR SELECTING THE BEST FEATURES TO BE USED
%INPUT:
%       T              -- number of features to be used (not too large :P)
%       rounds         -- number of rounds for cross-validation
%		pattern_scales -- number of different scales generated for each	pattern
%		locations_nr   -- total number of different locations fr each pattern
function classification_haar(T, rounds, pattern_scales, locations_nr)
	close all;
    % Do the CROSS-VALIDATION loop
    money_dir  = 'neur10'; % 'neur05';  
    fit        = [money_dir '/fit/'];
    unfit      = [money_dir '/unfit/'];	
	hold_n_out = 100;
	slice      = 100;
	%define hold-out set 	
	dir_fit_rear    = dir([fit 'r*.bmp']);
	dir_unfit_rear  = dir([unfit 'r*.bmp']);
	dir_fit_front   = dir([fit 'f*.bmp']);
	dir_unfit_front = dir([unfit 'f*.bmp']);
	all_labels      = [zeros(1,size(dir_fit_front,1)) ones(1,size(dir_unfit_front,1))]';
 	all_id          = randperm(length(all_labels));		
 	holdout_id      = all_id(1:hold_n_out);
 	rest_id         = all_id(hold_n_out+1:end);	
% 	%make sure there is at least one unfit/fit in the holdout
 	while ( sum(all_labels(holdout_id)==0)==0 || sum(all_labels(holdout_id)==1)==0)
 		all_id     = randperm(length(all_labels));		
 		holdout_id = all_id(1:hold_n_out);
 		rest_id    = all_id(hold_n_out+1:end);	
 	end	 
% 	%get images front and images rear
 	for i=1:size(dir_fit_rear,1)+size(dir_unfit_rear,1) %save images names for FIT (front/rear)
 		if(i<=size(dir_fit_rear,1))
 			names_rear{i}  = strcat(fit,dir_fit_rear(i).name);
 			names_front{i} = strcat(fit,dir_fit_front(i).name);
 		else
 			names_rear{i}  = strcat(unfit,dir_unfit_rear(i-size(dir_fit_rear,1)).name);
 			names_front{i} = strcat(unfit,dir_unfit_front(i-size(dir_fit_rear,1)).name);
 		end
	end	
	tp_rear = zeros(1,rounds); fp_rear = zeros(1,rounds); error_rear = zeros(1,rounds);
	tp_front = zeros(1,rounds); fp_front = zeros(1,rounds); error_front = zeros(1,rounds);
	tp_both = zeros(1,rounds); fp_both = zeros(1,rounds); error_both = zeros(1,rounds);	
	
	patterns = save_patterns(85,120,pattern_scales); 
%	patterns = save_patterns(400,250,pattern_scales);
	F        = generate_features(85, 120, patterns, locations_nr); %haar features       	
	for i=1:rounds
		fprintf('\t Crossvalidation -- round %d\n',i)		
		%TRAIN - COMMENT OUT WHEN THE MODELS ARE SAVED_________________________
		ids      = randperm(length(rest_id));
		testset  = rest_id(ids(1:slice));
		trainset = rest_id(ids(slice+1:end));		
		%make sure there is at least one unfit/fit in the test
 		while ( sum(all_labels(testset)==0)==0 || sum(all_labels(testset)==1)==0)
 			ids      = randperm(length(rest_id));
 			testset  = rest_id(ids(1:slice));
 			trainset = rest_id(ids(slice+1:end));		
		end		
		
%EXTRA________FILTER OUT THE FIT IMAGES!!!!!!!___________________________________
% 		labels_train = all_labels(trainset);
% 		trainset     = find(labels_train==1);
% 		labels_train = labels_train(trainset);
%________________________________________________________________________________
		labels_train = all_labels(trainset);
		labels_test  = all_labels(testset);	
        for j=1:2 % loop for front and rear            
			if (mod(j,2)==0) %rear			
				ImgTrain = preprocess(1,names_rear(trainset)); 
 				ImgTest  = preprocess(1,names_rear(testset)); 
			else
 				ImgTrain = preprocess(1,names_front(trainset));
 				ImgTest  = preprocess(1,names_front(testset)); 
			end;						
            %the result structure retrieved from the AdaBoost cascade
			[alpha_weights, best_feature_indexs, all_models] = adaboost(F, ImgTrain, T, patterns, labels_train);

%[alpha_weights, best_feature_indexs, patterns, F, all_models] = train_haar(T, labels_train, ImgTrain,locations_nr);
            %save the obtained model(the weak classifiers corresponding to the features chosen)
           model = struct('model',all_models,'weights',alpha_weights,'best_feature_id', ...
					best_feature_indexs,'patterns',patterns,'features',F);
		
		%EVALUATION ____________________________________________________________			
            %classify the new data using another cascade and evaluate             
			if (mod(j,2)==0)                 
                string_name = ['model_' money_dir sprintf('_rear%d.mat', i)];
                save(string_name, 'model');   
%			    load(string_name);
                [tp_rear(i),fp_rear(i),error_rear(i),classifier_rear]=eval_bills(model,labels_test,ImgTest,0);
            elseif (mod(j,2)~=0) 
                string_name = ['model_' money_dir sprintf('_front%d.mat', i)];
                save(string_name, 'model');
%				load(string_name);
                [tp_front(i),fp_front(i),error_front(i),classifier_front]=eval_bills(model,labels_test,ImgTest,0);
			end
			
		%VOTE THE BEST FEATURES TO BUILD THE BEST MODEL EVER______________________
			if (i==1 && j==1)
				voted_rear  = zeros(1,size(F,2)); %zeros(1, size(model.features,2)); 
				voted_front = zeros(1,size(F,2)); %zeros(1, size(model.features,2)); 
			end

 			if (mod(j,2)==0)
%				voted_rear(model.best_feature_id) = voted_rear(model.best_feature_id)+model.weights;  
 				voted_rear(best_feature_indexs) = voted_rear(best_feature_indexs)+alpha_weights;   
			else
%				voted_front(model.best_feature_id) = voted_front(model.best_feature_id)+model.weights;
 				voted_front(best_feature_indexs) = voted_front(best_feature_indexs)+alpha_weights;
			end;
		end
		%test rear&front classifier -- just labels matter because the predications are already made
		both_val(i,:) = 1-(1-classifier_front).*(1-classifier_rear); 				
		[tp_both(i),fp_both(i),error_both(i),both_val(i,:)]=eval_bills(model,...
				labels_test, ImgTest, both_val(i,:));		
	end		
	fprintf('\t TP_Rear:%f \t FN_Rear:%f \t FP_Rear:%f \t TN_Rear:%f \t Error_Rear:%f \n',...
		mean(tp_rear),(1-mean(tp_rear)),mean(fp_rear),(1-mean(fp_rear)), mean(error_rear));
	fprintf('\t TP_Front:%f \t FN_Front:%f \t FP_Front:%f \t TN_Front:%f \t Error_Front:%f \n',...
		mean(tp_front),(1-mean(tp_front)),mean(fp_front),(1-mean(fp_front)),mean(error_front));
	fprintf('\t TP_Both:%f \t FN_Both:%f \t FP_Both:%f \t TN_Both:%f \t Error_Both:%f \n',...
		mean(tp_both),(1-mean(tp_both)),mean(fp_both),(1-mean(fp_both)),mean(error_both));

    %EVAL THE BEST MODEL FRONT, THE BEST MODEL REAR AND THE BEST MODEL BOTH
	%Test on the hold out
	labels_holdout   = all_labels(holdout_id);
	ImgHoldout_front = preprocess(1,names_front(holdout_id));
	ImgHoldout_rear  = preprocess(1,names_rear(holdout_id)); 
	
	[sorted_rear indexes_rear]   = sort(voted_rear,'descend'); 
 	[sorted_front indexes_front] = sort(voted_front,'descend');
	
	voted_weights_rear  = sorted_rear(1:T)
	voted_indexes_rear  = indexes_rear(1:T)
	voted_weights_front = sorted_front(1:T)
	voted_indexes_front = indexes_front(1:T)
 	model = struct('model', all_models, 'weights', [1:(-0.5/(T-1)):0.5], 'best_feature_id', ...
 					indexes_rear(1:T),'patterns',patterns,'features',F);
				
% 	model = struct('model', model.model, 'weights', [1:(-0.5/(T-1)):0.5], 'best_feature_id', ...
% 	indexes_rear(1:T),'patterns',model.patterns,'features',model.features);

	save(['model_' money_dir '_handout_rear'], 'model');
	plot_features(ImgHoldout_rear,indexes_rear(1:T),F,patterns,'rear',T);
%	plot_features(ImgHoldout_rear,indexes_rear(1:T),model.features,model.patterns,'rear',T);
	[tp_holdout_rear, fp_holdout_rear, error_holdout_rear, ...
		classifier_holdout_rear] = eval_bills(model,labels_holdout,ImgHoldout_rear,0);

 	model = struct('model', all_models, 'weights',[1:(-0.5/(T-1)):0.5], 'best_feature_id', ...
 					indexes_front(1:T),'patterns',patterns,'features',F);
%   	model = struct('model', model.model, 'weights',[1:(-0.5/(T-1)):0.5], 'best_feature_id', ...
%   					indexes_front(1:T),'patterns',model.patterns,'features',model.features);

	save(['model_' money_dir '_handout_front'], 'model');
	plot_features(ImgHoldout_front,indexes_front(1:T),F,patterns,'front',T);
%	plot_features(ImgHoldout_front,indexes_front(1:T),model.features,model.patterns,'front',T);
	[tp_holdout_front, fp_holdout_front, error_holdout_front, ...
		classifier_holdout_front] = eval_bills(model,labels_holdout,ImgHoldout_front,0);
	
	%test rear&front classifier -- just labels matter because the predications are already made
	both_holdout = 1-(1-classifier_holdout_front).*(1-classifier_holdout_rear); 				
	[tp_holdout_both, fp_holdout_both, error_holdout_both, ...
		classifier_holdout_both] = eval_bills(model,labels_holdout,ImgHoldout_front,both_holdout);

	fprintf('\t TP_Holdout_Rear:%f \t FN_Holdout_Rear:%f \t FP_Holdout_Rear:%f \t TN_Holdout_Rear:%f \t Error_Holdout_Rear:%f \n',...
		tp_holdout_rear, (1-tp_holdout_rear), fp_holdout_rear, (1-fp_holdout_rear), error_holdout_rear);
	fprintf('\t TP_Holdout_Front:%f \t FN_Holdout_Front:%f \t FP_Holdout_Front:%f \t TN_Holdout_Front:%f \t Error_Holdout_Front:%f \n',...
		tp_holdout_front, (1-tp_holdout_front),fp_holdout_front,(1-fp_holdout_front), error_holdout_front);
	fprintf('\t TP_Holdout_Both:%f \t FN_Holdout_Both:%f \t FP_Holdout_Both:%f \t TN_Holdout_Both:%f \t Error_Holdout_Both:%f \n',...
		tp_holdout_both,(1-tp_holdout_both), fp_holdout_both,(1-fp_holdout_both), error_holdout_both);
end