%COMPUTES THE HAAR FEATURES FOR THE TRAINING SET AND RETURNS A STRUCTURE
%CONTAINING ALL WEAK CLASSIFIERS CORRESPONDING TO THE TOP "T" BEST FEATURES
%INPUT:
%       T                   -- number of features to be used (not too large :P)
%       labels              -- array of labels for the images
%       ImgSet              -- the images of the training set saved as a matrix   
%OUTPUT:
%		alpha_weights       -- the weights returned by the adaboost algorithm
%		best_feature_indexs -- array of indexs corresponding to the best featurees 
%		rect_patterns       -- the structure containint all possible
%							   patterns: rectangles(=matrix),pattern_id(=id)	
%       F                   -- the whole feature structure: x_top, y_top(=top coordinates), 
%							   pattern_id(=corresponding pattern id), feature_id
%		model               -- the model returned by svmtrain for each feature
function [alpha_weights, best_feature_indexs, patterns, F, model] = train_haar(T, target, ImgSet)
	load patterns	
    [Ny , Nx , P] = size(ImgSet); %P number of images
    F             = generate_features(Ny , Nx , patterns, 3); %haar features       	
	[alpha_weights, best_feature_indexs, model] = adaboost(F, ImgSet, T, patterns, target);
		
	best_feature_indexs	
end
