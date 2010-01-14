%INPUT:
%		F             -- features structure: x_top, y_top(=top coordinates), 
%						 pattern_id(=corresponding pattern id), feature_id 
%		Images        -- the whole images training set
%		rect_patterns -- the patterns structure: rectangles(=matrix),
%						 pattern_id(=id)	
%		labels        -- the labels corresponding to the 
%OUTPUT:
%		alpha         -- the weights of the features (alpha_t from algorithm)  
%		indexs        -- index of the best features  
%		best_model    -- the array containing the best SVM models corresponding to 
%						 the best features
function [alpha, indexs, best_model] = adaboost(F, Images, T, rect_patterns, labels)
	positives = sum(sum(labels == 1)); 
	negatives = sum(sum(labels == 0));
	weights(1,:) = 2/positives .* (labels==1) + 2/negatives .* (labels==0); 
	for t=1:T
		%normalize the weights
		weights(t,:) = weights(t,:)./sum(weights(t,:));				
		for i=1:size(F,2)
			%trains SVM
			if exist('patterns') 
				clear patterns
			end	
			patterns(:,:,1) = rect_patterns(F(i).pattern_id).rectangles;
			patterns        = patterns(:,:,ones(1,size(Images,3)));
			width           = size(rect_patterns(F(i).pattern_id).rectangles,2);
			height          = size(rect_patterns(F(i).pattern_id).rectangles,1);			
			values          = reshape(sum(sum(double(Images(F(i).y_top: F(i).y_top+height-1,F(i).x_top: F(i).x_top+width-1, :))...
  							  .* double(patterns),1),2), 1, size(Images,3));										
			model(i)        = svmtrain(double(labels'), values', '-t 0 -q -b 0');		
			rand_index      = randperm(size(values,2));			
			values          = values(rand_index);
			rand_labels     = labels(rand_index);
			[recognized, accuracy, probability] = svmpredict(double(rand_labels'), values', model(i), '-b 0');
			%compute the error
			error(i)        = sum(weights(t,:) .* abs(recognized' - double(rand_labels)));			
			ei(i,:)         = sign(recognized' - double(rand_labels));
		end
		%choose the classifier with the minimum error
		[minimum indexs(t)] = min(error)
		%update the weights
		beta(t)        = error(indexs(t))/(1-error(indexs(t)));
		alpha(t)	   = log(1/beta(t));
		best_model(t)  = model(indexs(t));
		repeat_beta    = repmat(beta(t), 1, size(weights,2));		
		weights(t+1,:) = weights(t,:) .* (1 .*(ei(indexs(t)) == 1) + repeat_beta.*(ei(indexs(t)) == 0));		
	end
end