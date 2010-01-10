%COMPUTES THE HAAR FEATURES FOR THE TRAINING SET AND RETURNS A STRUCTURE
%CONTAINING ALL WEAK CLASSIFIERS CORRESPONDING TO THE TOP "T" BEST FEATURES
%INPUT:
%       T      -- number of features to be used (not too large :P)
%       labels -- array of labels for the images
%       ImgSet -- the images of the training set saved as a matrix   
%OUTPUT:
%       model      -- the structure containing the weak classifiers corresponding 
%                     to the best features chosen in the AdaBoost algorithm
%       rect_param -- the variable containing the parameters corresponding
%                     to the pattern used
%       F          -- the haar features  
function [model, rect_param, F] = train_haar(T, labels, ImgSet)
    load haar_dico_5  %Dictionnary with 5 types of patterns
    target        = int8(labels); %targets or labels
    II            = image_integral_standard(ImgSet); %Integral Image 
    [Ny , Nx , P] = size(II); %P number of images
    F             = haar_featlist(Ny , Nx , rect_param); %haar features
    index         = randperm(length(target));
    tic,model     = haar_adaboost_binary_model_cascade(II(: , : , index) , target(index) , rect_param , F , T);,toc  %a bit long ....%

%    G          = Haar_matG(Ny , Nx , rect_param);
%    tic,model = fast_haar_adaboost_binary_model_cascade(II(: , : ,index) , target(index) , G , T);,toc

    %plot the best features on a random image
%{
    Nimage   = randperm(P); %Random image index for printing the result over it
    rand_Img = ImgSet(: , : , Nimage); %random image for ploting the features
    figure;imagesc(rand_Img);hold on;
    best_feats = (F(: , model(1 , 1:T)));
    x          = double(best_feats(2 , :)) + 0.5 ;
    y          = double(best_feats(3 , :)) + 0.5;
    w          = best_feats(4 , :);
    h          = best_feats(5 , :);
    indR       = fix(best_feats(6 , :) + 1)/10 + 1;
    R          = rect_param(4, indR);
    for f = 1 : T
        for r = 0:R(f)-1
            coeffw = w(f)/rect_param(2 , indR(f) + r);
            coeffh = h(f)/rect_param(3 , indR(f) + r);
            xr     = (x(f) + double(coeffw*rect_param(6 , indR(f) + r)));
            yr     = (y(f) + double(coeffh*rect_param(7 , indR(f) + r))) ;
            wr     = double(coeffw*(rect_param(8 , indR(f) + r)  - 0));
            hr     = double(coeffh*(rect_param(9 , indR(f) + r) - 0));
            s      = rect_param(10 , indR(f) + r);
            if (s == 1)
                color = [0.9 0.9 0.9];
            else
                color = [0.1 0.1 0.1];
            end
            hh      = rectangle('Position', [xr,  yr ,  wr ,  hr] );
            p       = patch([xr , xr+wr , xr + wr , xr] , [yr , yr , yr + hr , yr + hr] , color);
            alpha(p , 0.8);
            set(hh , 'linewidth' , 2 , 'EdgeColor' , [1 0 0])
        end
    end
    hold off
    title(sprintf('Best %d Haar features with Adaboost' , T) , 'fontsize' , 13)
    colormap(gray)
%}
end
