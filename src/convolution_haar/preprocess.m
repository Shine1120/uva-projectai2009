%PREPROCESSES IMAGES AND SPLITS THE DATA FOR CROSSVALIDATION 
%(resizes and stores them in a matrix)
%INPUT: 
%       res       -- the procent to which the images should be resized
%		names     -- names of the images 
%OUTPUT:
%       ImgSet     -- images for the data set as a matrix resized with the
%                     procent res
%__________________________________________________________________________
function ImgSet = preprocess(res,img_names)
	for i=1:length(img_names)
%			fprintf('\t %d --> %s \n',i,img_names{i})		
%			Img = imresize_old(im2double(imread(img_names{i})),[round(400*res) round(250*res)]);
			Img = imresize_old(im2double(imread(img_names{i})),[round(85*res) round(120*res)]);
			ImgSet(:,:,i) = Img;  
	end
end