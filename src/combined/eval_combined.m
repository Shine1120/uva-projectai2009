function eval_combined()

	doread		= 1;
% 	docreate	= 0;
	
	do5or10 = 5;

	
	if do5or10 == 5
		moneydir = '../moneyDivided/wholeplusborderHO/neur05';
	elseif do5or10 == 10
		moneydir = '../moneyDivided/wholeplusborderHO/neur10';
	end
		
	if (doread)
		fprintf('reading training data...\n');
		preprocessnew(moneydir);
	end

	load('all_money_rear');
	load('all_money_front');		
	load('all_labels')

	
	%haar evaluation
	fprintf('running Haar eval\n')
 	predH = final_eval(all_money_front,all_money_rear,do5or10);

	%Intensity & edges evaluation
	fprintf('running Intensity&edge eval\n')
	predIE = eval_IE(all_money_front, all_money_rear,do5or10);
	
	%pca evaluation
	fprintf('running PCA eval\n')
	predP = eval_pca(all_money_front, all_money_rear, all_labels, do5or10);


% 	predH				= rand(100,1);
% 	predH(predH >= 0.5) = 1;
% 	predH(predH <  0.5) = 0;
% 	
% 	predIE				  = rand(100,1);
% 	predIE(predIE >= 0.5) = 1;
% 	predIE(predIE <  0.5) = 0;
	
% 	predP				= rand(100,1);
% 	predP(predP >= 0.5) = 1;
% 	predP(predP <  0.5) = 0;

	pred1 = predH;
	pred2 = predIE;
	pred3 = predP;
	pred4 = predH+predIE;
	pred4(pred4<=1) = 0;
	pred4(pred4>1)  = 1;
	pred5 = predH+predP;
	pred5(pred5<=1) = 0;
	pred5(pred5>1)  = 1;
	pred6 = predIE+predP;
	pred6(pred6<=1) = 0;
	pred6(pred6>1)  = 1;
	pred7 = predH+predIE+predP;
	pred7(pred7<=1) = 0;
	pred7(pred7>1)  = 1;
	
	combPred = [pred1 pred2 pred3 pred4 pred5 pred6 pred7];

	mask_fit	= all_labels == 0;
	mask_unfit	= all_labels == 1;	
	
	results = zeros(4,size(combPred,2));
	
	for p = 1:size(combPred,2)
		error_unfit = 0;
		good_unfit  = 0;
		error_fit   = 0;	
		good_fit    = 0;
		for i=1:length(all_labels)
			if all_labels(i) == 1
				if (all_labels(i) == combPred(i,p))
					good_unfit = good_unfit+1;
				elseif (all_labels(i) ~= combPred(i,p))
					error_unfit = error_unfit + 1;
				end
			end
			if all_labels(i) == 0
				if (all_labels(i) == combPred(i,p))
					good_fit = good_fit + 1;
				elseif (all_labels(i) ~= combPred(i,p))
					error_fit = error_fit + 1;
				end
			end
		end
		error_unfit = error_unfit/sum(mask_unfit);
		good_unfit  = good_unfit/sum(mask_unfit);
		error_fit   = error_fit/sum(mask_fit);
		good_fit    = good_fit/sum(mask_fit);
		
		results(1,p) = good_unfit;
		results(2,p) = error_unfit;
		results(3,p) = good_fit;	
		results(4,p) = error_fit;
	end
%	results(5,:) = ['Haar' 'IE' 'PCA' 'Haar&IE' 'Haar&PCA' 'IE&PCA' 'Haar&IE&PCA']
	fprintf('\n\nThe results:\n')
	fprintf('Haar        -==->   unfit error: %1.2g \tfit error: %1.2g\n',results(2,1), results(4,1))
	fprintf('IE          -==->   unfit error: %1.2g \tfit error: %1.2g\n',results(2,2), results(4,2))
	fprintf('PCA         -==->   unfit error: %1.2g \tfit error: %1.2g\n',results(2,3), results(4,3))
	fprintf('Haar&IE     -==->   unfit error: %1.2g \tfit error: %1.2g\n',results(2,4), results(4,4))
	fprintf('Haar&PCA    -==->   unfit error: %1.2g \tfit error: %1.2g\n',results(2,5), results(4,5))
	fprintf('IE&PCA      -==->   unfit error: %1.2g \tfit error: %1.2g\n',results(2,6), results(4,6))
	fprintf('Haar&IE&PCA -==->   unfit error: %1.2g \tfit error: %1.2g\n',results(2,7), results(4,7))
end