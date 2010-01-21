function [ allResults ] = IEgetDataSet( do, path,cannyThresh,...
	useFront, useRear, invariant,xSegms, ySegms)

	imgNr=1;
	allResults=[0,0];
	
	if strcmp(path(length(path)-5:length(path)-1),'unfit')
		dataset = 'unfit';
	else
		dataset = 'fit';
	end

	fprintf('\tconstructing the %s data set for %s\n',dataset, do)
	maxImage=300;
	for i = 1:maxImage
		%for all images: extract the data

		%construct front and rear image name
		nextImageNameFront = [path 'f' num2str(i,'%01d') '.bmp'];
		nextImageNameRear  = [path 'r' num2str(i,'%01d') '.bmp'];
		%check if both exist in the dataset
		if exist(nextImageNameFront,'file') &&...
			exist(nextImageNameRear,'file')

		  %load images as required in the initialization at the top
			if (useFront)
				nextImageFront = imread(nextImageNameFront);
			end
			if (useRear)
				nextImageRear  = imread(nextImageNameRear);
			end
			imgSegFX = floor((size(nextImageFront,2)-1)/xSegms);
			imgSegFY = floor((size(nextImageFront,1)-1)/ySegms);
			imgSegRX = floor((size(nextImageRear,2)-1)/xSegms);
			imgSegRY = floor((size(nextImageRear,1)-1)/ySegms);


		  %get the data for classification
		  if strcmp(do,'edge')
			if (useFront)
			  frontImageResults = doEdge(nextImageFront,cannyThresh,...
				  invariant,imgSegFX,imgSegFY);
			end
			if (useRear)
			  rearImageResults  = doEdge(nextImageRear,cannyThresh,...
				  invariant,imgSegRX,imgSegRY);
			end
		  end
		  if strcmp(do,'Intensity')
			if (useFront)
			  frontImageResults = doIntensity(nextImageFront,...
				  invariant,imgSegFX,imgSegFY);
			end
			if (useRear)
			  rearImageResults  = doIntensity(nextImageRear,...
				  invariant,imgSegRX,imgSegRY);
			end
		  end
		  if strcmp(do,'IntensityOfEdge')
			if (useFront)
			  frontImageResults = doIntensityOfEdge(nextImageFront,...
				  cannyThresh,invariant,imgSegFX,imgSegFY);
			end
			if (useRear)
			  rearImageResults  = doIntensityOfEdge(nextImageRear,...
				  cannyThresh,invariant,imgSegRX,imgSegRY);
			end
		  end
		  if strcmp(do,'edge and Intensity')
			if (useFront)
			  frontImageResults = doEdgeIntensity(nextImageFront,...
				  cannyThresh,invariant,imgSegFX,imgSegFY);
			end
			if (useRear)
			  rearImageResults  = doEdgeIntensity(nextImageRear,...
				  cannyThresh,invariant,imgSegRX,imgSegRY);
			end
		  end

% 		  sizeFrontImageCount = size(frontImageResults)
% 		  frontImageResults
% 		  sizeRearImageCount = size(rearImageResults)
% 		  rearImageResults
		  %add count of front and rear image to results
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

function results = doEdge(image,cannyThresh,invariant,imgSegX, imgSegY)
	if invariant==1
		image = image - mean(mean(image));
	end
	edgeImage = edge(image,'canny',cannyThresh);
	
% 	edgeImage         = conv2(im2double(image), double([-1 1;-1 1]));
% 	threshold = mean(mean(edgeImage));
% 	filter            = (edgeImage<threshold);
% 	edgeImage(filter) = 0;

	%do per image segment and store in vector
	results = [];
	count=1;
	for y=1:imgSegY:size(image,1)-imgSegY
		for x=1:imgSegX:size(image,2)-imgSegX
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
	
%	edgeCount = sum(results);
% 	results
% 	resultsCheck = sum(sum(edgeImage))
end

function results = doIntensityOfEdge(image,cannyThresh,invariant,imgSegX, imgSegY)
	if invariant==1
		image = image - mean(mean(image));
	end
	edgeImage = edge(image,'canny',cannyThresh);
	mask = edgeImage==1;
	edgeImageIntensity = image(mask);
	%do per image segment and store in vector
	results = [];
	count=1;
	for y=1:imgSegY:size(image,1)-imgSegY
		for x=1:imgSegX:size(image,2)-imgSegX
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
			results(count) = sum(sum(edgeImageIntensity(y:untillY,x:untillX)));
			count = count+1;
		end
	end
	
%	edgeCount = sum(results);
%	results
%	resultsCheck = sum(sum(edgeImageIntensity));
end

function results = doIntensity(image,invariant,imgSegX, imgSegY)
	if invariant==1
		image = image - mean(mean(image));
	end
	%do per image segment and store in vector
	results = [];
	count=1;
	for y=1:imgSegY:size(image,1)-imgSegY
		for x=1:imgSegX:size(image,2)-imgSegX
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
	
%	avgIntensity = mean(results);
% 	results
% 	resultsCheck = mean(mean(image))
end

function count = doEdgeIntensity(image,cannyThresh,invariant,imgSegX, imgSegY)
	if invariant==1
		image = image - mean(mean(image));
	end
	factor = 10;
	%average Intensity is raised by a factor to make it usefull for large count
	%of edges. This might not be the ideal way to do this.
	count = doEdge(image,cannyThresh) + (doIntensity(image)*factor);
end