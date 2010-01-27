function [ labels ] = IEgetLabelsByGauss(data,models)

	meanFit   = models(1,:);
	covFit    = models(2,:);
	meanUnfit = models(3,:);
	covUnfit  = models(4,:);

	labels = zeros(size(data,1),size(data,2));
	if ~isempty(data)
		for x=1:size(models,2)
			for y=1:size(data,1)
				probBeFit   = mvnpdf(data(y,x),meanFit(x),covFit(x));
				probBeUnfit = mvnpdf(data(y,x),meanUnfit(x),covUnfit(x));

				if probBeFit>probBeUnfit
					labels(y,x) = 0;
				else
					labels(y,x) = 1;
				end
			end
		end
	end
end

