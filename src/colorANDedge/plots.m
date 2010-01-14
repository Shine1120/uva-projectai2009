function plots()


	close all;
	
	fitDir = '../money/wholeplusborder/neur10/fit/';

	fitFrontNames = dir([fitDir 'f*.bmp']);
	fitRearNames = dir([fitDir 'r*.bmp']);
	
	
	unfitDir = '../money/wholeplusborder/neur10/unfit/';
	unfitFrontNames = dir([unfitDir 'f*.bmp']);
	unfitRearNames = dir([unfitDir 'r*.bmp']);
	
	outFitFront = preprocessImg(fitFrontNames, fitDir, 1 );
	outFitRear = preprocessImg(fitRearNames, fitDir, 1 );
	outUnfitFront = preprocessImg(unfitFrontNames, unfitDir, 1 );
	outUnfitRear = preprocessImg(unfitRearNames, unfitDir, 1 );
	
	EoutFitFront = preprocessImg(fitFrontNames, fitDir, 1 );
	EoutFitRear = preprocessImg(fitRearNames, fitDir, 1 );
	EoutUnfitFront = preprocessImg(unfitFrontNames, unfitDir, 1 );
	EoutUnfitRear = preprocessImg(unfitRearNames, unfitDir, 1 );

	figure;
	hold on;
	title('Fit Intensity');
	hist(outFitFront+outFitRear/2, 25);
	hold off;
	figure;
	hold on;
	title('Unfit Intensity');
	hist(outUnfitFront+outUnfitRear/2, 25);
	hold off;

	figure;
	hold on;
	title('Fit Edge');
	hist(EoutFitFront+EoutFitRear/2, 25);
	hold off;
	figure;
	hold on;
	title('Unfit Edge');
	hist(EoutUnfitFront+EoutUnfitRear/2, 25);
	hold off;
end


function out = preprocessImg(imageNames, dir_name, s)


	switch s
		case 1
			for i=1:length(imageNames)
				img = imread([dir_name imageNames(i).name]);
				out(i) = mean(mean(img));
			end
		case 2
			for i=1:length(imageNames)
				img = imread([dir_name imageNames(i).name]);
				img = img - mean(img);
				out(i) = sum(sum(edge(img,'canny',0.0355)));
			end
	end


end