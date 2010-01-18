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
function classifier = eval_bills(model, label, ImgSet)

	for i=1:size(model.best_feature_id,2)
		%compute the values for the test images
		id                     = model.best_feature_id(i);
		patterns               = model.patterns(model.features(id).pattern_id).rectangles;
		width                  = size(patterns,2);
		height                 = size(patterns,1);			
		

% 		model.features(id).y_top
% 		model.features(id).x_top
% 		size(ImgSet)
		
		pre_values = double(ImgSet(model.features(id).y_top: model.features(id).y_top+height-1, ...
					   model.features(id).x_top: model.features(id).x_top+width-1)).* ...
					   double(patterns);
		
		value   = sum(pre_values(:));
		
		[recognized(i), accuracy, probability] = svmpredict(label, value, model.model(id), '-b 0');
	end	
	
	
	size(model.weights)
	size(recognized)
	
	classifier = (model.weights * recognized') >= sum(0.5*(model.weights));			

% 	REC = recognized
% 	CLASS = classifier
end