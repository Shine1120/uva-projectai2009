%COMPUTES THE HAAR FEATURES FOR THE TRAINING SET AND RETURNS A STRUCTURE
%CONTAINING ALL WEAK CLASSIFIERS CORRESPONDING TO THE TOP "T" BEST FEATURES
%INPUT:
%       T                   -- number of features to be used (not too large :P)
%       labels              -- array of labels for the images
%       ImgSet              -- the images of the training set saved as a matrix   
%OUTPUT:
%		alpha_weights       -- the weights returned by the adaboost algorithm
%		best_feature_indexs -- array of indexs corresponding to the best featurees 
%		rect_patterns       -- the structure containint all possible
%							   patterns: rectangles(=matrix),pattern_id(=id)	
%       F                   -- the whole feature structure  
%		model
function [alpha_weights, best_feature_indexs, patterns, F, model] = train_haar(T, labels, ImgSet)
	load patterns
	
	target        = int8(labels); %targets or labels
    [Ny , Nx , P] = size(ImgSet); %P number of images
    F             = generate_features(Ny , Nx , patterns, 20); %haar features	
	[alpha_weights, best_feature_indexs, model] = adaboost(F, ImgSet, T, patterns, target);
		
    %plot the best features on a random image
	Nimage     = randperm(P); %Random image index for printing the result over it
    rand_Img   = ImgSet(: , : , Nimage(1)); %random image for ploting the features
	figure;imshow(rand_Img,'DisplayRange', [0 256]);hold on;
	for f = 1:size(best_feature_indexs,2)
		x_top      = double(F(f).x_top); 
		y_top      = double(F(f).y_top);		
				
		F(f).pattern_id
		
		width      = size(patterns(F(f).pattern_id).rectangles,2);
		height     = size(patterns(F(f).pattern_id).rectangles,1);				
		h = imshow((patterns(F(f).pattern_id).rectangles+1).*256/2, 'XData', [x_top x_top+width],...
			'YData', [y_top y_top+height], 'Border', 'tight', 'DisplayRange', [0 256]);
	end
%	h = imshow(rand_Img,'DisplayRange', [0 256]);
%	set(h,'AlphaData', 0.1)	
    hold off;
    title(sprintf('Best %d Haar features with Adaboost' , T) , 'fontsize' , 13)
    colormap(gray)
end
