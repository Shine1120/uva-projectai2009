function [modelsOut, TPRate, TNRate,goodClassified] =...
		  IErunModels(modelsIN,bestModels,dataSet,...
		  labels,alpha,rescale)

	modelsOut = modelsIN(:,bestModels(:,1));

	sumLabels = zeros(size(dataSet,1),1);
	for modelNr=1:size(modelsOut,2)
		modelLabels =...
			IEgetLabelsByGauss(dataSet(:,bestModels(modelNr,1)),...
			modelsOut(:,modelNr));
		mask = modelLabels==0;
		modelLabels(mask) = -1;
		sumLabels = sumLabels +...
					(modelLabels.*alpha(modelNr).*rescale(modelNr));
	end

	resultLabels		= sign(sumLabels);
	mask				= resultLabels<=0;
	resultLabels(mask)  = 0;

	fitData					= labels==1;
	unfitData				= labels==0;

	fitResults			= resultLabels(fitData);
	unfitResults		= resultLabels(unfitData);

	TP					= fitResults==1;
	TPRate				= sum(TP)/size(TP,1);
	TN					= unfitResults==0;
	TNRate				= sum(TN)/size(TN,1);
	goodClassified		= (sum(TP)+sum(TN))./(size(TP,1)+size(TN,1));
end

