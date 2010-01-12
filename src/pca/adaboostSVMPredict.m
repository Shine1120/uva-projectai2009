function recognized = adaboostSVMPredict(testnote_regions, eigen_regions, Model)
%ADABOOSTSVNPREDICT Summary of this function goes here
%   Detailed explanation goes here

% 	size(testnote_regions)
% 	size(eigen_regions)
% 	
% 	Model

	testnote_region = testnote_regions(:,:,1);
	eigen_region = eigen_regions(:,:,1);
	
	testnoteProjection = testnote_region * eigen_region;
	
% 	figure;
% 	imshow(reshape(testnote_region,[50 63]));
% 	figure;
% 	imshow(reshape(eigen_region(:,1),[50 63]));
% 	figure;
% 	imshow(reshape(eigen_region(:,2),[50 63]));
% 	figure;
% 	imshow(reshape(eigen_region(:,3),[50 63]));	
% 	ginput(1)

	[recognized, accuracy, prob_est_front] = svmpredict(1,testnoteProjection, Model, '-b 0');
	
	

end