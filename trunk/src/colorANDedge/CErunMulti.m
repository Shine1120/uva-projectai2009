function [ output_args ] = CErunMulti( n )

sumTP=0;
sumTN=0;
allDataFitE    = [];
allDataFitC    = [];
allDataFitCofE = [];
allDataUnfitE    = [];
allDataUnfitC    = [];
allDataUnfitCofE = [];
nrIndxesFit    = 0;
nrIndxesUnfit  = 0;
for i=1:n
	tic
	fprintf('\n*********************************************\n')
	fprintf('\t**************************************\n')
	fprintf('\t\t\tstarting run number %d\n', i)
	fprintf('\t**************************************\n')
	fprintf('*********************************************\n')
	[TP,TN,allDataFitE,allDataFitC,allDataFitCofE,allDataUnfitE,...
		allDataUnfitC,allDataUnfitCofE,nrIndxesFit,nrIndxesUnfit] =...
		CErun(allDataFitE,allDataFitC,allDataFitCofE,allDataUnfitE,...
		allDataUnfitC,allDataUnfitCofE,nrIndxesFit,nrIndxesUnfit,i-1);
	sumTP = sumTP + TP;
	sumTN = sumTN + TN;
	toc
end
fprintf('\n\nresults for %d trials:\n',n)
fprintf('TP: %4.4g%%\n',sumTP/n)
fprintf('FN: %4.4g%%\n',100-sumTP/n)
fprintf('TN: %4.4g%%\n',sumTN/n)
fprintf('FP: %4.4g%%\n',100-sumTN/n)
