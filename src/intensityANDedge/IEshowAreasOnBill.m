function [ output_args ] = IEshowAreasOnBill( Xsegs, Ysegs,...
	doFront,doRear,bestModels,do5Euro,do10Euro, titleTxt,overlap)


	YsegsOld = Ysegs;
	XsegsOld = Xsegs;

	if (overlap)
		Xsegs = ((Xsegs*2)-1);
		Ysegs = ((Ysegs*2)-1);
	end
	segsPerSide		= Xsegs * Ysegs;
	segsPerMethod	= segsPerSide * (doFront+doRear);
	
	if (do10Euro)
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

	segWidthFront   = round(frontX/XsegsOld);
	segHeightFront  = round(frontY/YsegsOld);
	segWidthRear    = round(rearX/XsegsOld);
	segHeightRear   = round(rearY/YsegsOld);
	
	methodIdx		= ceil((bestModels./segsPerMethod));
	frontOrRear		= bestModels-((methodIdx-1)*segsPerMethod);
	segInFront		= frontOrRear<=segsPerSide;
	segInRear		= frontOrRear>segsPerSide;
	frontSegs		= frontOrRear(segInFront);
	rearSegs		= frontOrRear(segInRear);
	frontMethod		= methodIdx(segInFront);
	rearMethod		= methodIdx(segInRear);

	colors	 = ['r','b'];
	MethName = ['E','I'];

	
	figure
	subplot(1,2,1)
	imshow(imageFront)
	title([titleTxt ' front'])
	hold on
	for i=1: length(frontSegs)
		segment = frontSegs(i);
		column = mod(segment,Xsegs);
		row = ((segment-column)/Xsegs)+1;
		if column==0
			column=Xsegs;
			row=row-1;
		end
		
		x = ((column-1)*segWidthFront)+1;
		y = ((row-1)*segHeightFront)+1;		
		if (overlap)
			x = round(((column-1)/2)*segWidthFront)+1;
			y = round(((row-1)/2)*segHeightFront)+1;
		end

		rectangle('Position',[x,y,segWidthFront,segHeightFront],'EdgeColor',colors(frontMethod(i)))
		p       = patch([x,x+segWidthFront,x+segWidthFront,x],...
						[y,y,y+segHeightFront,y+segHeightFront] , colors(frontMethod(i)));
		alpha(p , 0.3);
	end
	for i=1: length(frontSegs)
		segment = frontSegs(i);
		column = mod(segment,Xsegs);
		row = ((segment-column)/Xsegs)+1;
		if column==0
			column=Xsegs;
			row=row-1;
		end
		
		x = ((column-1)*segWidthFront)+1;
		y = ((row-1)*segHeightFront)+1;		
		if (overlap)
			x = round(((column-1)/2)*segWidthFront)+1;
			y = round(((row-1)/2)*segHeightFront)+1;
		end

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
	title('rear    red: edge, blue: intensity')
	hold on
	for i=1: length(rearSegs)
		segment = rearSegs(i) - segsPerSide;
		column = mod(segment,Xsegs);
		row = ((segment-column)/Xsegs)+1;
		if column==0
			column=Xsegs;
			row=row-1;
		end
		
		x = ((column-1)*segWidthRear)+1;
		y = ((row-1)*segHeightRear)+1;		
		if (overlap)
			x = round(((column-1)/2)*segWidthRear)+1;
			y = round(((row-1)/2)*segHeightRear)+1;
		end
		
		rectangle('Position',[x,y,segWidthRear,segHeightRear],'EdgeColor',colors(rearMethod(i)))
		p       = patch([x,x+segWidthRear,x+segWidthRear,x],...
						[y,y,y+segHeightRear,y+segHeightRear] , colors(rearMethod(i)));
		alpha(p , 0.3);
	end
	for i=1: length(rearSegs)
		segment = rearSegs(i) - segsPerSide;
		column = mod(segment,Xsegs);
		row = ((segment-column)/Xsegs)+1;
		if column==0
			column=Xsegs;
			row=row-1;
		end
		
		x = ((column-1)*segWidthRear)+1;
		y = ((row-1)*segHeightRear)+1;		

		if (overlap)
			x = round(((column-1)/2)*segWidthRear)+1;
			y = round(((row-1)/2)*segHeightRear)+1;
		end
		
		[ignore memLoc] = ismember(bestModels, rearSegs(i)+((rearMethod(i)-1)*segsPerMethod));
		[ignore index] = sort(memLoc,'descend');
		shift = 0;
		if rearMethod(i)==2
			shift = 30;
		end
		segText = [MethName(rearMethod(i)) num2str(index(1))];
		text(x+4+shift,y+round(segHeightRear/2),segText)
	end
	hold off
end
