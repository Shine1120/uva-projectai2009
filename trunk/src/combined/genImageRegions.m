function img_regions = genImageRegions(imgVecs, fr)


	for i=1:size(imgVecs,3)
		img = imgVecs(:,:,i);
	
		img = imresize(img,[350, 190]);
		% resizing will make it possible to divide up the bill
		% into 7*3 regions ([350x189], imcrop adds 1 to the
		% cropsize...)
		region=1;
		for m=1:50:350
			for n=1:63:189
				cropped_img = imcrop(img,[n,m,62,49]);
				img_regions(i,:,region) = cropped_img(:);
				region = region+1;
			end
		end
	end
	
% 	size(img_regions)
end