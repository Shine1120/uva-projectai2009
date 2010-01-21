function [ output_args ] = IEshowAreasOnBill( Xsegs, Ysegs,...
	doFront,doRear,numberOfMethods,bestModels)

	segsPerSide = Xsegs * Ysegs;
	segsPerMethod = segsPerSide * (doFront+doRear);
	
	modelLijst = randperm(segsPerMethod*numberOfMethods);

	imageNameFront = '../money/wholeplusborder/neur10/fit/f1.bmp';
	imageNameRear = '../money/wholeplusborder/neur10/fit/r1.bmp';

	imageFront = imread(imageNameFront);
	imageRear  = imread(imageNameRear);
	
	[frontY frontX] = size(imageFront);
	[rearY rearX]   = size(imageRear);

	segWidthFront = round(frontX/Xsegs);
	segHeightFront = round(frontY/Ysegs);
	segWidthRear = round(rearX/Xsegs);
	segHeightRear = round(rearY/Ysegs);
	
	methodIdx   = ceil((bestModels./segsPerMethod));
	frontOrRear = bestModels-((methodIdx-1)*segsPerMethod);
	segInFront  = frontOrRear<=segsPerSide;
	segInRear   = frontOrRear>segsPerSide;
	frontSegs = frontOrRear(segInFront);
	rearSegs = frontOrRear(segInRear);
	frontMethod = methodIdx(segInFront);
	rearMethod = methodIdx(segInRear);
	
	figure(2)
	subplot(1,2,1)
	imshow(imageFront)
	title('front    blue: edge, red: intensity')
	hold on
	for i=1: length(frontSegs)
		segment = frontSegs(i);
		m = mod(segment,Xsegs);
		n = ((segment-m)/Xsegs)+1;
		if m==0
			m=Xsegs;
			n=n-1;
		end
		x = ((m-1)*segWidthFront)+1;
		y = ((n-1)*segHeightFront)+1;
		if frontMethod(i)==1
			color = 'b';
		elseif frontMethod(i)==2
			color = 'r';
		end
		rectangle('Position',[x,y,segWidthFront,segHeightFront],'EdgeColor',color)
	end
	hold off
	
	subplot(1,2,2)
	imshow(imageRear)
	title('rear')
	hold on
	for i=1: length(rearSegs)
		segment = rearSegs(i) - segsPerSide;
		m = mod(segment,Xsegs);
		n = ((segment-m)/Xsegs)+1;
		if m==0
			m=Xsegs;
			n=n-1;
		end
		x = ((m-1)*segWidthRear)+1;
		y = ((n-1)*segHeightRear)+1;
		if rearMethod(i)==1
			color = 'b';
		elseif rearMethod(i)==2
			color = 'r';
		end
		rectangle('Position',[x,y,segWidthRear,segHeightRear],'EdgeColor',color)
	end
	hold off
end

