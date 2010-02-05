%INPUT:
%		Xsegs      -- number of regions for X
%		Ysegs      -- number of regions for Y 
%		bestModels -- indexes of the best best models
%		side       -- front/rear
%__________________________________________________________________________
function plot_regions(Ysegs,Xsegs,bestModels,side,path)
	segsPerSide   = ((2 * Xsegs)-1) * ((2 *Ysegs)-1);
	if (strcmp(side,'rear')==1)
		imageName = [path 'r2.bmp'];
	else
		imageName = [path 'f2.bmp'];
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
	segText = cell(segsPerSide);
	for i=1:length(frontOrRear)
		segment = frontOrRear(i);
		column  = mod(segment,((2*Xsegs)-1));
		row     = (segment-column)/((2*Xsegs)-1)+1;
		if column==0
			column = (2 * Xsegs) -1;
			row    = row-1;
		end
		x = round(((column-1)/2)*segWidth)+1;
		y = round(((row-1)/2)*segHeight)+1;
		rectangle('Position',[x,y,segWidth,segHeight],'EdgeColor','r')		
		p = patch([x,x+segWidth,x+segWidth,x],[y,y,y+segHeight,y+segHeight],'r');
		alpha(p,0.3);
		
		[ignore memLoc] = ismember(bestModels, frontOrRear(i)+((methodIdx(i)-1)*segsPerSide));
		[ignore index]  = sort(memLoc,'descend');

		segText{segment} = [segText{segment} ' ' num2str(index(1))];
	end
	
	for i=1:length(frontOrRear)
		segment = frontOrRear(i);
		column  = mod(segment,((2*Xsegs)-1));
		row     = (segment-column)/((2*Xsegs)-1)+1;
		if column==0
			column = (2 * Xsegs)-1;
			row    = row - 1;
		end
		x = round(((column-1)/2)*segWidth)+1;
		y = round(((row-1)/2)*segHeight)+1;
		text(x+4,y+round(segHeight/2),segText(segment));		
	end
	hold off
end

