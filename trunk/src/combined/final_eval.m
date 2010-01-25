%INPUT: 
%		holdoutSetRear  -- images as they are (not modified) - 3D
%		holdoutSetFront -- images as they are (not modified) - 3D
%OUTPUT 
%		predictions     -- predictions for both
function return_value = final_eval(holdoutSetRear,holdoutSetFront)
 	%GET LABELS OF THE IMAGES FRONT AND REAR_______________________________
	ySegms = 12;
	xSegms = 5;
 	load 'patterns'
	for i=1:size(holdoutSetRear, 3)
		Img                    = imresize_old(holdoutSetRear(:,:,i),[400 250]);
		convolutions_rear(i,:) = generate_convolutions(ySegms,xSegms,400,250,patterns,Img); 
	end
	
	for i=1:size(holdoutSetFront,3)
		Img                     = imresize_old( holdoutSetFront(:,:,i),[400 250]);
		convolutions_front(i,:) = generate_convolutions(ySegms,xSegms,400,250,patterns,Img); 
	end
	
	%COMPUTE PROBABILITIES_________________________________________________	
	load 'model_neur10_handout_front.mat'
	classifier_front = just_eval(model,convolutions_front);

	load 'model_neur10_handout_rear.mat';
	classifier_rear = just_eval(model,convolutions_rear);
	
	%both_holdout = 1-(1-classifier_front).*(1-classifier_rear);	
	both_holdout = classifier_rear + classifier_front;
	return_value = (both_holdout>=0)';
end

function classifier = just_eval(model, convImg)
	prior_fit   = 0.5;
	prior_unfit = 0.5;
	for i=1:size(model.best_ids,2)
		id = model.best_ids(i);
		for j=1:size(convImg,1)
			prob_fit(j)     = mvnpdf(convImg(j,id), model.mean_fit(id), model.cov_fit(id));
			prob_unfit(j)   = mvnpdf(convImg(j,id), model.mean_unfit(id), model.cov_unfit(id));
			final_fit(j)    = (prior_fit * prob_fit(j))/(prior_fit * prob_fit(j) + prior_unfit * prob_unfit(j));
			final_unfit(j)  = (prior_unfit * prob_unfit(j))/(prior_fit * prob_fit(j) + prior_unfit * prob_unfit(j));
			recognized(i,j) = (final_fit(j)<=final_unfit(j));
		end	
	end	
	%classifier = ((model.weights * recognized) >= sum(0.5*(model.weights)));			
	classifier = ((model.weights * recognized) - sum(0.5*(model.weights)));			
end
