function plotHisto()
	[ImgSet_rear, ImgSet_front, labels] = labelsAndSets();
	patterns = save_patterns(85,120,1);
	for i=1:size(patterns,2)
		fprintf('\t Pattern %d\n',i)
		index_fit = 0;
		index_unfit = 0;
		for k=1:size(ImgSet_front,3)				
			fprintf('\t Front images: %d \t Patern: %d\n',k,i)
			convImg         = conv2(ImgSet_front(:,:,k), patterns(i).rectangles);
			filter          = (convImg<0);
			convImg(filter) = 0;
			values(k)       = sum(sum(convImg));
			if(labels(k) == 0)
				index_fit = index_fit + 1;
				conv_fit_front(i,index_fit) = values(k);	
			else
				index_unfit = index_unfit + 1;
				conv_unfit_front(i,index_unfit) = values(k);	
			end
			
		end	
		
		index_fit = 0;
		index_unfit = 0;
		for k=1:size(ImgSet_rear,3)				
			fprintf('\t Rear images: %d \t Patern: %d\n',k,i)
			convImg         = conv2(ImgSet_rear(:,:,k), patterns(i).rectangles);
			filter          = (convImg<0);
			convImg(filter) = 0;
			values(k)       = sum(sum(convImg));			
			if(labels(k) == 0)
				index_fit = index_fit + 1;
				conv_fit_rear(i,index_fit) = values(k);	
			else
				index_unfit = index_unfit + 1;
				conv_unfit_rear(i,index_unfit) = values(k);	
			end
		end	
	end
	convFitFront = mean(conv_fit_front,1);
	convUnfitFront = mean(conv_unfit_front,1);
	
	convFitRear = mean(conv_fit_rear,1);
	convUnfitRear = mean(conv_unfit_rear,1);
	
	figure;hold on;
	title('Fit Convolution');
	hist((convFitFront+convFitRear)/2, 25);
	hold off;figure;hold on;
	title('Unfit Concolution');
	hist((convUnfitFront+convUnfitRear)/2, 25);
	hold off;
end

function [Img_rear, Img_front, all_labels] = labelsAndSets()
	close all;
    % Do the CROSS-VALIDATION loop
    money_dir  = 'neur10'; % 'neur05';  
    fit        = [money_dir '/fit/'];
    unfit      = [money_dir '/unfit/'];	
	dir_fit_rear    = dir([fit 'r*.bmp']);
	dir_unfit_rear  = dir([unfit 'r*.bmp']);
	dir_fit_front   = dir([fit 'f*.bmp']);
	dir_unfit_front = dir([unfit 'f*.bmp']);
	all_labels      = [zeros(1,size(dir_fit_front,1)) ones(1,size(dir_unfit_front,1))]';
 	for i=1:size(dir_fit_rear,1)+size(dir_unfit_rear,1) %save images names for FIT (front/rear)
 		if(i<=size(dir_fit_rear,1))
 			names_rear{i}  = strcat(fit,dir_fit_rear(i).name);
 			names_front{i} = strcat(fit,dir_fit_front(i).name);
 		else
 			names_rear{i}  = strcat(unfit,dir_unfit_rear(i-size(dir_fit_rear,1)).name);
 			names_front{i} = strcat(unfit,dir_unfit_front(i-size(dir_fit_rear,1)).name);
 		end
	end	
	
	Img_rear  = preprocess(1,names_rear); 
	Img_front = preprocess(1,names_front);
end
