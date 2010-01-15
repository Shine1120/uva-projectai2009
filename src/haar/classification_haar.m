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
    fit   = [money_dir '/fit/'];
    unfit = [money_dir '/unfit/'];	
	
	
    %TRAIN - COMMENT OUT WHEN THE MODELS ARE SAVED_________________________
    for i=1:rounds
        for j=1:2 % loop for front and rear                  
            [labels, ImgSet, nx, ny] = preprocess(1,i,1,rounds,fit,unfit,j); % get the train matrix   
            %the result structure retrieved from the AdaBoost cascade
            [alpha_weights, best_feature_indexs, rect_patterns, F, model] = train_haar(T, labels, ImgSet);
            %save the obtained model(the weak classifiers corresponding to the features chosen)
            model = struct('model',model, 'weights',alpha_weights,'best_feature_id', ...
					best_feature_indexs,'patterns',rect_patterns,'features',F);
            %classify the new data using another cascade and evaluate             
            if (mod(j,2)==0)                 
                string_name = ['model_' money_dir sprintf('_rear%d.mat', i)];
                save(string_name, 'model');   
            elseif (mod(j,2)~=0) 
                string_name = ['model_' money_dir sprintf('_front%d.mat', i)];
                save(string_name, 'model');           
            end
        end
    end

    %EVALUATION____________________________________________________________
    for i=1:rounds         
        for j=1:2 % loop for front and rear 
            [labels, ImgSet, nx, ny] = preprocess(1,i,0,rounds,fit,unfit,j); % get the test matrix   

            %load the corresponding model
            if (mod(j,2)==0)                 
                string_name = ['model_' money_dir sprintf('_rear%d.mat', i)];
                load(string_name);
                [tp_rear(i), fp_rear(i), error_rear(i), classifier_rear]...
                                        = eval_bills(model, labels, ImgSet,0);
            elseif (mod(j,2)~=0) 
                string_name = ['model_' money_dir sprintf('_front%d.mat', i)];
                load(string_name);
                [tp_front(i), fp_front(i), error_front(i), classifier_front]...
                                        = eval_bills(model, labels, ImgSet,0);
			end;
		end
		both_val = 1-(1-classifier_front).*(1-classifier_rear); 				
	end
	
	[tp_both(i), fp_both(i), error_both(i), classifier_both]...
							 = eval_bills(model, labels, ImgSet, both_val);
    
    %average over all results to obtain the performance of the classifier
    true_positive_rear  = mean(tp_rear)
    true_positive_front = mean(tp_front)
    true_positive_both  = mean(tp_both)
    
    false_positive_rear  = mean(fp_rear)
    false_positive_front = mean(fp_rear)
    false_positive_both  = mean(fp_both)
       
    error_rear  = mean(error_rear)
    error_front = mean(error_front)
    error_both  = mean(error_both)
end