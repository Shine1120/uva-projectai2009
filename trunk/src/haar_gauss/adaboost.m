%INPUT:
%		ySegms        -- number of segments on Y 
%		xSegms        -- number of segments on X
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
function [alpha, indexs, mean_fit, mean_unfit, cov_fit, cov_unfit] = ...
							adaboost(ySegms,xSegms,convImages,T,rect_patterns,labels)
	positives = sum(sum(labels == 1)); 
	negatives = sum(sum(labels == 0));
	weights   = 2/positives .* (labels==1) + 2/negatives .* (labels==0); %weights = 2/length(labels); 
	indexs    = [];
	delta     = 0.00001;	
	
	mean_fit   = mean(convImages((labels==0),:));
	mean_unfit = mean(convImages((labels==1),:));

	trainFit   = convImages((labels==0),:)';
	trainUnfit = convImages((labels==1),:)';
	cov_fit    = zeros(1,size(trainFit,1));
	for covIdx = 1:size(trainFit,1)
		cov_fit(covIdx) = cov(trainFit(covIdx,:));
	end
	cov_unfit = zeros(1,size(trainUnfit,1));
	for covIdx = 1:size(trainUnfit,1)
		cov_unfit(covIdx) = cov(trainUnfit(covIdx,:));
	end

	for t=1:T
		fprintf('\t AdaBoost t=%d\n',t)
		%NORMALIZE THE WEIGTHS_____________________________________________
		weights = weights ./ sum(weights);			
		for i=1:size(convImages,2)
			if (sum(indexs==i)==0)
				for j=1:size(convImages,1)
					prob_fit(j)   = mvnpdf(convImages(j,i), mean_fit(i), cov_fit(i));
					prob_unfit(j) = mvnpdf(convImages(j,i), mean_unfit(i), cov_unfit(i));
					recognized(j) = (prob_fit(j)<=prob_unfit(j));
				end	
		%COMPUTE THE ERROR FOR EACH WEAK CLASSIFIER________________________ 
				error(i)   = sum(weights .* abs(recognized' - labels)) + delta;				
				ei(i,:)    = abs(recognized' - labels);
				pattern_id = ceil(i/(ySegms*xSegms));
				fprintf('\t\t Error for model %d is %f\t pattern type:%d\t scale_x:%d\t scale_y:%d\n',i,error(i),...
					rect_patterns(pattern_id).parent_id,rect_patterns(pattern_id).scale_x,...
					rect_patterns(pattern_id).scale_y);
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


