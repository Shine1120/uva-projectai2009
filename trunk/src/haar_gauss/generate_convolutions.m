%INPUT:
%		xSegms   -- number of segments on x
%		ySegms   -- number of segments on y
%		size_x   -- image size on x
%		size_y   -- image size on y
%		patterns -- rectangular patterns 
%		Images   -- the set of images 
%OUTPUT:
%		values   -- the values obtained by convolving the image with the rectangles 
%__________________________________________________________________________
function result = generate_convolutions(ySegms,xSegms,size_y,size_x,patterns,Image)
	%DEFINE THE SIZE OF THE SEGMENTS_______________________________________
	imgSegX = floor((size_x-1)/xSegms);
	imgSegY = floor((size_y-1)/ySegms);
	values  = zeros(1,(ySegms*xSegms));
	result  = [];
	for i=1:size(patterns,2)			
		%CONVOLVE THE IMAGES_______________________________________________
		convImg         = conv2(Image, patterns(i).rectangles, 'full');
		filter          = (convImg<0);
		convImg(filter) = 0;
		count           = 1;
		%CUT CONVOLVED IMAGES______________________________________________
		nrY = floor(imgSegY/2);
		nrX = floor(imgSegX/2);
		for y=1:nrY:(size_y-imgSegY)
			for x=1:nrX:(size_x-imgSegX)
				if y+imgSegY+ySegms>size_y
					untillY = size_y;
				else
					untillY = y+imgSegY-1;
				end
				if x+imgSegX+xSegms>size_x
					untillX = size_x;
				else
					untillX = x+imgSegX-1;
				end								
				values(count) = sum(sum(convImg(y:untillY,x:untillX)));
				count = count+1;
			end	
		end
		result = [result values];
	end
end