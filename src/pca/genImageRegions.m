function img_regions = genImageRegions(imgVecs, fr)


	for i=1:size(imgVecs,1)
		img = imgVecs(i,:);
	
		% fr switch: f = front, r = rear
		switch fr
			case 1
				%img = reshape(img,[350,190]);
				img = reshape(img,[400,250]);
				img = imresize_old(img,[350 190]);
			case 2
				%img = reshape(img,[340,190]);
% 				imshow(img)
% 				size(img)
				img = reshape(img,[410,250]);
				img = imresize_old(img,[350 190]);
		end

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