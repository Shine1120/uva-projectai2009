%COMPUTES THE CLASSIFIER THAT PERFORMS THE BEST AS THE FINAL CLASSIFIER
%USING "A SIMPLE CASCADE" AND EVALUATES THE RESULT ON THE TEST SET
%INPUT:
%       model      -- model structure of the features computed in the
%                     train_haar.m
%       labels     -- array of labels for the images
%       ImgSet     -- the images of the training set saved as a matrix   
%       classifier -- 0 if is not computed yet / the array containing the probabilities   
%OUTPUT:
%       true_pos   -- the number of the true positives
%       false_pos  -- the number of false positives
%       error      -- the error of the classifier
%                     (number of images incorrectly classified)
%       tpp        -- true positive rate(for the ROC curve, regardles of the threshold)
%       fpp        -- flase positive rate(for the ROC curve, regardles of the threshold)
%       classifier -- the vector of with the final probabilities of the test set   
function [true_pos, false_pos, error, classifier] = eval_bills(model, labels, ImgSet, classifier)
    target    = int8(labels);
    index_pos = find(target == 1); %the indexes for the positive class
    index_neg = find(target == 0); %the indexes for the negative class

	if classifier == 0
		for i=1:size(model.best_feature_id,2)
			%compute the values for the test images
			id                     = model.best_feature_id(i);
			patterns               = model.patterns(model.features(id).pattern_id).rectangles;
			width                  = size(patterns,2);
			height                 = size(patterns,1);			
			if exist('repeat_patterns') 
				clear repeat_patterns
			end	
			repeat_patterns(:,:,1) = patterns;
			repeat_patterns        = repeat_patterns(:,:,ones(1,size(ImgSet,3)));			
			pre_values = double(ImgSet(model.features(id).y_top: model.features(id).y_top+height-1, ...
						   model.features(id).x_top: model.features(id).x_top+width-1, :)).* ...
						   double(repeat_patterns);
			values   = reshape(sum(sum(pre_values,1),2),1,size(ImgSet,3));															   
			[recognized(i,:), accuracy, probability] = svmpredict(double(labels'), values',model.model(i), '-b 0');
		end		
		classifier = (model.weights * recognized) >= sum(0.5*(model.weights));			
		%classifier = (classifier==1) + (classifier==0) 
	end
	true_pos  = sum(classifier(index_pos) == target(index_pos))/length(index_pos);
    false_pos = 1 - sum(classifier(index_neg) == target(index_neg))/length(index_neg);
    error     = 1 - sum(classifier == target)/length(target); 	
end