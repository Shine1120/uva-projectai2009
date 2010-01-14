function recognized = AdaBoostSVMPredict(testnote_regions, eigen_regions, alpha, modelIdx, models)
%ADABOOSTSVNPREDICT Summary of this function goes here
%   Detailed explanation goes here



	
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
	
	if recognized == -1
		recognized = 0;
	end
	
	
	


% 	testnote_region = testnote_regions(:,:,2);
% 	eigen_region = eigen_regions(:,:,2);
% 	model = models(2);
% 	
% 	testnoteProjection = testnote_region * eigen_region;
	
% 	figure;
% 	imshow(reshape(testnote_region,[50 63]));
% 	figure;
% 	imshow(reshape(eigen_region(:,1),[50 63]));
% 	figure;
% 	imshow(reshape(eigen_region(:,2),[50 63]));
% 	figure;
% 	imshow(reshape(eigen_region(:,3),[50 63]));	
% 	ginput(1)


% 	[recognized, accuracy, prob_est_front] = svmpredict(1,testnoteProjection, model, '-b 0');
	
	

end