function start_plots
%	pattern_scales -- number of different scales generated for each	pattern
%	money_dir      -- the name of the money folder: 'neur10'/'neur05'
%	repetitions    -- number of repetitions (not too large: preferable 5)
%	ySegs          -- number of regions on Y coordinate (preferable 12)
%	xSegs          -- number of reguons on X coordinate (preferable 5)
%	model_rear     -- the rear model to be ploted
%	model_front    -- th front model to be ploted
%	if_load        -- 1 = load convolved images/ 0 = generate convolutions
%__________________________________________________________________________
	pattern_scales = 1;
	money_dir      = 'neur10'; % 'neur05';  
 	repetitions    = 5;
	ySegms		   = 12;
	xSegms		   = 5;
	if_load        = 0;
	load('12x5_haar_model_neur10_handout_rear.mat');	
	model_rear     = model;
	load('12x5_haar_model_neur10_handout_front.mat');	        
    model_front    = model;
	plots_haar(repetitions, money_dir, ySegms, xSegms, ...
			   model_rear, model_front, pattern_scales, if_load)
end