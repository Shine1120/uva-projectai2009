function eigen_regions = genEigenFaceRegions(img_regions)

	s = size(img_regions);
	eigen_regions = zeros(s(2),s(1),s(3));

	for i=1:size(img_regions,3)
		img_region = img_regions(:,:,i);
		eigen_region = genEigenFaces(img_region);
% 		size(eigen_region)
		eigen_regions(:,:,i) = eigen_region;
	end

end