function [incorrect_plot_rear_fit, incorrect_plot_rear_unfit, ...
		  incorrect_plot_front_fit, incorrect_plot_front_unfit, ...
		  incorrect_plot_both_fit, incorrect_plot_both_unfit] = ...
	evaluate(model_front, model_rear, target, ImgHoldout_front, ImgHoldout_rear)
%BUILD THE STRONG CLASSIFIER OUT OF THE BEST T ONES FROM ADABOOST______
	prior_fit   = 0.60;
	prior_unfit = 0.40;
	
    for i=1:size(model_rear.best_ids,2)
		id = model_rear.best_ids(i);
		for j=1:size(ImgHoldout_rear,1)
			prob_fit(j)   = mvnpdf(ImgHoldout_rear(j,id), model_rear.mean_fit(id), model_rear.cov_fit(id));
			prob_unfit(j) = mvnpdf(ImgHoldout_rear(j,id), model_rear.mean_unfit(id), model_rear.cov_unfit(id));
		end	
			final_fit       = ((prior_fit .* prob_fit)+1)./((prior_fit .* prob_fit) + (prior_unfit .* prob_unfit)+2);
			final_unfit     = ((prior_unfit .* prob_unfit)+1)./((prior_fit .* prob_fit) + (prior_unfit .* prob_unfit)+2);
			recognized_rear(i,:) = (final_fit<=final_unfit);
    end
     
    for i=1:size(model_front.best_ids,2)
		id = model_front.best_ids(i);
		for j=1:size(ImgHoldout_front,1)
			prob_fit(j)   = mvnpdf(ImgHoldout_front(j,id), model_front.mean_fit(id), model_front.cov_fit(id));
			prob_unfit(j) = mvnpdf(ImgHoldout_front(j,id), model_front.mean_unfit(id), model_front.cov_unfit(id));
		end	
			final_fit       = ((prior_fit .* prob_fit)+1)./((prior_fit .* prob_fit) + (prior_unfit .* prob_unfit)+2);
			final_unfit     = ((prior_unfit .* prob_unfit)+1)./((prior_fit .* prob_fit) + (prior_unfit .* prob_unfit)+2);
			recognized_front(i,:) = (final_fit<=final_unfit);
	end

	index_pos = find(target == 1); %INDEXES FOR POSITIVE CLASS
    index_neg = find(target == 0); %INDEXES FOR NEGATIVE CLASS
    for i=1:size(model_rear.best_ids,2)
		classifier_rear              = ((model_rear.weights(:,(1:i)) * recognized_rear((1:i),:)) >= sum(0.5*(model_rear.weights(:,(1:i)))));			
		incorrect_plot_rear_fit(i)   = 1 - sum(classifier_rear(index_neg)' == target(index_neg))/length(index_neg);
		incorrect_plot_rear_unfit(i) = 1 - sum(classifier_rear(index_pos)' == target(index_pos))/length(index_pos);        
		
        classifier_front              = ((model_front.weights(:,(1:i)) * recognized_front((1:i),:)) >= sum(0.5*(model_front.weights(:,(1:i)))));			
		incorrect_plot_front_fit(i)   = 1 - sum(classifier_front(index_neg)' == target(index_neg))/length(index_neg);
		incorrect_plot_front_unfit(i) = 1 - sum(classifier_front(index_pos)' == target(index_pos))/length(index_pos);
		
        
        classifier_both              = 1-(1-classifier_front).*(1-classifier_rear);			
		incorrect_plot_both_fit(i)   = 1 - sum(classifier_both(index_neg)' == target(index_neg))/length(index_neg);    
		incorrect_plot_both_unfit(i) = 1 - sum(classifier_both(index_pos)' == target(index_pos))/length(index_pos);    
	end
end