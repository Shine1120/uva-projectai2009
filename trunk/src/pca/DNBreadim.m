function im=DNBreadim(str)

im = im2double(imread(str));

% gives similar results:
% im = imresize(im, 0.75);



%% reshape into long vector
im = reshape(im,1,prod(size(im)));
