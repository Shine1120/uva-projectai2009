%PREPROCESSES IMAGES AND SPLITS THE DATA FOR CROSSVALIDATION 
%(resizes and stores them in a matrix)
%INPUT: 
%       res       -- the procent to which the images should be resized
%		names     -- names of the images 
%OUTPUT:
%       ImgSet     -- images for the data set as a matrix resized with the
%                     procent res
%       nx         -- resized dimension of images on x axis
%       ny         -- resized dimension of images on x axis
function [ImgSet, nx, ny] = preprocess(res,names)    
    nx = round(120*res);
    ny = round(85*res);
	for i=1:length(names)
	    Img = imread(names{i});
		Img = imresize(Img, [round(85*res) round(120*res)]);
        ImgSet(:,:,i) = Img;  
	end
end