function recognized = AdaBoostSVMPredict(testnote_regions, eigen_regions, alpha, modelIdx, models)
% ADABOOSTSVNPREDICT - using a strong classifier consisting of a list of
% weights, SVM models and eigen-regions.
%  
% testnote_regions:		image data of 1 bill divided into regions
% eigen_regions:		components to project testnote_regions on
% alpha:				list of weights for strong classifier
% modelIdx:				list of indexes pointing to the correct image data 
%						regions, eigen_regions and models.
% models:				SVM models (for each region 1)


	
	result = 0;
	for i=1:length(alpha)
		a = alpha(i);
		idx = modelIdx(i);
		testnote_region = testnote_regions(:,:,idx);
		eigen_region = eigen_regions(:,:,idx);		
		model = models(idx);		
		testnoteProjection = testnote_region * eigen_region;		
		
		[recognized, accuracy, prob_est_front] = svmpredict(1,testnoteProjection, model, '-b 0');
		
		
		if recognized == 0;
			recognized = -1;
		end
		
		result = result + (a*recognized);
	end
	
	recognized = sign(result);

	% convert label back
	if recognized == -1
		recognized = 0;
	end

end