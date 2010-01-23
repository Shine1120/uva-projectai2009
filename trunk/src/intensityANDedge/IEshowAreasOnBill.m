function [ output_args ] = IEshowAreasOnBill( Xsegs, Ysegs,...
	doFront,doRear,bestModels,do5Euro,do10Euro)

	segsPerSide		= Xsegs * Ysegs;
	segsPerMethod	= segsPerSide * (doFront+doRear);
	
	if do10Euro
		imageNameFront	= '../moneyDivided/wholeplusborder/neur10/fit/f2.bmp';
		imageNameRear	= '../moneyDivided/wholeplusborder/neur10/fit/r2.bmp';
	end
	if (do5Euro)
		imageNameFront	= '../moneyDivided/wholeplusborder/neur05/fit/f2.bmp';
		imageNameRear	= '../moneyDivided/wholeplusborder/neur05/fit/r2.bmp';
	end
	

	imageFront		= imread(imageNameFront);
	imageRear		= imread(imageNameRear);
	
	[frontY frontX] = size(imageFront);
	[rearY rearX]   = size(imageRear);

	segWidthFront   = round(frontX/Xsegs);
	segHeightFront  = round(frontY/Ysegs);
	segWidthRear    = round(rearX/Xsegs);
	segHeightRear   = round(rearY/Ysegs);
	
	methodIdx		= ceil((bestModels./segsPerMethod));
	frontOrRear		= bestModels-((methodIdx-1)*segsPerMethod);
	segInFront		= frontOrRear<=segsPerSide;
	segInRear		= frontOrRear>segsPerSide;
	frontSegs		= frontOrRear(segInFront);
	rearSegs		= frontOrRear(segInRear);
	frontMethod		= methodIdx(segInFront);
	rearMethod		= methodIdx(segInRear);

	colors = ['r','b'];
	MethName = ['E','I'];

	
	figure(2)
	subplot(1,2,1)
	imshow(imageFront)
	title('front    red: edge, blue: intensity')
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

		rectangle('Position',[x,y,segWidthFront,segHeightFront],'EdgeColor',colors(frontMethod(i)))
		p       = patch([x,x+segWidthFront,x+segWidthFront,x],...
						[y,y,y+segHeightFront,y+segHeightFront] , colors(frontMethod(i)));
		alpha(p , 0.3);
%		set(p,'AlphaDataMapping', 0.2)	
	end
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
		[ignore memLoc] = ismember(bestModels, frontSegs(i)+((frontMethod(i)-1)*segsPerMethod));
		[ignore index] = sort(memLoc,'descend');
		shift = 0;
		if frontMethod(i)==2
			shift = 30;
		end
		segText = [MethName(frontMethod(i)) num2str(index(1))];
		text(x+4+shift,y+round(segHeightFront/2),segText)
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
		
		rectangle('Position',[x,y,segWidthRear,segHeightRear],'EdgeColor',colors(rearMethod(i)))
		p       = patch([x,x+segWidthRear,x+segWidthRear,x],...
						[y,y,y+segHeightRear,y+segHeightRear] , colors(rearMethod(i)));
		alpha(p , 0.3);
%		set(p,'AlphaDataMapping', 0.2)	
	end
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
		[ignore memLoc] = ismember(bestModels, rearSegs(i)+((rearMethod(i)-1)*segsPerMethod));
		[ignore index] = sort(memLoc,'descend');
		shift = 0;
		if rearMethod(i)==2
			shift = 30;
		end
		segText = [MethName(rearMethod(i)) num2str(index(1))];
		text(x+4+shift,y+round(segHeightFront/2),segText)
	end
	hold off
end
