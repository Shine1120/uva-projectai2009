function eigen_regions = genEigenFaceRegions(img_regions)
% genEigenFaceRegions calculates the components for each region on the
% images

	s = size(img_regions);

	% allocate eigen_regions
	eigen_regions = zeros(s(2),s(1),s(3));

	for i=1:size(img_regions,3)
		% get a specific region
		img_region = img_regions(:,:,i);

		% calculate components over this region
		eigen_region = genEigenFaces(img_region);

		% store
		eigen_regions(:,:,i) = eigen_region;
	end

end