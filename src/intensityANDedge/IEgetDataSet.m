function [ allResults ] = IEgetDataSet( do, path,cannyThresh,...
	useFront, useRear, invariant,xSegms, ySegms,overlap)

	imgNr=1;
	allResults=[0,0];
	
	%extract what detazet to get from given path
	if strcmp(path(length(path)-5:length(path)-1),'unfit')
		dataset = 'unfit';
	else
		dataset = 'fit';
	end

	fprintf('\tconstructing the %s data set for %s\n',dataset, do)
	%define maximum image number
	% this is a little bit naive to get all the images, but works as long
	% as maxImages is higher or equal to last image
	maxImage=300;
	for i = 1:maxImage
		%for all images: extract the data

		%construct front and rear image path
		nextImageNameFront = [path 'f' num2str(i,'%01d') '.bmp'];
		nextImageNameRear  = [path 'r' num2str(i,'%01d') '.bmp'];
		%check if both exist in the dataset
		if exist(nextImageNameFront,'file') &&...
			exist(nextImageNameRear,'file')

		  %load images as required in the initialization at the top
			if (useFront)
				nextImageFront = im2double(imread(nextImageNameFront));
			end
			if (useRear)
				nextImageRear  = im2double(imread(nextImageNameRear));
			end
			%get the segment sizes for front and rear (front and rear can 
			% differ)
			imgSegFX = floor((size(nextImageFront,2)-1)/xSegms);
			imgSegFY = floor((size(nextImageFront,1)-1)/ySegms);
			imgSegRX = floor((size(nextImageRear,2)-1)/xSegms);
			imgSegRY = floor((size(nextImageRear,1)-1)/ySegms);


		  %get the data per method for front and rear
		  if strcmp(do,'edge')
			if (useFront)
			  frontImageResults = doEdge(nextImageFront,cannyThresh,...
				  invariant,imgSegFX,imgSegFY,overlap);
			end
			if (useRear)
			  rearImageResults  = doEdge(nextImageRear,cannyThresh,...
				  invariant,imgSegRX,imgSegRY,overlap);
			end
		  end
		  if strcmp(do,'Intensity')
			if (useFront)
			  frontImageResults = doIntensity(nextImageFront,...
				  invariant,imgSegFX,imgSegFY,overlap);
			end
			if (useRear)
			  rearImageResults  = doIntensity(nextImageRear,...
				  invariant,imgSegRX,imgSegRY,overlap);
			end
		  end

		  %add counts of front and rear image to one matrix
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
		end %if fileExists
	end %for imgaes
end

function results = doEdge(image,cannyThresh,invariant,imgSegX, imgSegY,overlap)
	if invariant==1
		image = image - mean(mean(image));
	end
	%get edges of image
	edgeImage = edge(image,'canny',cannyThresh);
	
	results = [];
	count=1;
	
	yStepSize = imgSegY;
	xStepSize = imgSegX;
	if (overlap)
		yStepSize = floor(imgSegY/2);
		xStepSize = floor(imgSegX/2);
	end
	%per image segment cut corresponding part out of the edge image
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
			%final value for edge of a segment if the sum of all edge
			%points in the segment
			results(count) = sum(sum(edgeImage(y:untillY,x:untillX)));
			count = count+1;
		end
	end
end

function results = doIntensity(image,invariant,imgSegX, imgSegY,overlap)
	if invariant==1
		image = image - mean(mean(image));
	end
	
	results = [];
	count=1;
	
	yStepSize = imgSegY;
	xStepSize = imgSegX;
	if (overlap)
		yStepSize = floor(imgSegY/2);
		xStepSize = floor(imgSegX/2);
	end
	
	%per image segment cut corresponding part out of the image
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
			%final value for intensity of a segment if the mean intensity
			%in that segment
			results(count) = mean(mean(image(y:untillY,x:untillX)));
			count = count+1;
		end
	end
end