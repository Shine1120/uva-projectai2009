function [bestModels, alpha] = IEAdaboost(trainLabels, hypotheses,...
										  trainSetCombi,modelsCombi)

	%initialize weights
	Dt = ones(size(trainLabels,1),1)*(1/size(trainLabels,1));

	labels_masked		= trainLabels;
	mask				= trainLabels == 0;
	labels_masked(mask) = -1;	

	bestModels			= zeros(hypotheses,2);

	[labels] = IEgetLabelsByGauss(trainSetCombi,modelsCombi);
	alpha	 = zeros(1,hypotheses);
	for t=1:hypotheses
		for model = 1:size(labels,2)
			mask = labels(:,model) ~= trainLabels;
			results(:,model) = Dt.*mask;
		end
		modelResults = sum(results);

		[sortedModelResults, sortedModelResultsIdx] =...
			sort(modelResults);

		searchForBestModel = 1;
		mNr = 1;
		while (searchForBestModel)
			%search for the best model that is not included in the
			%chosen models yet
			if mNr<= length(sortedModelResultsIdx)
				if ~ismember(sortedModelResultsIdx(mNr), bestModels(:,1))
					alpha(t) =...
						0.5*log((1-sortedModelResults(mNr))/sortedModelResults(mNr));
					bestModels(t,1) = sortedModelResultsIdx(mNr);
					bestModels(t,2) = alpha(t);	
					searchForBestModel = 0;
				else
					mNr = mNr+1;
				end
			else
				alpha(t)		   = 0.5*log((1-sortedModelResults(1))/...
									 sortedModelResults(1));
				bestModels(t,1)    = sortedModelResultsIdx(1);
				bestModels(t,2)    = alpha(t);	
				searchForBestModel = 0;
			end
		end

		% update instance weights
		labelsOfBestModel = labels(:,sortedModelResultsIdx(mNr));

		Dt = (Dt.*exp(-alpha(t).*labels_masked.*labelsOfBestModel));

		% normalize Dt so it will be a probability distribution 
		%  (it sums up to 1)
		Dt = Dt./sum(Dt);
	end

end

