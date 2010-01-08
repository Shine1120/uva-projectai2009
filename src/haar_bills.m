res = 0.75

%preprocessing images
path_fit = 'fit/';
struct_fit = dir(path_fit);
struct_fit = struct_fit(4:end);
no_fit     = size(struct_fit,1);

path_unfit   = 'unfit/';
struct_unfit = dir(path_unfit);
struct_unfit = struct_unfit(4:end);
no_unfit     = size(struct_unfit,1);

ImgSet       = zeros(round(85*res),round(120*res),(no_unfit+no_fit));
size(ImgSet)
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
load haar_dico_5    %Dictionnary with 2 types of pattern

y                  = int8(labels);

II                 = image_integral_standard(ImgSet);
[Ny , Nx , P]      = size(II);
Nimage             = 10%110;
nb_feats           = 100;
T                  = nb_feats;

F                  = haar_featlist(Ny , Nx , rect_param);
I                  = ImgSet(: , : , Nimage);


index              = randperm(length(y));

tic,model0         = haar_adaboost_binary_model_cascade(II(: , : , index) , y(index) , rect_param , F , T);,toc  %a bit long ....%

% G                  = Haar_matG(Ny , Nx , rect_param);
%tic,model1         = fast_haar_adaboost_binary_model_cascade(II(: , : , index) , y(index) , G , T);,toc



figure
imagesc(I)
hold on

best_feats          = (F(: , model0(1 , 1:nb_feats)));
x                   = double(best_feats(2 , :)) + 0.5 ;
y                   = double(best_feats(3 , :)) + 0.5;
w                   = best_feats(4 , :);
h                   = best_feats(5 , :);
indR                = fix(best_feats(6 , :) + 1)/10 + 1;
R                   = rect_param(4 , indR);

for f = 1 : nb_feats
    for r = 0:R(f)-1
        
        coeffw  = w(f)/rect_param(2 , indR(f) + r);
        coeffh  = h(f)/rect_param(3 , indR(f) + r);
        xr      = (x(f) + double(coeffw*rect_param(6 , indR(f) + r)));
        yr      = (y(f) + double(coeffh*rect_param(7 , indR(f) + r))) ;
        wr      = double(coeffw*(rect_param(8 , indR(f) + r)  - 0));
        hr      = double(coeffh*(rect_param(9 , indR(f) + r) - 0));
        s       = rect_param(10 , indR(f) + r);
        if (s == 1)
            
            color   = [0.9 0.9 0.9];
            
        else
            
            color   = [0.1 0.1 0.1];
            
        end
        hh      = rectangle('Position', [xr,  yr ,  wr ,  hr] );
        p       = patch([xr , xr+wr , xr + wr , xr] , [yr , yr , yr + hr , yr + hr] , color);
        alpha(p , 0.8);
        set(hh , 'linewidth' , 2 , 'EdgeColor' , [1 0 0])
        
    end
end
hold off
title(sprintf('Best %d Haar features with Adaboost' , nb_feats) , 'fontsize' , 13)
colormap(gray)
