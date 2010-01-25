function preprocessnew(value)
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

all_labels = [];

all_money_front = zeros(350, 190, length(fitset_front)+length(unfitset_front));
all_money_rear = zeros(350, 190, length(fitset_front)+length(unfitset_front));

for i = 1:length(fitset_front)
    banknote = DNBreadim([fitdir fitset_front(i).name]);
    all_money_front(:,:,i) = banknote;
    all_labels = [all_labels; 0];
end;
for i = 1:length(unfitset_front)
    banknote = DNBreadim([unfitdir unfitset_front(i).name]);
    all_money_front(:,:,i+length(fitset_front)) = banknote;
    all_labels = [all_labels; 1];
end;

save all_money_front.mat all_money_front
clear all_money_front

for i = 1:length(fitset_rear)
    banknote = DNBreadim([fitdir fitset_rear(i).name]);
    all_money_rear(:,:,i) = banknote;
end;
for i = 1:length(unfitset_rear)
    banknote = DNBreadim([unfitdir unfitset_rear(i).name]);
    all_money_rear(:,:,i+length(fitset_rear)) = banknote;
end;

save all_money_rear.mat all_money_rear
clear all_money_rear

save all_labels.mat all_labels
clear all_labels

