%COMPUTES THE CLASSIFIER THAT PERFORMS THE BEST AS THE FINAL CLASSIFIER
%USING "A SIMPLE CASCADE" AND EVALUATES THE RESULT ON THE TEST SET
%INPUT:
%       model -- model structure of the features computed in the
%                train_haar.m
%       labels -- array of labels for the images
%       ImgSet -- the images of the training set saved as a matrix   
function [true_pos, false_pos, performance, tpp, fpp] = eval_bills(model, labels, ImgSet)
    load model_struct.mat
    target    = int8(labels);
    index_pos = find(target == 1); %the indexes for the positive class
    index_neg = find(target ==-1); %the indexes for the negative class
    T         = size(model.param , 2); %number of features choosen 

    final_classifier = eval_haar(ImgSet , model); %compute the final classifier using a simple cascade
    [tpp, fpp, threshold] = basicroc(target , final_classifier); %compute the ROC curve

    Error_classifier  = 1-tpp(2:end-1) + fpp(2:end-1);
    [minimum , index] = min(Error_classifier); %get the min value and the index of the corresponding classifier  
    threshold_opt     = threshold(index); %get the corresponding threshold 
    best              = sign(final_classifier - threshold_opt); %the predicted output with respect to the threshold
    true_pos          = sum(best(index_pos) == target(index_pos))/length(index_pos);
    false_pos         = 1 - sum(best(index_neg) == target(index_neg))/length(index_neg);
    performance       = sum(best == target)/length(target);

%{
    figure
    plot(1:length(y) , final_classifier , 'r')
    title(sprintf('Output of the strong classifier for test data with T = %d, n_{exit} = %d' , T ))
   
    figure
    plot(fpp , tpp ,'r' , 'linewidth' , 2)
    axis([-0.02 , 1.02 , -0.02 , 1.02])
    title(sprintf('ROC for Conventional Cascade with T = %d, n_{stages} = %d' , T))
   
    figure
    plot(threshold , Error_classifier, 'r+' , threshold_opt , minimum, 'k+' , 'linewidth' , 2)
    title('Plot of all classifiers" erros, and all thresholds AND the minimal error and the corresponding threshold');

    xlabel('\lambda (threshold)')
    ylabel('Error')
 %}
end