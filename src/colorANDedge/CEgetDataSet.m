function [ allResults ] = CEgetDataSet( do, path,cannyThresh,...
  maxNrImg, useFront, useRear )

  numImages=1;
  allResults=[0,0];

  fprintf('\tconstructing the data set for %s\n',do)
  for i = 1:maxNrImg
    %for all images: extract the data

    %construct front and rear image name
    nextImageNameFront = [path 'f' num2str(i,'%01d') '.bmp'];
    nextImageNameRear = [path 'r' num2str(i,'%01d') '.bmp'];
    %check if both exist in the dataset
    if exist(nextImageNameFront,'file') &&...
        exist(nextImageNameRear,'file')

      %load images as required in the initialization at the top
      if (useFront)
        nextImageFront = imread(nextImageNameFront);
      end
      if (useRear)
        nextImageRear = imread(nextImageNameRear);
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
      if strcmp(do,'color')
        if (useFront)
          frontImageCount = doColor(nextImageFront);
        end
        if (useRear)
          rearImageCount  = doColor(nextImageRear);
        end
      end
      if strcmp(do,'colorOfEdge')
        if (useFront)
          frontImageCount = doColorOfEdge(nextImageFront,cannyThresh);
        end
        if (useRear)
          rearImageCount  = doColorOfEdge(nextImageRear,cannyThresh);
        end
      end
      if strcmp(do,'edge and color')
        if (useFront)
          frontImageCount = doEdgeColor(nextImageFront,cannyThresh);
        end
        if (useRear)
          rearImageCount = doEdgeColor(nextImageRear,cannyThresh);
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
      %store image id
      allResults(2,numImages)=i;

      %raise image count
      numImages=numImages+1;
    end %if fileExists
  end %for imgaes
end

function edgeCount = doEdge(image,cannyThresh)
  edgeImage = edge(image,'canny',cannyThresh);
  edgeCount=sum(sum(edgeImage));
end

function edgeCount = doColorOfEdge(image,cannyThresh)
  edgeImage = edge(image,'canny',cannyThresh);
  mask = edgeImage==1;
  edgeImageColor = image(mask);
  edgeCount=sum(sum(edgeImageColor));
end

function avgColor = doColor(image)
	avgColor=mean(mean(image));
end

function count = doEdgeColor(image,cannyThresh)
  factor = 10;
  %average color is raised by a factor to make it usefull for large count
  %of edges. This might not be the ideal way to do this.
  count = doEdge(image,cannyThresh) + (doColor(image)*factor);
end