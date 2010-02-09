function [ output_args ] = IEshowAreasOnBill( Xsegs, Ysegs,...
	doFront,doRear,bestModels,do5Euro,do10Euro, titleTxt,overlap)

	%back up number of segments in x and y direction (those are updated
	%when overlap is true)
	XsegsOld = Xsegs;
	YsegsOld = Ysegs;

	if (overlap)
		%update number of segments in x and y direction
		Xsegs = ((Xsegs*2)-1);
		Ysegs = ((Ysegs*2)-1);
	end
	segsPerSide		= Xsegs * Ysegs;
	segsPerMethod	= segsPerSide * (doFront+doRear);
	
	%get images to show segments on
	if (do10Euro)
		imageNameFront	= '../moneyDivided/wholeplusborder/neur10/fit/f2.bmp';
		imageNameRear	= '../moneyDivided/wholeplusborder/neur10/fit/r2.bmp';
	end
	if (do5Euro)
		imageNameFront	= '../moneyDivided/wholeplusborder/neur05/fit/f2.bmp';
		imageNameRear	= '../moneyDivided/wholeplusborder/neur05/fit/r2.bmp';
	end
	
	%read the images
	imageFront		= imread(imageNameFront);
	imageRear		= imread(imageNameRear);
	
	%get size of images
	[frontY frontX] = size(imageFront);
	[rearY rearX]   = size(imageRear);

	%calculate the size of the segments
	segWidthFront   = round(frontX/XsegsOld);
	segHeightFront  = round(frontY/YsegsOld);
	segWidthRear    = round(rearX/XsegsOld);
	segHeightRear   = round(rearY/YsegsOld);
	
	%get method from model id (stored in bestModels)
	methodIdx		= ceil((bestModels./segsPerMethod));
	%get the location of the segments on front or rear reguardless of the
	%model it belongs too (model is already extracted)
	frontOrRear		= bestModels-((methodIdx-1)*segsPerMethod);
	%get segments that are on the front of the bill
	segInFront		= frontOrRear<=segsPerSide;
	frontSegs		= frontOrRear(segInFront);
	%get segments that are on the rear of the bill
	segInRear		= frontOrRear>segsPerSide;
	rearSegs		= frontOrRear(segInRear);
	%get the method number the segments belong too (to color them later on)
	frontMethod		= methodIdx(segInFront);
	rearMethod		= methodIdx(segInRear);

	%define colors and name (method number will corespond to index)
	colors	 = ['r','b'];
	MethName = ['E','I'];

	
	figure
	subplot(1,2,1)
	imshow(imageFront)
	title([titleTxt ' front'])
	hold on
	for i=1: length(frontSegs)
		%for all segments in the front of the bill
		
		%get location code of segment
		segment = frontSegs(i);
		%find what column and row the segment is in
		column = mod(segment,Xsegs);
		row = ((segment-column)/Xsegs)+1;
		if column==0
			column=Xsegs;
			row=row-1;
		end
		%get the x and y coordinates of left top corner according to the
		%row and column of the segment.
		x = ((column-1)*segWidthFront)+1;
		y = ((row-1)*segHeightFront)+1;		
		if (overlap)
			x = round(((column-1)/2)*segWidthFront)+1;
			y = round(((row-1)/2)*segHeightFront)+1;
		end
		%draw the rectangle on the imgae
		rectangle('Position',[x,y,segWidthFront,segHeightFront],'EdgeColor',colors(frontMethod(i)))
		%colot the rectangle
		p       = patch([x,x+segWidthFront,x+segWidthFront,x],...
						[y,y,y+segHeightFront,y+segHeightFront] , colors(frontMethod(i)));
		%set opacity for rectangle so overlapping rectangles can be
		%visualized
		% Remark: some matlab versions can not coop with opacity. comment
		% out if this is the case
		alpha(p , 0.3);
	end
	
	for i=1: length(frontSegs)
		% for all segments in front print a text that shows what method it
		% belongs too to make the output more readable
		segment = frontSegs(i);
		%get column and row of segment
		column = mod(segment,Xsegs);
		row = ((segment-column)/Xsegs)+1;
		if column==0
			column=Xsegs;
			row=row-1;
		end
		%get x and y coordinates
		x = ((column-1)*segWidthFront)+1;
		y = ((row-1)*segHeightFront)+1;		
		if (overlap)
			x = round(((column-1)/2)*segWidthFront)+1;
			y = round(((row-1)/2)*segHeightFront)+1;
		end

		%get method id of the segment
		[ignore memLoc] = ismember(bestModels, frontSegs(i)+((frontMethod(i)-1)*segsPerMethod));
		[ignore index] = sort(memLoc,'descend');
		shift = 0;
		%if method id is 2 print text a bit to the right to not overlap the
		%text of method 1
		if frontMethod(i)==2
			shift = 30;
		end
		segText = [MethName(frontMethod(i)) num2str(index(1))];
		text(x+4+shift,y+round(segHeightFront/2),segText)
	end
	hold off
	
	%for the rear same is done as explained for the front
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
