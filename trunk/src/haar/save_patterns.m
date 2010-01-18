function save_patterns(imsize_x, imsize_y)
	%DEFINE BASIC PATTERNS
	pre_patterns(1) = struct('pattern_id',1, 'rectangles', [1 -1;1 -1]);
	pre_patterns(2) = struct('pattern_id',2, 'rectangles', [-1 1;-1 1]);
	pre_patterns(3) = struct('pattern_id',3, 'rectangles', [-1 -1;1 1]);
	pre_patterns(4) = struct('pattern_id',4, 'rectangles', [1 1;-1 -1]);
	pre_patterns(5) = struct('pattern_id',5, 'rectangles', [-1 1;1 -1]);
	pre_patterns(6) = struct('pattern_id',6, 'rectangles', [1 -1;-1 1]);
	pre_patterns(7) = struct('pattern_id',7, 'rectangles', [1 -1 1;1 -1 1]);
	pre_patterns(8) = struct('pattern_id',8, 'rectangles', [-1 1 -1;-1 1 -1]);
	pre_patterns(9) = struct('pattern_id',9, 'rectangles', [-1 -1;1 1;-1 -1]);
	pre_patterns(10) = struct('pattern_id',10, 'rectangles', [1 1;-1 -1;1 1]);
	
%	size_patt = size(pre_patterns,2);
	
	%RESIZE THE BASIC PATTERNS
	for i=1:size(pre_patterns,2)
		width      = size(pre_patterns(i).rectangles,2);
		height     = size(pre_patterns(i).rectangles,1);
		randsize_x = randperm(round(imsize_x/width)-10);
		randsize_y = randperm(round(imsize_y/height)-10);
		
		size_x     = randsize_x(randsize_x>10);
		size_y     = randsize_y(randsize_y>10);
		number     = min(20, length(size_x)); 
		number     = min(number, length(size_y));
		for j=1:number
			index           = number*(i-1)+j; %size_patt + number*(i-1)+j;
			rectangles      = sign(imresize_old(pre_patterns(i).rectangles,[height*size_y(j) width*size_x(j)]));
			patterns(index) = struct('pattern_id',index, 'rectangles', rectangles);
		end
	end
	save 'patterns.mat' patterns
end

	
