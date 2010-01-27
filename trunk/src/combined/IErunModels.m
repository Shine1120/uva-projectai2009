function resultLabels = IErunModels(modelsIN,bestModels,dataSet,alpha)

	sumLabels = zeros(size(dataSet,1),1);
	for modelNr=1:size(modelsIN,2)
		
		modelLabels =...
			IEgetLabelsByGauss(dataSet(:,bestModels(modelNr)),...
			modelsIN(:,modelNr));
		mask = modelLabels==0;
		modelLabels(mask) = -1;
		sumLabels = sumLabels + (modelLabels.*alpha(modelNr));
	end
	
	resultLabels		= sign(sumLabels);
	mask				= resultLabels<=0;
	resultLabels(mask)  = 0;
end
