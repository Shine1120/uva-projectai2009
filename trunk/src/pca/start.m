
doread = 0;
docreate = 0;

moneydir = '../money/wholeplusborder/neur05';

%% ------------- READ TRAINING DATA -------------------

if (doread)
	fprintf('reading training data...\n');
	preprocessnew(moneydir);
end

DNB_demo(docreate)



