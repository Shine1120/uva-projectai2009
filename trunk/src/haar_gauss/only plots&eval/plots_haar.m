%INPUT:
%		pattern_scales -- number of different scales generated for each	pattern
%		money_dir      -- the name of the money folder: 'neur10'/'neur05'
%		repetitions    -- number of repetitions (not too large: preferable 5)
%		ySegs          -- number of regions on Y coordinate (preferable 12)
%		xSegs          -- number of reguons on X coordinate (preferable 5)
%		model_rear     -- the rear model to be tested
%		model_front    -- th front model to be tested
%		if_load        -- 1 = load convolved images/ 0 = generate convolutions
%__________________________________________________________________________
function plots_haar(repetitions, money_dir, ySegms, xSegms, model_rear, model_front, pattern_scales, if_load)
	close all;
    fit             = ['moneyDivided/wholeplusborder/' money_dir '/fit/'];
    unfit           = ['moneyDivided/wholeplusborder/' money_dir '/unfit/'];	    
    hold_n_out      = 75;
	slice           = 35;
	dir_fit_rear    = dir([fit 'r*.bmp']);
	dir_unfit_rear  = dir([unfit 'r*.bmp']);
	dir_fit_front   = dir([fit 'f*.bmp']);
	dir_unfit_front = dir([unfit 'f*.bmp']);
	all_labels      = [zeros(1,size(dir_fit_front,1)) ones(1,size(dir_unfit_front,1))]';
 	%GET LABELS OF THE IMAGES FRONT AND REAR_______________________________
	for i=1:size(dir_fit_rear,1)+size(dir_unfit_rear,1) 
		if(i<=size(dir_fit_rear,1))
			names_rear{i}  = strcat(fit,dir_fit_rear(i).name);
			names_front{i} = strcat(fit,dir_fit_front(i).name);
		else
			names_rear{i}  = strcat(unfit,dir_unfit_rear(i-size(dir_fit_rear,1)).name);
			names_front{i} = strcat(unfit,dir_unfit_front(i-size(dir_fit_rear,1)).name);
		end
	end		
	%CONVOLVE IMAGES WITH THE PATTERNS_____________________________________     
	if( if_load == 0 )
		patterns           = save_patterns(250,400,pattern_scales);						
		convolutions_rear  = preprocess(ySegms,xSegms,1,names_rear,patterns,'rear'); 
		convolutions_front = preprocess(ySegms,xSegms,1,names_front,patterns,'front'); 
	else
		load 'convolved_images_front'
		load 'convolved_images_rear'
		load 'patterns'	
	end
	min_error_rear   = 1; min_error_front  = 1;
	best_index_rear  = 1; best_index_front = 1;
	%START REPETITIONS OF CROSSVALIDATION__________________________________
	for r=1:repetitions	
		%DEFINE HOLDOUT SET________________________________________________ 	
		all_id          = randperm(length(all_labels));		
		holdout_id      = all_id(1:hold_n_out);
		rest_id         = all_id(hold_n_out+1:end);	
		%AT LEASt ONE FIT/UNFIT IMAGE IN THE HOLDOUT SET___________________
		while ( sum(all_labels(holdout_id)==0)==0 || sum(all_labels(holdout_id)==1)==0)
			all_id     = randperm(length(all_labels));		
			holdout_id = all_id(1:hold_n_out);
			rest_id    = all_id(hold_n_out+1:end);	
		end	 
 		labels_holdout     = all_labels(holdout_id);
 		ImgHoldout_front   = convolutions_front(holdout_id,:);
 		ImgHoldout_rear    = convolutions_rear(holdout_id,:); 
        voted_indexes_rear = model_rear.best_ids;                
        voted_indexes_front = model_front.best_ids;       
        [incorrect_plot_rear_fit(r,:), incorrect_plot_rear_unfit(r,:), ...
		  incorrect_plot_front_fit(r,:), incorrect_plot_front_unfit(r,:), ...
		  incorrect_plot_both_fit(r,:), incorrect_plot_both_unfit(r,:)] = ...
		evaluate(model_front, model_rear, labels_holdout, ImgHoldout_front, ImgHoldout_rear);    
	end
	plot_rear_fit = mean(incorrect_plot_rear_fit,1);
	plot_rear_unfit = mean(incorrect_plot_rear_unfit,1);
	plot_front_fit = mean(incorrect_plot_front_fit,1);
	plot_front_unfit = mean(incorrect_plot_front_unfit,1);
	plot_both_fit = mean(incorrect_plot_both_fit,1);
	plot_both_unfit = mean(incorrect_plot_both_unfit,1);
	
	plot([1:size(model_rear.best_ids,2)],plot_rear_fit,'g-s', ...
		 [1:size(model_rear.best_ids,2)],plot_rear_unfit,'g-*', ...
		 [1:size(model_rear.best_ids,2)],plot_front_fit,'r-s', ...
		 [1:size(model_rear.best_ids,2)],plot_front_unfit,'r-*', ...
		 [1:size(model_rear.best_ids,2)],plot_both_fit,'b-s', ...
		 [1:size(model_rear.best_ids,2)],plot_both_unfit,'b-*');
	xlabel('model');ylabel('error');
    legend('Rear Fit','Rear Unfit','Front Fit', 'Front Unfit', 'Both Fit', 'Both Unfit');
	plot_regions(ySegms, xSegms, voted_indexes_rear, 'rear', fit);
	plot_regions(ySegms, xSegms, voted_indexes_front, 'front', fit);	
end