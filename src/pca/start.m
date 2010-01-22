
doread = 0;
docreate = 0;

moneydir = '../validationset/wholeplusborder/neur10';

%% ------------- READ TRAINING DATA -------------------

if (doread)
	fprintf('reading training data...\n');
	preprocessnew(moneydir);
end

DNB_demo(docreate)



