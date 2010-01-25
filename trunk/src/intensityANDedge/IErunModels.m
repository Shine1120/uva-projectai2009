function [modelsOut, fitGoodRate, unfitGoodRate,goodClassified] =...
		  IErunModels(modelsIN,bestModels,dataSet,...
		  labels,alpha,plot)

	if (plot)
		modelsOut = modelsIN;
	else
		modelsOut = modelsIN(:,bestModels(:,1));
	end

	sumLabels = zeros(size(dataSet,1),1);
	for modelNr=1:size(modelsOut,2)
		modelLabels =...
			IEgetLabelsByGauss(dataSet(:,bestModels(modelNr,1)),...
			modelsOut(:,modelNr));
		mask = modelLabels==0;
		modelLabels(mask) = -1;
		sumLabels = sumLabels +...
					(modelLabels.*alpha(modelNr)');%.*rescale(modelNr));
	end

	resultLabels		= sign(sumLabels);
	mask				= resultLabels<=0;
	resultLabels(mask)  = 0;

	fitData				= labels==1;
	unfitData			= labels==0;

	fitResults			= resultLabels(fitData);
	unfitResults		= resultLabels(unfitData);

	fitGood				= fitResults==1;
	fitGoodRate			= sum(fitGood)/size(fitGood,1);
	unfitGood			= unfitResults==0;
	unfitGoodRate		= sum(unfitGood)/size(unfitGood,1);
	goodClassified		= (sum(fitGood)+sum(unfitGood))./...
						  (size(fitGood,1)+size(unfitGood,1));
end
