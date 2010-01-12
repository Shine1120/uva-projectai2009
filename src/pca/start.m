
doread = 0;

moneydir = 'whole/neur10';

if (doread)
	all_money_front = []; all_money_rear = []; all_labels = [];
end



%% ------------- READ TRAINING DATA -------------------

if (doread)
	fprintf('reading training data...\n');
	[all_money_front all_money_rear all_labels] = preprocessnew(moneydir);
	save all_money_front.mat all_money_front
	save all_money_rear.mat all_money_rear
	save all_labels.mat all_labels
end



DNB_demo()%(all_money_front, all_money_rear, all_labels)