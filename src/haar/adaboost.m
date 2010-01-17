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
function [alpha, indexs, model] = adaboost(F, Images, T, rect_patterns, labels)
	positives = sum(sum(labels == 1)); 
	negatives = sum(sum(labels == 0));
	weights   = 2/positives .* (labels==1) + 2/negatives .* (labels==0); 
	indexs    = [];
	for t=1:T
		fprintf('\t t=%d\n',t)
		%normalize the weights
		weights = weights ./ sum(weights);			
		for i=1:size(F,2)
			%trains SVM
			if exist('patterns') 
				clear patterns
			end	
			patterns(:,:,1)        = rect_patterns(F(i).pattern_id).rectangles;
			patterns               = patterns(:,:,ones(1,size(Images,3)));
			width                  = size(rect_patterns(F(i).pattern_id).rectangles,2);
			height                 = size(rect_patterns(F(i).pattern_id).rectangles,1);			
			pre_values             = double(Images(F(i).y_top: F(i).y_top+height-1,F(i).x_top: ...
							    	 F(i).x_top+width-1, :)).* double(patterns);
			values                 = reshape(sum(sum(pre_values,1),2),1,size(Images,3));
			model(F(i).feature_id) = svmtrain(double(labels'), values', '-t 3 -q -b 0');		
			[recognized, accuracy, probability] = svmpredict(double(labels'), values', model(F(i).feature_id), '-b 0');
			%compute the error
			error(i)        = sum(weights .* abs(recognized' - double(labels)));				
			ei(i,:)         = abs(recognized' - double(labels));
		end
		%choose the classifier with the minimum error
		[sorted_error sortedindex]= sort(error);
		index_sorted = 1;
		while (sum(ismember(indexs, sortedindex(index_sorted)))>0 && index_sorted<size(error,2))
			index_sorted = index_sorted + 1;
		end
		indexs(t)      = sortedindex(index_sorted);		
		%update the weights		
		beta(t)        = error(indexs(t))/(1-error(indexs(t)));
		alpha(t)	   = log(1/beta(t))
		weights        = weights .* (1 .*(ei(indexs(t),:) == 1) + beta(t).*(ei(indexs(t),:) == 0));	
	end
end