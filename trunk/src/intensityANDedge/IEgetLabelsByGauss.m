function [ labels ] = IEgetLabelsByGauss(data,models)

	%get the values for the gaussian distributions from models
	meanFit   = models(1,:);
	covFit    = models(2,:);
	meanUnfit = models(3,:);
	covUnfit  = models(4,:);

	%initialize labels
	labels = zeros(size(data,1),size(data,2));
	if ~isempty(data)
		for x=1:size(models,2)
			%for all models
			for y=1:size(data,1)
				%for all data (images/segments)
				
				%get the probability of the data belonging to fit or unfit
				probBeFit      = mvnpdf(data(y,x),meanFit(x),covFit(x));
				probBeUnfit    = mvnpdf(data(y,x),meanUnfit(x),covUnfit(x));

				%calculate the final probability using MAP
				% prior probability for a fit bill is 60% 
				% and for a unfit bill is 40%
				sumProb = (0.6 * probBeFit + 0.4 * probBeUnfit);
				finalFitProb   = (0.6 * probBeFit)/sumProb; 
				finalUnfitProb = (0.4 * probBeUnfit)/sumProb; 

				%if the probability for a fit bill is higher then the
				%probability of an unfit bill label 1 is given to this
				%data-item
				if finalFitProb>finalUnfitProb
					labels(y,x) = 1;
				else
					labels(y,x) = 0;
				end
			end
		end
	end
end

        