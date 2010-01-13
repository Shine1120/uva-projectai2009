%PREPROCESSES IMAGES AND SPLITS THE DATA FOR CROSSVALIDATION 
%(resizes and stores them in a matrix)
%INPUT: 
%       res        -- the procent to which the images should be resized
%       train      -- 1 for train / 0 for test    
%       index      -- the index of the CROSS-VALIDATION round
%       no_rounds  -- the total number of rounds for cross-validation
%       path_fit   -- the path to the folder for the fit images
%       path_unfit -- the path to the folder for the unfit images
%OUTPUT:
%       labels     -- labels for the data set 
%       ImgSet     -- images for the data set as a matrix resized with the
%                     procent res
%       nx         -- resized dimension of images on x axis
%       ny         -- resized dimension of images on x axis
function [labels, ImgSet, nx, ny] = preprocess(res,index,train,no_rounds,path_fit,path_unfit)    
    nx         = round(120*res);
    ny         = round(85*res);

    struct_fit = dir(path_fit);
    struct_fit = struct_fit(find(cellfun(@length,{struct_fit(:).name}))>2);
    no_fit     = size(struct_fit,1);
    if(no_rounds == 1) 
        slice_fit  = round(no_fit/4);
    else    
        slice_fit  = round(no_fit/no_rounds);
    end
    
    struct_unfit = dir(path_unfit);
    struct_unfit = struct_unfit(find(cellfun(@length,{struct_unfit(:).name}))>2);
    no_unfit     = size(struct_unfit,1);
    if(no_rounds == 1)
        slice_unfit  = round(no_unfit/4);
    else 
        slice_unfit  = round(no_unfit/no_rounds);
    end
    if(~train && index==1) %for test set 
        struct_fit   = struct_fit(1:slice_fit);
        struct_unfit = struct_unfit(1:slice_unfit);
    elseif(~train)
        struct_fit   = struct_fit((index-1)*slice_fit:index*slice_fit);    
        struct_unfit = struct_unfit((index-1)*slice_unfit:index*slice_unfit);
    elseif(train && index==1) %for the training set 
        struct_fit   = struct_fit(slice_fit+1:end);
        struct_unfit = struct_unfit(slice_unfit+1:end);
    elseif(train)
        struct_fit   = [struct_fit(1:(index-1)*slice_fit-1); struct_fit(index*slice_fit+1:end)];
        struct_unfit = [struct_unfit(1:(index-1)*slice_unfit-1); struct_unfit(index*slice_unfit+1:end)];
    end
    no_fit   = size(struct_fit,1); %update the number of total fit images
    no_unfit = size(struct_unfit,1); %update the number of total unfit images

%   ImgSet = zeros(round(85*res),round(120*res),(no_unfit+no_fit));
    for i=1:no_fit
        Img = imread([path_fit struct_fit(i).name]);
        Img = imresize(Img, [round(85*res) round(120*res)]);
        ImgSet(:,:,i) = Img;  
    end

    for i=1:no_unfit
        Img = imread([path_unfit struct_unfit(i).name]);
        Img = imresize(Img, [round(85*res) round(120*res)]);
        ImgSet(:,:,i+no_fit) = Img;  
	end

	labels = [ones(1,no_fit) -1*ones(1,no_unfit)];
end