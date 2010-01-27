function allResults = IEgetDataSet( do,moneyFront,moneyRear,cannyThresh,...
									useFront, useRear, xSegms, ySegms,overlap)

	imgNr=1;
	allResults=[0,0];
	
	for i = 1:size(moneyFront,3)
		%for all images: extract the data

	  %load images as required in the initialization at the top
		if (useFront)
			nextImageFront = moneyFront(:,:,i);
		end
		if (useRear)
			nextImageRear  = moneyRear(:,:,i);
		end

		imgSegFX = floor((size(nextImageFront,2)-1)/xSegms);
		imgSegFY = floor((size(nextImageFront,1)-1)/ySegms);
		imgSegRX = floor((size(nextImageRear,2)-1)/xSegms);
		imgSegRY = floor((size(nextImageRear,1)-1)/ySegms);

	  %get the data for classification
	  
	  if strcmp(do,'edge')
		if (useFront)
		  frontImageResults = doEdge(nextImageFront,cannyThresh,...
			  0,imgSegFX,imgSegFY,overlap);
		end
		if (useRear)
		  rearImageResults  = doEdge(nextImageRear,cannyThresh,...
			  0,imgSegRX,imgSegRY,overlap);
		end
	  end
	  if strcmp(do,'Intensity')
		if (useFront)
		  frontImageResults = doIntensity(nextImageFront,...
			  0,imgSegFX,imgSegFY,overlap);
		end
		if (useRear)
		  rearImageResults  = doIntensity(nextImageRear,...
			  0,imgSegRX,imgSegRY,overlap);
		end
	  end

	  allResults(imgNr,1:xSegms*ySegms*2)=0;
	  if (useFront)
		insMin = 1;  
		insMax = size(frontImageResults,2);  
		allResults(imgNr,insMin:insMax) = frontImageResults;
	  end
	  if (useRear)
		insMin = size(frontImageResults,2)+1;  
		insMax = size(frontImageResults,2)+size(rearImageResults,2);  
		allResults(imgNr,insMin:insMax) = rearImageResults;
	  end

	  %raise image count
	  imgNr=imgNr+1;
	end %for images
end

function results = doEdge(image,cannyThresh,invariant,imgSegX, imgSegY,overlap)
	if invariant==1
		image = image - mean(mean(image));
	end
	edgeImage = edge(image,'canny',cannyThresh);
	
	%do per image segment and store in vector
	results = [];
	count=1;
	
	yStepSize = imgSegY;
	xStepSize = imgSegX;
	if (overlap)
		yStepSize = floor(imgSegY/2);
		xStepSize = floor(imgSegX/2);
	end
	
	for y=1:yStepSize:size(image,1)-imgSegY
		for x=1:xStepSize:size(image,2)-imgSegX
			if y+imgSegY+10>size(image,1)
				untillY = size(image,1);
			else
				untillY = y+imgSegY-1;
			end
			if x+imgSegX+10>size(image,2)
				untillX = size(image,2);
			else
				untillX = x+imgSegX-1;
			end
			results(count) = sum(sum(edgeImage(y:untillY,x:untillX)));
			count = count+1;
		end
	end
end

function results = doIntensity(image,invariant,imgSegX, imgSegY,overlap)
	if invariant==1
		image = image - mean(mean(image));
	end
	%do per image segment and store in vector
	results = [];
	count=1;

	yStepSize = imgSegY;
	xStepSize = imgSegX;
	if (overlap)
		yStepSize = floor(imgSegY/2);
		xStepSize = floor(imgSegX/2);
	end
	
	for y=1:yStepSize:size(image,1)-imgSegY
		for x=1:xStepSize:size(image,2)-imgSegX
			if y+imgSegY+10>size(image,1)
				untillY = size(image,1);
			else
				untillY = y+imgSegY-1;
			end
			if x+imgSegX+10>size(image,2)
				untillX = size(image,2);
			else
				untillX = x+imgSegX-1;
			end
			results(count) = mean(mean(image(y:untillY,x:untillX)));
			count = count+1;
		end
	end
end
