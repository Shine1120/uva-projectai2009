%PLOT THE BEST FEATURES FOUND ON A RANDOMLY SELECTED BILL
%INPUT:
%       ImgSet              -- the images of the training set saved as a matrix   
%		best_feature_indexs -- array of indexs corresponding to the best featurees 
%		rect_patterns       -- the structure containint all possible
%							   patterns: rectangles(=matrix),pattern_id(=id)	
%       F                   -- the whole feature structure: x_top, y_top(=top coordinates), 
%							   pattern_id(=corresponding pattern id), feature_id
%		side                -- 'rear'/'front' 
%		T                   -- number of features to be used (not too large :P)
function plot_features(ImgSet,best_feature_indexs,F,patterns, side, T)
	[Ny , Nx , P] = size(ImgSet); %P number of images   
	Nimage        = randperm(P); %Random image index for printing the result over it
    rand_Img      = ImgSet(:, :, Nimage(1)); %random image for ploting the features
	
	figure;imshow(rand_Img,[]);hold on;	
	for f = 1:size(best_feature_indexs,2)
		x_top  = double(F(best_feature_indexs(f)).x_top); 
		y_top  = double(F(best_feature_indexs(f)).y_top);		
		width  = size(patterns(F(best_feature_indexs(f)).pattern_id).rectangles,2);
		height = size(patterns(F(best_feature_indexs(f)).pattern_id).rectangles,1);	
		h = imshow((patterns(F(best_feature_indexs(f)).pattern_id).rectangles+1).*255/2, ...
			'XData', [x_top x_top+width],'YData', [y_top y_top+height], 'Border', 'tight', 'DisplayRange', [0 255]);
		plot(x_top,y_top,'r*');
	end
	h = imshow(rand_Img,[]);
	set(h,'AlphaData', 0.2)	
    hold off;
    title(sprintf('Best %d %s Haar features with Adaboost' , T, side) , 'fontsize' , 13)
    colormap(gray)
end