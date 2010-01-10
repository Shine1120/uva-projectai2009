%CLASSIFIES THE DATA BASED ON THE HAAR FEATURES AND USING ADABOOST CASCADE 
%FOR SELECTING THE BEST FEATURES TO BE USED
%INPUT:
%       T -- number of features to be used (not too large :P)
function classification_haar(T)
    % Do the CROSS-VALIDATION loop
    money_dir = 'neur10'; % 'neur05';
    fit_path   = {'/fit/fit_front/', '/fit/fit_rear/'};
    unfit_path = {'/unfit/unfit_front/', '/unfit/unfit_rear/'};
    for j=1:size(fit_path,2)
        for i=1:2
            fit   = [money_dir char(fit_path(j))];
            unfit = [money_dir char(unfit_path(j))];
            [labels, ImgSet, nx, ny] = preprocess(0.75,i,1,2,fit,unfit); % get the train matrix   
            %the result structure retrieved from the AdaBoost cascade
            [model, rect_param, F]   = train_haar(T, labels, ImgSet);

            [labels, ImgSet, nx, ny] = preprocess(0.75,i,0,2,fit,unfit); % get the test matrix   
            %save the obtained model(the weak classifiers corresponding to the features chosen)
            model           = struct('param',model,'weaklearner',1,'dimsItraining', ...
                              [ny nx],'rect_param',rect_param,'F',F,'cascade_type',1,'postprocessing',1);
            
            %classify the new data using another cascade and evaluate 
            if (mod(j,2)==0)                 
                string_name = ['model_' money_dir sprintf('_rear%d.mat', i)];
                save string_name model;   
                [tp_rear(i), fp_rear(i), error_rear(i), tpp_rear(:,i), fpp_rear(:,i)] = eval_bills(model, labels, ImgSet);
            elseif (mod(j,2)~=0) 
                string_name = ['model_' money_dir sprintf('_front%d.mat', i)];
                save string_name model;   
                [tp_front(i), fp_front(i), error_front(i), tpp_front(:,i), fpp_front(:,i)] = eval_bills(model, labels, ImgSet);
            end
        end
    end
    
    %average over all results to obtain the performance of the classifier
    true_positive_rear  = mean(tp_rear)
    true_positive_front = mean(tp_front)
    
    false_positive_rear  = mean(fp_rear)
    false_positive_front = mean(fp_rear)
    
    error_rear  = mean(error_rear)
    error_front = mean(error_front)
    
    tpp_rear  = mean(tpp_rear,2);
    fpp_rear  = mean(fpp_rear,2);
    tpp_front = mean(tpp_front,2);
    fpp_front = mean(fpp_front,2);
    
    figure; hold on;
    plot(fpp_rear , tpp_rear ,'r' , 'linewidth' , 2)
    axis([-0.02 , 1.02 , -0.02 , 1.02])
    plot(fpp_front , tpp_front ,'b' , 'linewidth' , 2)   
    legend('rear', 'front')
    title(sprintf('ROC for Haar Classifier with the best T = %d, features considered', T));
    hold off;
end