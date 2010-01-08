%INPUTE
%       nb_feats -- number of features to be used (not too large :P)
function train_haar(nb_feats)
    [labels ImgSet] = preprocess(0.75,1); %the parameter indicates the size for the resizing
    load haar_dico_5  %Dictionnary with 5 types of patterns

    y                  = int8(labels);
    II                 = image_integral_standard(ImgSet);
    [Ny , Nx , P]      = size(II);
    Nimage             = 10%110;
    T                  = nb_feats;
    F                  = haar_featlist(Ny , Nx , rect_param);
    I                  = ImgSet(: , : , Nimage);

    index              = randperm(length(y));

    tic,model0         = haar_adaboost_binary_model_cascade(II(: , : , index) , y(index) , rect_param , F , T);,toc  %a bit long ....%

    % G                  = Haar_matG(Ny , Nx , rect_param);
    %tic,model1         = fast_haar_adaboost_binary_model_cascade(II(: , : ,
    %index) , y(index) , G , T);,toc

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
    
    model = struct('param',model0,'weaklearner',1,'dimsItraining',[64 90],'rect_param',rect_param,'F',F,'cascade_type',0,'postprocessing',1);
    save model_haar_small.mat model;
    eval_bills(model);
end
