%INPUT:
%		Ny                  -- height of the regions (images)
%		Nx                  -- width of the regions  (images)
%		rect_patterns       -- the structure of patterns: rectangles(=matrix),
%							   pattern_id(=id)	
%		nr_random_locations -- number of random locations/bill
%OUTPUT:
%		F -- features: x_top, y_top(=top coordinates), 
%			 pattern_id(=corresponding pattern id), feature_id
function F = generate_features(Ny, Nx, rect_patterns, nr_random_locations)
	for i=1:size(rect_patterns,2)
		width  = size(rect_patterns(i).rectangles,2);
		height = size(rect_patterns(i).rectangles,1);
		for k=1:nr_random_locations
			locations_x = randperm(Nx-width);
			locations_y = randperm(Ny-height);
			x_top    = locations_x(1);
			y_top    = locations_y(1);
			index    = nr_random_locations*(i-1)+k;
			F(index) = struct('feature_id', index,'x_top', x_top, 'y_top', y_top,...
					   'pattern_id', rect_patterns(i).pattern_id);	
		end		
	end
end