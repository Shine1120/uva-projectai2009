function [ allResults ] = CEgetDataSet2( do, path,cannyThresh,...
	useFront, useRear)

	numImages=1;
	allResults=[0,0];

	if strcmp(path(length(path)-5:length(path)-1),'unfit')
		dataset = 'unfit';
	else
		dataset = 'fit';
	end

	fprintf('\tconstructing the %s data set for %s\n',dataset, do)
	maxImage=250;
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

		  %get the data for classification
		  if strcmp(do,'edge')
			if (useFront)
			  frontImageCount = doEdge(nextImageFront,cannyThresh);
			end
			if (useRear)
			  rearImageCount  = doEdge(nextImageRear,cannyThresh);
			end
		  end
		  if strcmp(do,'Intensity')
			if (useFront)
			  frontImageCount = doIntensity(nextImageFront);
			end
			if (useRear)
			  rearImageCount  = doIntensity(nextImageRear);
			end
		  end
		  if strcmp(do,'IntensityOfEdge')
			if (useFront)
			  frontImageCount = doIntensityOfEdge(nextImageFront,cannyThresh);
			end
			if (useRear)
			  rearImageCount  = doIntensityOfEdge(nextImageRear,cannyThresh);
			end
		  end
		  if strcmp(do,'edge and Intensity')
			if (useFront)
			  frontImageCount = doEdgeIntensity(nextImageFront,cannyThresh);
			end
			if (useRear)
			  rearImageCount  = doEdgeIntensity(nextImageRear,cannyThresh);
			end
		  end

		  %add count of front and rear image to results
		  allResults(1,numImages)=0;
		  if (useFront)
			allResults(1,numImages)=allResults(1,numImages)+frontImageCount;
		  end
		  if (useRear)
			allResults(1,numImages)=allResults(1,numImages)+rearImageCount;
		  end
		  
		  %raise image count
		  numImages=numImages+1;
		end %if fileExists
	end %for imgaes
end

function edgeCount = doEdge(image,cannyThresh)
  edgeImage = edge(image,'canny',cannyThresh);
  edgeCount=sum(sum(edgeImage));
end

function edgeCount = doIntensityOfEdge(image,cannyThresh)
  edgeImage = edge(image,'canny',cannyThresh);
  mask = edgeImage==1;
  edgeImageIntensity = image(mask);
  edgeCount=sum(sum(edgeImageIntensity));
end

function avgIntensity = doIntensity(image)
	avgIntensity=mean(mean(image));
% 	bDist=15;
% 	bb = mean(mean(image(size(image,1)-bDist:size(image,1),:)));
% 	tb = mean(mean(image(1:bDist,:)));
% 	lb = mean(mean(image(:,1:bDist)));
% 	rb = mean(mean(image(:,size(image,2)-bDist:size(image,2))));
% 	avgIntensity = mean([bb tb lb rb]);
end

function count = doEdgeIntensity(image,cannyThresh)
  factor = 10;
  %average Intensity is raised by a factor to make it usefull for large count
  %of edges. This might not be the ideal way to do this.
  count = doEdge(image,cannyThresh) + (doIntensity(image)*factor);
end