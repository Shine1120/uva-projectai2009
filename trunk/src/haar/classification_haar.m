%CLASSIFIES THE DATA BASED ON THE HAAR FEATURES AND USING ADABOOST CASCADE 
%FOR SELECTING THE BEST FEATURES TO BE USED
%INPUT:
%       T      -- number of features to be used (not too large :P)
%       rounds -- number of rounds for cross-validation
function classification_haar(T, rounds)
	save_patterns %generate the patterns
    % Do the CROSS-VALIDATION loop
    money_dir  = 'neur10'; % 'neur05';  
    fit_path   = {'/fit/fit_front/', '/fit/fit_rear/'};
    unfit_path = {'/unfit/unfit_front/', '/unfit/unfit_rear/'};
 
    %TRAIN - COMMENT OUT WHEN THE MODELS ARE SAVED_________________________
    for i=1:rounds
        for j=1:size(fit_path,2)         
            fit   = [money_dir char(fit_path(j))];
            unfit = [money_dir char(unfit_path(j))];
            [labels, ImgSet, nx, ny] = preprocess(0.75,i,1,rounds,fit,unfit); % get the train matrix   
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
        for j=1:size(fit_path,2)
            fit   = [money_dir char(fit_path(j))];
            unfit = [money_dir char(unfit_path(j))];
            [labels, ImgSet, nx, ny] = preprocess(0.75,i,0,rounds,fit,unfit); % get the test matrix   

            %load the corresponding model
            if (mod(j,2)==0)                 
                string_name = ['model_' money_dir sprintf('_rear%d.mat', i)];
                load(string_name);
                [tp_rear(i), fp_rear(i), error_rear(i), tpp_rear(:,i), fpp_rear(:,i), classifier_rear]...
                                        = eval_bills(model, labels, ImgSet,0);
            elseif (mod(j,2)~=0) 
                string_name = ['model_' money_dir sprintf('_front%d.mat', i)];
                load(string_name);
                [tp_front(i), fp_front(i), error_front(i), tpp_front(:,i), fpp_front(:,i), classifier_front]...
                                        = eval_bills(model, labels, ImgSet,0);
			end;
		end
	        
		%PROBABILITIES OF BOTH FRONT AND REAR
%          [tp_both(i), fp_both(i), error_both(i), tpp_both(:,i), fpp_both(:,i), classifier_both]...
%          = eval_bills(model, labels, ImgSet, (classifier_rear+classifier_front)./2);
  
        %CHANGE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         both_val  = (abs(classifier_rear)>abs(classifier_front)).*classifier_rear...
 					+(abs(classifier_rear)<=abs(classifier_front)).*classifier_front
         [tp_both(i), fp_both(i), error_both(i), tpp_both(:,i), fpp_both(:,i), classifier_both]...
         = eval_bills(model, labels, ImgSet, both_val);				
    end
    
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
    
    tpp_rear  = mean(tpp_rear,2);
    fpp_rear  = mean(fpp_rear,2);
	
    tpp_front = mean(tpp_front,2);
    fpp_front = mean(fpp_front,2);
    
	tpp_both = mean(tpp_both,2);
    fpp_both = mean(fpp_both,2);
    
    figure; hold on;
    plot(fpp_rear , tpp_rear ,'r' , 'linewidth' , 2)
    plot(fpp_front , tpp_front ,'b' , 'linewidth' , 2)
    plot(fpp_front , tpp_both ,'g' , 'linewidth' , 2)
    axis([-0.02 , 1.02 , -0.02 , 1.02])
    legend('rear', 'front', 'both')
    title(sprintf('ROC for Haar Classifier with the best T = %d, features considered', T));
    hold off;
end