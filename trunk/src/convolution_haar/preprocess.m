%PREPROCESSES IMAGES AND SPLITS THE DATA FOR CROSSVALIDATION 
%(resizes and stores them in a matrix)
%INPUT: 
%		ySegms    -- number of regions on Y
%		xSegms    -- number of regions on X
%       res       -- the procent to which the images should be resized
%		img_names -- names of the images 
%		patterns  -- structure of patterns
%		side      -- front/rear
%OUTPUT:
%       ImgSet    -- images for the data set as a matrix resized with the
%                     procent res
%__________________________________________________________________________
function convolutions = preprocess(ySegms,xSegms,res,img_names,patterns,side)
	fprintf('\t preprocessing images ...\n')
	for i=1:length(img_names)
		fprintf('\t Image %s - %d\n',side,i)
		Img = imresize_old(im2double(imread(img_names{i})),[round(400*res) round(250*res)]);
%		Img = imresize_old(im2double(imread(img_names{i})),[round(85*res) round(120*res)]);
		convolutions(i,:) = generate_convolutions(ySegms,xSegms,400,250,patterns,Img); 
	end
	%STORE THE RESULTS_____________________________________________________
	if (strcmp(side,'rear')==1)
		convolutions_rear = convolutions;
	else
		convolutions_front = convolutions;
	end
	save(['convolved_images_' side], ['convolutions_' side]);
end