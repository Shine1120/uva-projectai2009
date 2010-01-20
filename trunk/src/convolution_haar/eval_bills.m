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
function [true_pos, false_pos, error, classifier] = eval_bills(model, target, convImg, classifier)
	if classifier == 0
		for i=1:size(model.best_ids,2)
			id = model.best_ids(i);			
			[recognized(i,:), accuracy, probability] = svmpredict(target, ...
					convImg(model.patterns(id).pattern_id,:)', ...
					model.model(model.patterns(id).pattern_id), '-b 0');
		end	
 		classifier = ((model.weights * recognized) >= sum(0.5*(model.weights)));			
	end
	index_pos = find(target == 1); %the indexes for the positive class
    index_neg = find(target == 0); %the indexes for the negative class
	
	true_pos  = sum(classifier(index_pos)' == target(index_pos))/length(index_pos);
	false_pos = 1 - sum(classifier(index_neg)' == target(index_neg))/length(index_neg);
    error     = 1 - sum(classifier' == target)/length(target); 	
end