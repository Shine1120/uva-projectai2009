function [bestModels, alpha] = IEAdaboost(trainLabels, hypotheses,...
										  trainSetCombi,modelsCombi)

	%initialize weights
	Dt = ones(size(trainLabels,1),1)*(1/size(trainLabels,1));

	%transform labels to 1 and -1 in stead of 1 and 0. used for easy
	%calculations later on.
	labels_masked		= trainLabels;
	mask				= trainLabels == 0;
	labels_masked(mask) = -1;	

	bestModels			= zeros(hypotheses,2);

	% get the labels of all the trainingdata for all models
	[labels] = IEgetLabelsByGauss(trainSetCombi,modelsCombi);
	alpha	 = zeros(1,hypotheses);
	for t=1:hypotheses
		% for number of hypotseses hypotheses:
		% every iteration one model is selected
		for model = 1:size(labels,2)
			%per model find the labels that are different from the
			%groundtruth
			mask = labels(:,model) ~= trainLabels;
			%save weighted difference per model
			results(:,model) = Dt.*mask;
		end
		%sum to get results per model
		modelResults = sum(results);

		[sortedModelResults, sortedModelResultsIdx] =...
			sort(modelResults);

		searchForBestModel = 1;
		mNr = 1;
		while (searchForBestModel)
			%search for the best model that is not included in the
			%chosen models yet
			if mNr<= length(sortedModelResultsIdx)
				%first try to find a new model that has the highest ranking
				if ~ismember(sortedModelResultsIdx(mNr), bestModels(:,1))
					% if model not yet chosen
					alpha(t) =...
						0.5*log((1-sortedModelResults(mNr))/sortedModelResults(mNr));
					bestModels(t,1) = sortedModelResultsIdx(mNr);
					bestModels(t,2) = alpha(t);	
					searchForBestModel = 0;
				else
					% if model already chose, look for the next best one
					mNr = mNr+1;
				end
			else
				%if no new model found, get the first model
				alpha(t)		   = 0.5*log((1-sortedModelResults(1))/...
									 sortedModelResults(1));
				bestModels(t,1)    = sortedModelResultsIdx(1);
				bestModels(t,2)    = alpha(t);	
				searchForBestModel = 0;
				mNr				   = 1;
			end
		end

		labelsOfBestModel = labels(:,sortedModelResultsIdx(mNr));

		% update weights
		Dt = (Dt.*exp(-alpha(t).*labels_masked.*labelsOfBestModel));

		% normalize Dt so it will be a probability distribution 
		%  (it sums up to 1)
		Dt = Dt./sum(Dt);
	end

end

