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
	
	EoutFitFront = preprocessImg(fitFrontNames, fitDir, 2 );
	EoutFitRear = preprocessImg(fitRearNames, fitDir, 2 );
	EoutUnfitFront = preprocessImg(unfitFrontNames, unfitDir, 2 );
	EoutUnfitRear = preprocessImg(unfitRearNames, unfitDir, 2 );

	figure;
	hist((outFitFront+outFitRear)/2, 25);
	h = findobj(gca,'Type','patch');
	set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75);
	hold on;
	title('Intensity 5 euro');
	xlabel('Average intensity');
	ylabel('Counts');
	hist((outUnfitFront+outUnfitRear)/2, 25);
	h = findobj(gca,'Type','patch');
	set(h,'facealpha',0.75);
	hold off;
	
	figure;
	hist((EoutFitFront+EoutFitRear), 25);
	h = findobj(gca,'Type','patch');
	set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75);
	hold on;
	title('Edges 5 euro');
	xlabel('Sum of edge points');
	ylabel('Counts');
	hist((EoutUnfitFront+EoutUnfitRear), 25);
	h = findobj(gca,'Type','patch');
	set(h,'facealpha',0.75);
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
				out(i) = sum(sum(edge(img,'canny',0.0355)));
			end
	end


end