%INPUTE
%       model -- model structure of the features computed in the
%                train_haar.m
function eval_bills(model)
    [labels ImgSet] = preprocess(0.75,0); %the parameter indicates the size for the resizing
    %load model_detector_haar_24x24.mat
    load model_struct.mat
    y    = int8(labels);
    indp = find(y == 1);
    indn = find(y ==-1);
    T    = size(model.param , 2);

    fx_full                         = eval_haar(ImgSet , model);
    [tpp_full , fpp_full , th_full] = basicroc(y , fx_full);

    Error_full                 = (1-tpp_full(2:end-1)) + fpp_full(2:end-1);
    [mini_full , index_full]   = min(Error_full);
    th_full_opt                = th_full(index_full);
    yest_full                  = sign(fx_full - th_full_opt);
    tp_full                    = sum(yest_full(indp) == y(indp))/length(indp)
    fp_full                    = 1 - sum(yest_full(indn) == y(indn))/length(indn)
    Perf_full                  = sum(yest_full == y)/length(y)

    figure
    plot(1:length(y) , fx_full , 'r')
    title(sprintf('Output of the strong classifier for test data with T = %d, n_{exit} = %d' , T ))
    legend('Full' , 'Location' , 'NorthEast');

    figure
    plot(fpp_full , tpp_full ,'r' , 'linewidth' , 2)
    axis([-0.02 , 1.02 , -0.02 , 1.02])
    title(sprintf('ROC for Conventional Cascade with T = %d, n_{stages} = %d' , T))
    legend('Full' , 'Location' , 'SouthEast');

    figure
    plot(th_full , Error_full , th_full_opt , mini_full , 'k+' , 'linewidth' , 2)

    xlabel('\lambda')
    ylabel('Error')
end