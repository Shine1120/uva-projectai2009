function im=DNBreadim(str)

im = imresize_old(im2double(imread(str)),[350 190]);


% gives similar results:
% im = imresize(im, 0.75);



%% reshape into long vector
%im = reshape(im,1,prod(size(im)));


%% TODO:
% - for each bill, subtract the mean of that bill (to get intensity
% invariance) (results should go down)
% - for both training and test-set subtract subtract the emperical mean of
% the training-set before projecting (results should go up)