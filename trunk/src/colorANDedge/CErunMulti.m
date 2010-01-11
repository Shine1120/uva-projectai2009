function [ output_args ] = CErunMulti( n )

sumTP=0;
sumTN=0;
for i=1:n
	[TP, TN] = CErun();
	sumTP = sumTP + TP;
	sumTN = sumTN + TN;
end
fprintf('\nresults for %d trials:\n',n)
fprintf('TP: %4.4g%%\n',sumTP/n)
fprintf('FN: %4.4g%%\n',100-sumTP/n)
fprintf('TP: %4.4g%%\n',sumTN/n)
fprintf('TP: %4.4g%%\n',100-sumTN/n)
