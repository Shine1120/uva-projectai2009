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
	weights   = 2/positives .* (labels==1) + 2/negatives .* (labels==0); %weights = 2/length(labels); 
	indexs    = [];
	for t=1:T
		fprintf('\t AdaBoost t=%d\n',t)
		%normalize the weights
		weights = weights ./ sum(weights);			
		for i=1:size(F,2)
			if (sum(indexs==i)==0)
				%trains SVM
				if exist('patterns') 
					clear patterns
				end	
				patterns(:,:,1)        = rect_patterns(F(i).pattern_id).rectangles;
				patterns               = patterns(:,:,ones(1,size(Images,3)));
				
				width                  = size(rect_patterns(F(i).pattern_id).rectangles,2);
				height                 = size(rect_patterns(F(i).pattern_id).rectangles,1);			
				pre_values             = Images(F(i).y_top: F(i).y_top+height-1,F(i).x_top: ...
											 F(i).x_top+width-1, :).* patterns;
				values                 = reshape(sum(sum(pre_values,1),2),1,size(Images,3));
				
				model(F(i).feature_id) = svmtrain(labels, values', '-t 2 -q -b 0');		
				[recognized, accuracy, probability] = svmpredict(labels, values', model(F(i).feature_id), '-b 0');
				%compute the error
				error(i) = sum(weights .* abs(recognized - labels));				
				ei(i,:)  = abs(recognized - labels);
				fprintf('\t\t Error for model %d is %f\t pattern type:%d\t scale_x:%d\t scale_y:%d\n',i,error(i),...
					rect_patterns(F(i).pattern_id).parent_id,rect_patterns(F(i).pattern_id).scale_x, rect_patterns(F(i).pattern_id).scale_y);
			else
				error(i) = 1;
			end
		end
 		[minimum indexs(t)]= min(error);		
		%update the weights		
		beta(t)  = error(indexs(t))/(1-error(indexs(t)));
		alpha(t) = log(1/beta(t))
		weights  = weights .* (1 .*(ei(indexs(t),:) == 1)' + beta(t).*(ei(indexs(t),:) == 0)');	
	end
end