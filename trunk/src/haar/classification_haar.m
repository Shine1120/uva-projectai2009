%CLASSIFIES THE DATA BASED ON THE HAAR FEATURES AND USING ADABOOST CASCADE 
%FOR SELECTING THE BEST FEATURES TO BE USED
%INPUT:
%       T -- number of features to be used (not too large :P)
function classification_haar(T)
    % Do the CROSS-VALIDATION loop
    for i=1:2
        [labels, ImgSet, nx, ny] = preprocess(0.75, i, 1, 2); % get the train matrix   
        %the result structure retrieved from the AdaBoost cascade
        [model, rect_param, F]   = train_haar(T, labels, ImgSet);
        
        [labels, ImgSet, nx, ny] = preprocess(0.75, i, 0, 2); % get the test matrix   
        %save the obtained model(the weak classifiers corresponding to the features chosen)
        model           = struct('param',model,'weaklearner',1,'dimsItraining', ...
                          [ny nx],'rect_param',rect_param,'F',F,'cascade_type',1,'postprocessing',1);
        string_name     = sprintf('model_haar_small_%d.mat' , i);
        save string_name model;   
        %classify the new data using another cascade and evaluate 
        [true_pos(i), false_pos(i), performance(i), tpp(:,i), fpp(:,i)] = eval_bills(model, labels, ImgSet);
    end
    %average over all results to obtain the performance of the classifier
    true_positive  = mean(true_pos)
    false_positive = mean(false_pos)
    performance    = mean(performance)
    tpp            = mean(tpp,2);
    fpp            = mean(fpp,2);  
    
    figure
    plot(fpp , tpp ,'r' , 'linewidth' , 2)
    axis([-0.02 , 1.02 , -0.02 , 1.02])
    title(sprintf('ROC for Haar Classifier with the best T = %d, features considered', T));
end