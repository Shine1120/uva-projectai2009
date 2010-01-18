function [front rear labels] = preprocessnew(value)
% PREPROCESS the money files. It will return all the nodes in a 2d matrix

value
% this is hardcoded...
dataset = [value '/'];

fitdir = [value '/fit/'];
unfitdir = [value '/unfit/'];

fitset_front = dir([fitdir 'f*.bmp']);
fitset_rear = dir([fitdir 'r*.bmp']);
unfitset_front = dir([unfitdir 'f*.bmp']);
unfitset_rear = dir([unfitdir 'r*.bmp']);

front = []; rear = []; labels = [];
for i = 1:length(fitset_front)
    banknote = DNBreadim([fitdir fitset_front(i).name]);
    front(:,:,i) = banknote;
    labels = [labels; 0];
end;
for i = 1:length(unfitset_front)
    banknote = DNBreadim([unfitdir unfitset_front(i).name]);
    front(:,:,i+length(fitset_front)) = banknote;
    labels = [labels; 1];
end;
for i = 1:length(fitset_rear)
    banknote = DNBreadim([fitdir fitset_rear(i).name]);
    rear(:,:,i) = banknote;
end;
for i = 1:length(unfitset_rear)
    banknote = DNBreadim([unfitdir unfitset_rear(i).name]);
    rear(:,:,i+length(fitset_rear)) = banknote;
end;