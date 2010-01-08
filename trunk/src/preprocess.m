%INPUT 
%       res -- the procent to which the images should be resized
%OUTPUT
%       labels -- labels for the data set 
%       ImgSet -- images for the data set as a matrix resized with the
%                 procent res
%       train -- 1 for train / 0 for test    
function [labels ImgSet] = preprocess(res, train)    
    %preprocessing images
    path_fit   = 'fit/';
    struct_fit = dir(path_fit);
    if(train)
        struct_fit = struct_fit(4:26);
    else
        struct_fit = struct_fit(27:end);
    end
    no_fit     = size(struct_fit,1);

    path_unfit   = 'unfit/';
    struct_unfit = dir(path_unfit);
    if(train)
        struct_unfit = struct_unfit(4:26);
    else
        struct_unfit = struct_unfit(27:end);
    end
    no_unfit     = size(struct_unfit,1);

%   ImgSet       = zeros(round(85*res),round(120*res),(no_unfit+no_fit));
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