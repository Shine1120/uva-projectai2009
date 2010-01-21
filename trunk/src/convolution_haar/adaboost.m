%INPUT:
%		convImages    -- the whole images training set
%		T             -- number of hypothesis
%		rect_patterns -- the patterns structure: rectangles(=matrix),
%						 pattern_id(=id)	
%		labels        -- the labels corresponding to the 
%OUTPUT:
%		alpha         -- the weights of the features (alpha_t from algorithm)  
%		indexs        -- index of the best features  
%		model         -- the array containing the all the SVM models 
%__________________________________________________________________________
function [alpha, indexs, model] = adaboost(convImages, T, rect_patterns, labels)
	positives = sum(sum(labels == 1)); 
	negatives = sum(sum(labels == 0));
	weights   = 2/positives .* (labels==1) + 2/negatives .* (labels==0); %weights = 2/length(labels); 
	indexs    = [];
	delta     = 0.00001;
	for t=1:T
		fprintf('\t AdaBoost t=%d\n',t)
		%NORMALIZE THE WEIGTHS_____________________________________________
		weights = weights ./ sum(weights);			
		for i=1:size(rect_patterns,2)
			if (sum(indexs==i)==0)
				model(rect_patterns(i).pattern_id)  = svmtrain(labels, convImages(i,:)', '-t 0 -q -b 0');		
				[recognized, accuracy, probability] = svmpredict(labels, convImages(i,:)',model(rect_patterns(i).pattern_id), '-b 0');
		%COMPUTE THE ERROR FOR EACH WEAK CLASSIFIER________________________ 
				error(i) = sum(weights .* abs(recognized - labels)) + delta;				
				ei(i,:)  = abs(recognized - labels);
				fprintf('\t\t Error for model %d is %f\t pattern type:%d\t scale_x:%d\t scale_y:%d\n',i,error(i),...
					rect_patterns(i).parent_id,rect_patterns(i).scale_x, rect_patterns(i).scale_y);
			else
				error(i) = 1;
			end
		end
		%GET THE ID OF THE CLASSIFIER WITH THE MINIMUM ERROR_______________
 		[minimum indexs(t)]= min(error);		
		%COMPUTE ALPHA-WEIGHTS AND UPDATE THE WEIGHTS______________________		
		beta(t)  = error(indexs(t))/(1-error(indexs(t)));
		alpha(t) = log(1/beta(t))
		weights  = weights .* (1 .*(ei(indexs(t),:) == 1)' + beta(t).*(ei(indexs(t),:) == 0)');	
	end
end


