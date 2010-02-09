function im=DNBreadim(str)

im = im2double(imread(str));

% gives similar results:
% im = imresize(im, 0.75);



%% reshape into long vector
im = reshape(im,1,prod(size(im)));


%% TODO:
% [DONE] for each bill, subtract the mean of that bill (to get intensity
% invariance) (results get terrible)
%
% [TODO] for both training and test-set subtract subtract the emperical mean of
% the training-set before projecting (results should go up)