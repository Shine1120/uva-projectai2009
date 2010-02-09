% Remark: fit data has label 1 here and unfit label 0!


function [modelsOut, fitGoodRate, unfitGoodRate,goodClassified] =...
		  IErunModels(modelsIN,bestModels,dataSet,...
		  labels,alpha,plot)

	%after adaboost returns the chosen models here the models can be
	%applied to some data
	  
	if (plot)
		modelsOut = modelsIN;
	else
		modelsOut = modelsIN(:,bestModels(:,1));
	end

	sumLabels = zeros(size(dataSet,1),1);
	for modelNr=1:size(modelsOut,2)
		%for all models
		
		%get the labels from aplying MAP with the gaussian probability
		modelLabels =...
			IEgetLabelsByGauss(dataSet(:,bestModels(modelNr,1)),...
			modelsOut(:,modelNr));
		% transform label 0 to -1 for easy calculations
		mask = modelLabels==0;
		modelLabels(mask) = -1;
		% the labels weighted by the alphas ara summed. Because of the
		% labels (1 and -1) a positive summation indicates label 1 and a
		% negative summation indicates label 0.
		sumLabels = sumLabels +...
					(modelLabels.*alpha(modelNr)');%.*rescale(modelNr));
	end

	% extract labels from summed weghted labels
	resultLabels		= sign(sumLabels);
	mask				= resultLabels<=0;
	resultLabels(mask)  = 0;

	%get fit and unfit data from groundtruth
	fitData				= labels==1;
	unfitData			= labels==0;
	%get labels assigned by models just applied for fit and unfit data
	fitResults			= resultLabels(fitData);
	unfitResults		= resultLabels(unfitData);

	% all ones in fitGood are labels assigned correctly by models
	fitGood				= fitResults==1;
	fitGoodRate			= sum(fitGood)/size(fitGood,1);
	% all zeros in unfitGood are labels assigned correctly by models
	unfitGood			= unfitResults==0;
	unfitGoodRate		= sum(unfitGood)/size(unfitGood,1);
	goodClassified		= (sum(fitGood)+sum(unfitGood))./...
						  (size(fitGood,1)+size(unfitGood,1));
end
