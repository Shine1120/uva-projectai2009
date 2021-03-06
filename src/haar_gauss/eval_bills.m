%COMPUTES THE CLASSIFIER THAT PERFORMS THE BEST AS THE FINAL CLASSIFIER
%USING "A SIMPLE CASCADE" AND EVALUATES THE RESULT ON THE TEST SET
%INPUT:
%       model      -- model structure of the features computed in the
%                     train_haar.m
%       target     -- array of targets for the images
%       convImg    -- the images of the training set saved as a matrix   
%       classifier -- 0 if is not computed yet / the array containing the probabilities   
%		isplot     -- 1 = plots the error with respect to the nr of
%		              features / 0 = no plot
%OUTPUT:
%       true_pos   -- the number of the true positives
%       false_pos  -- the number of false positives
%       error      -- the error of the classifier
%                     (number of images incorrectly classified)
%       classifier -- the vector of with the final probabilities of the test set
%__________________________________________________________________________
function [true_pos, true_neg, error, classifier] = eval_bills(model, target, convImg, classifier, isplot)
	%BUILD THE STRONG CLASSIFIER OUT OF THE BEST T ONES FROM ADABOOST______
	if classifier == 0
		prior_fit   = 0.60;
		prior_unfit = 0.40;
		for i=1:size(model.best_ids,2)
			id = model.best_ids(i);
			for j=1:size(convImg,1)
				prob_fit(j)     = mvnpdf(convImg(j,id), model.mean_fit(id), model.cov_fit(id));
				prob_unfit(j)   = mvnpdf(convImg(j,id), model.mean_unfit(id), model.cov_unfit(id));
			end	
			final_fit       = ((prior_fit .* prob_fit)+1)./((prior_fit .* prob_fit) + (prior_unfit .* prob_unfit)+2);
			final_unfit     = ((prior_unfit .* prob_unfit)+1)./((prior_fit .* prob_fit) + (prior_unfit .* prob_unfit)+2);
			recognized(i,:) = (final_fit<=final_unfit);
		end	
		
		if (isplot ~= 0)
			for i=1:size(model.best_ids,2) 
				classifier        = ((model.weights(:,(1:i)) * recognized((1:i),:)) >= sum(0.5*(model.weights(:,(1:i)))));			
				incorrect_plot(i) = 1 - sum(classifier' == target)/length(target); 	
			end
			plot([1:size(model.best_ids,2)],incorrect_plot,isplot);
			xlabel('model');ylabel('error');
		end
		classifier = ((model.weights * recognized) >= sum(0.5*(model.weights)));
	end
	%COMPUTE THE TP, FP AND ERROR__________________________________________
	index_pos = find(target == 1); %INDEXES FOR POSITIVE CLASS
    index_neg = find(target == 0); %INDEXES FOR NEGATIVE CLASS
	
	true_pos = sum(classifier(index_pos)' == target(index_pos))/length(index_pos);
	true_neg = sum(classifier(index_neg)' == target(index_neg))/length(index_neg);
    error    = 1 - sum(classifier' == target)/length(target); 	
end








