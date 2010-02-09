function models = trainRegionsSVM(image_regions, labels, eigen_regions, NumberOfEigenVectors)
% trainRegionsSVM - for each region, project the training-data onto the
% correct eigen-regions and train an SVM model for this.
%
% image_regions:			image data split into regions
% labels:					data labels
% eigen_regions:			eigen-faces per region
% NumberOfEigenVectors:		number of eigen-vectors used for projection

	s = size(eigen_regions);

	% models are structs, which makes it difficult to allocate
	models = [];
	
	for i=1:s(3)
		eigen_region = eigen_regions(:,:,i);
		image_region = image_regions(:,:,i);
		eigen_region = eigen_region(:,1:NumberOfEigenVectors);
		
		img_projection = image_region*eigen_region;
% 		size(eigen_region)
% 		size(img_projection)
% 		size(labels)

		model = svmtrain(labels, img_projection, '-t 0 -q -b 0');
		models = [models model];
	end
end