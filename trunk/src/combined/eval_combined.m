function eval_combined()

	doread		= 0;
	docreate	= 1;

	moneydir = 'moneyDivided/wholeplusborderHO/neur10';

	predictions = [];


	if (doread)
		fprintf('reading training data...\n');
		preprocessnew(moneydir);
	end

	load('all_money_rear');
	load('all_money_front');		
	load('all_labels')

	%haar evaluation
% 	predictionsHaar = final_eval(all_money_front,all_money_rear);
% 	predictions = [predictions predictionsHaar];

	%Intensity & edges evaluation
	predictionsIE = eval_IE(all_money_front, all_money_rear);
	predictions = [predictions predictionsIE];
	
	%pca evaluation
%	predictionsPCA = eval_pca(all_money_front, all_money_rear, all_labels, docreate);
%	predictions = [predictions predictionsPCA];

	stop
	
	mask_fit = all_labels == 0;
	mask_unfit = all_labels == 1;	
	
	error_unfit = 0;
	good_unfit  = 0;
	error_fit   = 0;	
	good_fit    = 0;

	for i=1:length(all_labels)
		if (all_labels(i) == predictions(i) && all_labels(i) == 1)
			good_unfit = good_unfit+1;
		elseif (all_labels(i) ~= predictions(i) && all_labels(i) == 1)
			error_unfit = error_unfit + 1;
		elseif (all_labels(i) == predictions(i) && all_labels(i) == 0)
			good_fit = good_fit + 1;
		elseif (all_labels(i) ~= predictions(i) && all_labels(i) == 0)
			error_fit = error_fit + 1;
		end
	end
	
	error_unfit = error_unfit/sum(mask_unfit)
	good_unfit  = good_unfit/sum(mask_unfit)

	error_fit   = error_fit/sum(mask_fit)
	good_fit    = good_fit/sum(mask_fit)

	
	
end