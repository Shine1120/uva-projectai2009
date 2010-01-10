function [histogram,binSize,mini] = constrHistogram(list,bins)
  mini = min(list);
  maxi = max(list);
  diff = maxi-mini;
  binSize = diff/bins;

  resultBinned = zeros(size(list));
  histogram = zeros(bins,1);
  for i=1:bins
    %get all items in list that have values that correspond to bin i
    mask = list>=((binSize*(i-1))+mini) & list<=((binSize*(i))+mini);
    resultBinned(mask) = i;
  end
  for t=1:size(list,2)
     %add occurences to bar 
     histogram(resultBinned(t)) = histogram(resultBinned(t)) + 1;
  end
end
