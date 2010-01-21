%INPUT:
%		patterns -- rectangular patterns 
%		Images   -- the set of images 
%		side	 -- rear/front
%OUTPUT:
%		values   -- the values obtained by convolving the image with the rectangles 
%__________________________________________________________________________
function values = generate_convolutions(patterns,Images,side)	
	values = zeros(size(patterns,2), size(Images,3));
	for i=1:size(patterns,2)	
		fprintf('\t Generate convolutions for %s -- pattern %d\n',side,i)
		for k=1:size(Images,3)				
			convImg         = conv2(Images(:,:,k), patterns(i).rectangles);
			filter          = (convImg<0);
			convImg(filter) = 0;
			values(i,k)       = sum(sum(convImg));
		end	
	end
	if (strcmp(side,'rear')==1)
		convolutions_rear = values;
	else
		convolutions_front = values;
	end
	save(['convolved_images_' side], ['convolutions_' side]);
end