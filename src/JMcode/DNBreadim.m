function im=DNBreadim(str)

im = im2double(imread(str));
%% reshape into long vector
im = reshape(im,1,prod(size(im)));
