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
function [true_pos, false_pos, error, tpp, fpp, classifier] = eval_bills(model, labels, ImgSet, classifier)
    target    = int8(labels);
    index_pos = find(target == 1); %the indexes for the positive class
    index_neg = find(target == -1); %the indexes for the negative class

	if classifier == 0
		for i=1:size(model.best_feature_id,2)
			%compute the values for the test images
			id                     = model.best_feature_id(i);
			patterns               = model.patterns(model.features(id).pattern_id).rectangles;
			width                  = size(patterns,2);
			height                 = size(patterns,1);			
			repeat_patterns(:,:,1) = patterns;
			repeat_patterns        = repeat_patterns(:,:,ones(1,size(ImgSet,3)));			
			values   = reshape(sum(sum(double(ImgSet(model.features(id).y_top: model.features(id).y_top+height-1, ...
					   model.features(id).x_top: model.features(id).x_top+width-1, :)).* ...
					   double(repeat_patterns))), 1, size(ImgSet,3));															   
			[recognized, accuracy, probability(i,:)] = svmpredict(double(labels'), values', model.model, '-b 0');
			probability(i,:) = sign(probability(i,:));
			probability(i,:) = (probability(i,:)==1) + (probability(i,:)==0);
		end		
		repeat_weights(1,:) = model.weights;
		repeat_weights      = repeat_weights(ones(1,size(probability,2)),:);
		classifier          = sign(sum((repeat_weights .* probability') - 1/2*(repeat_weights),2));			
		classifier          = classifier + (classifier==0) 
	end
	[tpp, fpp, thresh] = basicroc(target, classifier);
	error_cascade      = (1-tpp(2:end-1)) + fpp(2:end-1);
    [minimum, index]   = min(error_cascade);
 	if index == 1 
 		threshold = 0;
 	else
 	    threshold = thresh(index);  	
	end
    best      = sign(classifier - threshold);
	true_pos  = sum(best(index_pos) == target(index_pos)')/length(index_pos);
    false_pos = 1 - sum(best(index_neg) == target(index_neg)')/length(index_neg);
    error     = 1 - sum(best == target')/length(target); 	
	
%   
%SIMPLE CASCADE________________________________
%     if(classifier == 0)
%         %If cascade_type = 0, i.e. coventional cascade:
%         %Entrance nodes are: [1, cumsum(cascade(1 , 1:end-1))+1] 
%         %Exit nodes are:     [cumsum(cascade(1 , :))]         
% 		
%         cascade = [1, 2, 2, 2, 3; -1, -0.75, -0.5 , -0.25, 0]; 
%         %cascade = [1, 2, 2, 2, 2; 1, 2, 3, 6, 12];       
%         %cascade = [1, 2, 2, 2, 3; -0.75, -0.5, -0.25, 0, 0];
%         %cascade     = [1, 2, 3, 4; -0.75, -0.5, -0.25, 0];       
%         classifier1 = eval_haar(ImgSet, model , cascade)
%     else
%         classifier1 = classifier;
%     end   
%     [tpp1,fpp1,thresh1] = basicroc(target, classifier1);
%     Error_cascade1      = (1-tpp1(2:end-1)) + fpp1(2:end-1);
%     [minimum1, index1]  = min(Error_cascade1);
% 	if index1 ==1 
% 		threshold1 = 0;
% 	else
% 	    threshold1          = thresh1(index1);  	
% 	end
% 	
%     best1               = sign(classifier1 - threshold1);
%     true_pos1           = sum(best1(index_pos) == target(index_pos))/length(index_pos);
%     false_pos1          = 1 - sum(best1(index_neg) == target(index_neg))/length(index_neg);
%     error1              = 1 - sum(best1 == target)/length(target);
%     
% %WITHOUT CASCADE - FULL________________________________    
%     if(classifier == 0)        
%         classifier2 = eval_haar(ImgSet , model); %compute the final classifier using a simple cascade
%     else
%         classifier2 = classifier;
%     end
%     [tpp2,fpp2,threshold2] = basicroc(target, classifier2); %compute the ROC curve
%     Error_classifier2      = 1-tpp2(2:end-1) + fpp2(2:end-1);
%     [minimum2 , index2]    = min(Error_classifier2); %get the min value and the index of the corresponding classifier  
%     threshold_opt2         = threshold2(index2); %get the corresponding threshold 
%     best2                  = sign(classifier2 - threshold_opt2); %the predicted output with respect to the threshold
%     true_pos2              = sum(best2(index_pos) == target(index_pos))/length(index_pos);
%     false_pos2             = 1 - sum(best2(index_neg) == target(index_neg))/length(index_neg);
%     error2                 = 1 - sum(best2 == target)/length(target);

%CHOOSE THE BEST RESULT OF THE TWO
%     if error1<error2
%         true_pos   = true_pos1;
%         false_pos  = false_pos1;
%         error      = error1;
%         tpp        = tpp1;
%         fpp        = fpp1;
%         classifier = classifier1;
%     else
%         true_pos   = true_pos2;
%         false_pos  = false_pos2;
%         error      = error2;
%         tpp        = tpp2;
%         fpp        = fpp2;
%         classifier = classifier2;
% 	end
end