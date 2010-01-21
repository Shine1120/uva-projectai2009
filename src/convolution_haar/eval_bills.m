%COMPUTES THE CLASSIFIER THAT PERFORMS THE BEST AS THE FINAL CLASSIFIER
%USING "A SIMPLE CASCADE" AND EVALUATES THE RESULT ON THE TEST SET
%INPUT:
%       model      -- model structure of the features computed in the
%                     train_haar.m
%       target     -- array of targets for the images
%       convImg    -- the images of the training set saved as a matrix   
%       classifier -- 0 if is not computed yet / the array containing the probabilities   
%OUTPUT:
%       true_pos   -- the number of the true positives
%       false_pos  -- the number of false positives
%       error      -- the error of the classifier
%                     (number of images incorrectly classified)
%       classifier -- the vector of with the final probabilities of the test set
%__________________________________________________________________________
function [true_pos, true_neg, error, classifier] = eval_bills(model, target, convImg, classifier)
	%BUILD THE STRONG CLASSIFIER OUT OF THE BEST T ONES FROM ADABOOST______
	if classifier == 0
		for i=1:size(model.best_ids,2)
			id = model.best_ids(i);
			[recognized(i,:), accuracy, probability] = svmpredict(target, ...
					convImg(:,id),model.model(id), '-b 0');
		end	
 		classifier = ((model.weights * recognized) >= sum(0.5*(model.weights)));			
	end
	%COMPUTE THE TP, FP AND ERROR__________________________________________
	index_pos = find(target == 1); %INDEXES FOR POSITIVE CLASS
    index_neg = find(target == 0); %INDEXES FOR NEGATIVE CLASS
	
	true_pos = sum(classifier(index_pos)' == target(index_pos))/length(index_pos);
	true_neg = sum(classifier(index_neg)' == target(index_neg))/length(index_neg);
    error    = 1 - sum(classifier' == target)/length(target); 	
end








