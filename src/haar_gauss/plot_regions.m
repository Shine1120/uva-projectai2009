%INPUT:
%		Xsegs      -- number of regions for X
%		Ysegs      -- number of regions for Y 
%		bestModels -- indexes of the best best models
%		side       -- front/rear
%__________________________________________________________________________
function plot_regions(Ysegs,Xsegs,bestModels,side)
	segsPerSide   = Xsegs * Ysegs;
	if (strcmp(side,'rear')==1)
		imageName = 'moneyDivided/wholeplusborder/neur10/fit/f2.bmp';
	else
		imageName = 'moneyDivided/wholeplusborder/neur10/fit/r2.bmp';
	end
	image         = imread(imageName);
	[sizeY sizeX] = size(image);
	segWidth      = round(sizeX/Xsegs);
	segHeight     = round(sizeY/Ysegs);
	
	methodIdx   = ceil((bestModels./segsPerSide));
	frontOrRear = bestModels-((methodIdx-1)*segsPerSide);
	figure;imshow(image)
	title(sprintf('Regions for %s',side))
	hold on
	for i=1:length(frontOrRear)
		segment = frontOrRear(i);
		m       = mod(segment,Xsegs);
		n       = ((segment-m)/Xsegs)+1;
		if m==0
			m=Xsegs;n=n-1;
		end
		x = ((m-1)*segWidth)+1;
		y = ((n-1)*segHeight)+1;
		rectangle('Position',[x,y,segWidth,segHeight],'EdgeColor','r')		
		p = patch([x,x+segWidth,x+segWidth,x],[y,y,y+segHeight,y+segHeight],'r');
		alpha(p,0.3);
	end
	hold off
end

