%CLASSIFIES THE DATA BASED ON THE HAAR FEATURES AND USING ADABOOST CASCADE 
%FOR SELECTING THE BEST FEATURES TO BE USED
%INPUT:
%       T              -- number of features to be used (not too large :P)
%       rounds         -- number of rounds for cross-validation
%		pattern_scales -- number of different scales generated for each	pattern
%__________________________________________________________________________
function classification_haar(T, rounds, pattern_scales)
	close all;
    money_dir       = 'neur10'; % 'neur05';  
    fit             = ['moneyDivided/wholeplusborder/' money_dir '/fit/'];
    unfit           = ['moneyDivided/wholeplusborder/' money_dir '/unfit/'];	
	hold_n_out      = 80;
	slice           = 80;
	repetitions     = 5;
	ySegms			= 12;
	xSegms			= 5;
	dir_fit_rear    = dir([fit 'r*.bmp']);
	dir_unfit_rear  = dir([unfit 'r*.bmp']);
	dir_fit_front   = dir([fit 'f*.bmp']);
	dir_unfit_front = dir([unfit 'f*.bmp']);
	all_labels      = [zeros(1,size(dir_fit_front,1)) ones(1,size(dir_unfit_front,1))]';
 	%GET LABELS OF THE IMAGES FRONT AND REAR_______________________________
	for i=1:size(dir_fit_rear,1)+size(dir_unfit_rear,1) 
		if(i<=size(dir_fit_rear,1))
			names_rear{i}  = strcat(fit,dir_fit_rear(i).name);
			names_front{i} = strcat(fit,dir_fit_front(i).name);
		else
			names_rear{i}  = strcat(unfit,dir_unfit_rear(i-size(dir_fit_rear,1)).name);
			names_front{i} = strcat(unfit,dir_unfit_front(i-size(dir_fit_rear,1)).name);
		end
	end		
	%CONVOLVE IMAGES WITH THE PATTERNS_____________________________________
%     patterns           = save_patterns(250,400,pattern_scales);						
%     convolutions_rear  = preprocess(ySegms,xSegms,1,names_rear,patterns,'rear'); 
%     convolutions_front = preprocess(ySegms,xSegms,1,names_front,patterns,'front'); 
 	load 'convolved_images_front'
 	load 'convolved_images_rear'
 	load 'patterns'	
	min_error        = 1;
	best_model_index = 0;
	%START REPETITIONS OF CROSSVALIDATION__________________________________
	for r=1:repetitions	
		%DEFINE HOLDOUT SET________________________________________________ 	
		all_id          = randperm(length(all_labels));		
		holdout_id      = all_id(1:hold_n_out);
		rest_id         = all_id(hold_n_out+1:end);	
		%AT LEASt ONE FIT/UNFIT IMAGE IN THE HOLDOUT SET___________________
		while ( sum(all_labels(holdout_id)==0)==0 || sum(all_labels(holdout_id)==1)==0)
			all_id     = randperm(length(all_labels));		
			holdout_id = all_id(1:hold_n_out);
			rest_id    = all_id(hold_n_out+1:end);	
		end	 
		tp_rear  = zeros(1,rounds); tn_rear = zeros(1,rounds); error_rear = zeros(1,rounds);
		tp_front = zeros(1,rounds); tn_front = zeros(1,rounds); error_front = zeros(1,rounds);
		tp_both  = zeros(1,rounds); tn_both = zeros(1,rounds); error_both = zeros(1,rounds);	
		%START CROSSVALIDATION_____________________________________________
		for i=1:rounds
			fprintf('\t Crossvalidation -- round:%d \t repetition:%d\n',i,r)		
			%TRAIN_________________________________________________________
			ids      = randperm(length(rest_id));
			testset  = rest_id(ids(1:slice));
			trainset = rest_id(ids(slice+1:end));		
			%AT LEASt ONE FIT/UNFIT IMAGE IN THE TEST SET__________________
			while ( sum(all_labels(testset)==0)==0 || sum(all_labels(testset)==1)==0)
				ids      = randperm(length(rest_id));
				testset  = rest_id(ids(1:slice));
				trainset = rest_id(ids(slice+1:end));		
			end		
			labels_train = all_labels(trainset);
			labels_test  = all_labels(testset);		
			for j=1:2 %LOOP FOR REAR AND FRONT            
				if (mod(j,2)==0) %FOR REAR
					ImgTrain = convolutions_rear(trainset,:); 
					ImgTest  = convolutions_rear(testset,:); 
				else %FOR FRONT
					ImgTrain = convolutions_front(trainset,:);
					ImgTest  = convolutions_front(testset,:); 
				end;		
				%THE RESULTS RETURNED BY ADABOOST CASCADE__________________
				[alpha_weights,best_feature_indexs,mean_fit,mean_unfit,cov_fit,cov_unfit] = ...
						adaboost(ySegms,xSegms,ImgTrain,T,patterns,labels_train);
				model = struct('weights',alpha_weights,'best_ids', best_feature_indexs,...
								'mean_fit',mean_fit,'cov_fit',cov_fit,'mean_unfit',mean_unfit,'cov_unfit',cov_unfit);
			%EVALUATION ___________________________________________________	
			%CLASSIFY THE NEW DATA USING THE STRONG CLASSIFIER_____________              
				if (mod(j,2)==0)                 
					string_name = ['model_' money_dir sprintf('_rear%d.mat', rounds*(r-1)+i)];
					save(string_name, 'model');   
					[tp_rear(i),tn_rear(i),error_rear(i),classifier_rear]=eval_bills(model,labels_test,ImgTest,0,0);
				elseif (mod(j,2)~=0) 
					string_name = ['model_' money_dir sprintf('_front%d.mat',rounds*(r-1)+i)];
					save(string_name, 'model');
					[tp_front(i),tn_front(i),error_front(i),classifier_front]=eval_bills(model,labels_test,ImgTest,0,0);
				end
			%VOTE THE BEST FEATURES TO BUILD THE BEST MODEL EVER___________
				if (i==1 && j==1 && r==1)
					voted_rear  = zeros(2,size(mean_fit,2));  
					voted_front = zeros(2,size(mean_fit,2));  
				end
				if (mod(j,2)==0)
					voted_rear(1,best_feature_indexs) = voted_rear(1,best_feature_indexs)+alpha_weights;
					voted_rear(2,best_feature_indexs) = voted_rear(2,best_feature_indexs)+1;
				else
					voted_front(1,best_feature_indexs) = voted_front(1,best_feature_indexs)+alpha_weights;
					voted_front(2,best_feature_indexs) = voted_front(2,best_feature_indexs)+1;
				end;
			end
			%REAR&FRONT CLASSIFIERS - JUST LABLES ARE NEEDED_______________  
			both_val(i,:) = 1-(1-classifier_front).*(1-classifier_rear); 				
			[tp_both(i),tn_both(i),error_both(i),both_val(i,:)]=eval_bills(model,...
					labels_test, ImgTest, both_val(i,:),0);		
			if error_both(i)<=min_error
				min_error = error_both(i);
				best_model_index = rounds*(r-1)+i;
			end	
		end		
		%COMPUTE THE MEAN OF THE RESULTS FROM THE CORSSVALIDATION__________
		tpRear(r)    = mean(tp_rear);
		tnRear(r)    = mean(tn_rear);
		fnRear(r)    = mean(1 - tp_rear);
		fpRear(r)    = mean(1 - tn_rear);
		errorRear(r) = mean(error_rear);
		
		tpFront(r)    = mean(tp_front);
		tnFront(r)    = mean(tn_front);
		fnFront(r)    = mean(1 - tp_front);
		fpFront(r)    = mean(1 - tn_front);
		errorFront(r) = mean(error_front);
		
		tpBoth(r)    = mean(tp_both);
		tnBoth(r)    = mean(tn_both);
		fnBoth(r)    = mean(1 - tp_both);
		fpBoth(r)    = mean(1 - tn_both);
		errorBoth(r) = mean(error_both);		
		%EVAL THE BESTS(FRONT/REAR/BOTH)___________________________________
		labels_holdout   = all_labels(holdout_id);
		ImgHoldout_front = convolutions_front(holdout_id,:);
		ImgHoldout_rear  = convolutions_rear(holdout_id,:); 

		mask_rear                 = (voted_rear(2,:)==0);
		voted_rear(2,mask_rear)   = 1;
		mask_front                = (voted_front(2,:)==0);
		voted_front(2,mask_front) = 1;
		[sorted_rear indexes_rear]   = sort((voted_rear(1,:)./voted_rear(2,:)),'descend'); 
		[sorted_front indexes_front] = sort((voted_front(1,:)./voted_front(2,:)),'descend');
		voted_weights_rear  = sorted_rear(1:T)
		voted_indexes_rear  = indexes_rear(1:T)
		voted_weights_front = sorted_front(1:T)
		voted_indexes_front = indexes_front(1:T)
		%LOAD THE BEST MODEL FROM THE CROSSVALIDAITON______________________
		figure;hold on;
		model_name = ['model_' money_dir sprintf('_rear%d.mat', best_model_index)];
		load(model_name);
		model_rear = struct('weights', voted_weights_rear, 'best_ids', indexes_rear(1:T),...
					'mean_fit',model.mean_fit,'cov_fit',model.cov_fit,'mean_unfit',...
					 model.mean_unfit,'cov_unfit',model.cov_unfit);				
		save(['model_' money_dir '_handout_rear.mat'], 'model_rear');
		[tp_holdout_rear(r), tn_holdout_rear(r), error_holdout_rear(r), ...
			classifier_holdout_rear] = eval_bills(model_rear,labels_holdout,ImgHoldout_rear,0,'r');
		model_name = ['model_' money_dir sprintf('_front%d.mat', best_model_index)];
		load(model_name);	
		model_front = struct('weights',voted_weights_front, 'best_ids',indexes_front(1:T),...
					  'mean_fit',model.mean_fit,'cov_fit',model.cov_fit,'mean_unfit',...
					  model.mean_unfit,'cov_unfit',model.cov_unfit);
		save(['model_' money_dir '_handout_front.mat'], 'model_front');
		[tp_holdout_front(r), tn_holdout_front(r), error_holdout_front(r), ...
			classifier_holdout_front] = eval_bills(model_front,labels_holdout,ImgHoldout_front,0,'g');
		%REAR&FRONT CLASSIFIER - JUST LABELS NEEDED________________________
		both_holdout = 1-(1-classifier_holdout_front).*(1-classifier_holdout_rear); 				
		[tp_holdout_both(r), tn_holdout_both(r), error_holdout_both(r), ...
			classifier_holdout_both] = eval_bills(model_front,labels_holdout,...
										ImgHoldout_front,both_holdout,'b');
		hold off;legend('rear','front');
	end
	plot_regions(ySegms, xSegms, voted_indexes_rear, 'rear');
	plot_regions(ySegms, xSegms, voted_indexes_front, 'front');
	
	%THE MEAN OF THE RESULTS FOR ALL ROUND AND ALL REPETITIONS_____________
	fprintf('\t Correct_Unfit:%f \t Correct_Fit:%f \t Incorrect_Fit:%f \t Incorrect_Unfit:%f \t Error_Rear:%f \n',...
		mean(tpRear),mean(tnRear),mean(fnRear),mean(fpRear),mean(errorRear));
	fprintf('\t Correct_Unfit:%f \t Correct_Fit:%f \t Incorrect_Fit:%f \t Incorrect_Unfit:%f \t Error_Front:%f \n',...
		mean(tpFront),mean(tnFront),mean(fnFront),mean(fpFront),mean(errorFront));
	fprintf('\t Correct_Unfit:%f \t Correct_Fit:%f \t Incorrect_Fit:%f \t Incorrect_Unfit:%f \t Error_Both:%f \n\n',...
		mean(tpBoth),mean(tnBoth),mean(fnBoth),mean(fpBoth),mean(errorBoth));

	fprintf('\t Correct_Unfit:%f \t Correct_Fit:%f \t Incorrect_Fit:%f \t Incorrect_Unfit:%f \t Error_Holdout_Rear:%f \n',...
		mean(tp_holdout_rear), mean(tn_holdout_rear), mean(1-tp_holdout_rear), mean(1-tn_holdout_rear), mean(error_holdout_rear));
	fprintf('\t Correct_Unfit:%f \t Correct_Fit:%f \t Incorrect_Fit:%f \t Incorrect_Unfit:%f \t Error_Holdout_Front:%f \n',...
		mean(tp_holdout_front), mean(tn_holdout_front),mean(1-tp_holdout_front),mean(1-tn_holdout_front), mean(error_holdout_front));
	fprintf('\t Correct_Unfit:%f \t Correct_Fit:%f \t Incorrect_Fit:%f \t Incorrect_Unfit:%f \t Error_Holdout_Both:%f \n',...
		mean(tp_holdout_both), mean(tn_holdout_both), mean(1-tp_holdout_both),mean(1-tn_holdout_both), mean(error_holdout_both));
end