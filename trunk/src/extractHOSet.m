function [ output_args ] = extractHOSet( input_args )

	maxImage=300;

	
	pathFitWPB = 'moneyDivide/wholeplusborder/neur05/fit/';
	pathFitW   = 'moneyDivide/whole/neur05/fit/';
	pathFitWP  = 'moneyDivide/whitepatch/neur05/fit/';
	imgIdxListFit = [];
	for i = 1:maxImage
		%for all images: extract the data

		%construct front and rear image name
		nextImageNameFront = [pathFitWPB 'f' num2str(i,'%01d') '.bmp'];
		nextImageNameRear  = [pathFitWPB 'r' num2str(i,'%01d') '.bmp'];
		%check if both exist in the dataset
		if exist(nextImageNameFront,'file') &&...
			exist(nextImageNameRear,'file')
			imgIdxListFit = [imgIdxListFit i];
		end
	end
	
	pathUnfitWPB = 'moneyDivide/wholeplusborder/neur05/unfit/';
	pathUnfitW   = 'moneyDivide/whole/neur05/unfit/';
	pathUnfitWP  = 'moneyDivide/whitepatch/neur05/unfit/';
	imgIdxListUnfit = [];
	
	for i = 1:maxImage
		%for all images: extract the data

		%construct front and rear image name
		nextImageNameFront = [pathUnfitWPB 'f' num2str(i,'%01d') '.bmp'];
		nextImageNameRear  = [pathUnfitWPB 'r' num2str(i,'%01d') '.bmp'];
		%check if both exist in the dataset
		if exist(nextImageNameFront,'file') &&...
			exist(nextImageNameRear,'file')
			imgIdxListUnfit = [imgIdxListUnfit i];
		end
	end
	
	randomIdxsFit   = randperm(size(imgIdxListFit,2));
	hoSetIdxsFit    = imgIdxListFit(randomIdxsFit(1:60));
	randomIdxsUnfit = randperm(size(imgIdxListUnfit,2));
	hoSetIdxsUnfit  = imgIdxListUnfit(randomIdxsUnfit(1:40));
	
	for j=1:size(hoSetIdxsFit,2)
		fromFrontWPB = [pathFitWPB 'f' num2str(hoSetIdxsFit(j),'%01d') '.bmp'];
		fromRearWPB  = [pathFitWPB 'r' num2str(hoSetIdxsFit(j),'%01d') '.bmp'];
		fromFrontW   = [pathFitW 'f' num2str(hoSetIdxsFit(j),'%01d') '.bmp'];
		fromRearW    = [pathFitW 'r' num2str(hoSetIdxsFit(j),'%01d') '.bmp'];
		fromFrontWP  = [pathFitWP 'f' num2str(hoSetIdxsFit(j),'%01d') '.bmp'];
		fromRearWP   = [pathFitWP 'r' num2str(hoSetIdxsFit(j),'%01d') '.bmp'];
		toPathWPB = 'moneyDivide/wholeplusborderHO/neur05/fit';
		toPathW   = 'moneyDivide/wholeHO/neur05/fit';
		toPathWP  = 'moneyDivide/whitepatchHO/neur05/fit';
		movefile(fromFrontWPB, toPathWPB)
		movefile(fromRearWPB, toPathWPB)
		movefile(fromFrontW, toPathW)
		movefile(fromRearW, toPathW)
		movefile(fromFrontWP, toPathWP)
		movefile(fromRearWP, toPathWP)
	end
	for k=1:size(hoSetIdxsUnfit,2)
		fromFrontWPB = [pathUnfitWPB 'f' num2str(hoSetIdxsUnfit(k),'%01d') '.bmp'];
		fromRearWPB  = [pathUnfitWPB 'r' num2str(hoSetIdxsUnfit(k),'%01d') '.bmp'];
		fromFrontW   = [pathUnfitW 'f' num2str(hoSetIdxsUnfit(k),'%01d') '.bmp'];
		fromRearW    = [pathUnfitW 'r' num2str(hoSetIdxsUnfit(k),'%01d') '.bmp'];
		fromFrontWP  = [pathUnfitWP 'f' num2str(hoSetIdxsUnfit(k),'%01d') '.bmp'];
		fromRearWP   = [pathUnfitWP 'r' num2str(hoSetIdxsUnfit(k),'%01d') '.bmp'];
		toPathWPB = 'moneyDivide/wholeplusborderHO/neur05/unfit';
		toPathW   = 'moneyDivide/wholeHO/neur05/unfit';
		toPathWP  = 'moneyDivide/whitepatchHO/neur05/unfit';
		movefile(fromFrontWPB, toPathWPB)
		movefile(fromRearWPB, toPathWPB)
		movefile(fromFrontW, toPathW)
		movefile(fromRearW, toPathW)
		movefile(fromFrontWP, toPathWP)
		movefile(fromRearWP, toPathWP)
	end
end

function p = randperm(n)
    [ignore,p] = sort(rand(1,n));
end