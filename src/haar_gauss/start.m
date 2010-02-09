function start
%   T              -- number of features to be used (not too large :P)
%   rounds         -- number of rounds for cross-validation
%   pattern_scales -- number of different scales generated for each	pattern
%   money_dir      -- the name of the money folder: 'neur10'/'neur05'
%   repetitions    -- number of repetitions (not too large: preferable 5)
%   ySegs          -- number of regions on Y coordinate (preferable 12)
%   xSegs          -- number of reguons on X coordinate (preferable 5)
%	if_load        -- 1 = load convolved images/ 0 = generate convolutions
%__________________________________________________________________________
    T              = 20;
	rounds         = 10;
	pattern_scales = 1;
	money_dir      = 'neur10'; % 'neur05';  
 	repetitions    = 5;
	ySegms		   = 12;
	xSegms		   = 5;
	if_load        = 0;
	classification_haar(T, rounds, repetitions, ySegms, xSegms, money_dir, ...
						pattern_scales, if_load);
end