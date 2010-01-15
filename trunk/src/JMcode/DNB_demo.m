
doread = 1;
dotrain = 1;

moneydir = 'whole/neur10';
leave_n_out = 50;  % experiment for DNB newdata
hold_n_out = 100;  % experiment for DNB newdata
trials = 20; % 20 for DNB newdata
repetitions = 20; % 20 for DNB newdata
unfitaccept = 0.04; % ensures better than 5% error on unfit class

% how many eigenvectors to use 
NumberOfEigenVectors = 30;
% how many images to construct eigenmoney
EigenConstructFrom = 50;
%EigenConstructFrom = 35; % doesn't change the results much...

if (doread)
    all_money_front = []; all_money_rear = []; all_labels = [];
end

hcorrect_front = [0 0];
hcorrect_rear = [0 0];
hcorrect_both = [0 0];
hcorrectbayes = [0 0];
%hcorrectall = [0 0];
hn = [0 0];


%% ------------- READ TRAINING DATA -------------------

if (doread)
    fprintf('reading training data...\n');
    [all_money_front all_money_rear all_labels] = preprocessnew(moneydir);
end

for q=1:repetitions

    fprintf('Run %d of %d\n', q, repetitions);

    if (dotrain)
        money_front = []; money_rear = []; eigen_front = []; eigen_rear = [];
        trainProjection_front = []; trainProjection_rear = [];
    end

    allidx = randperm(length(all_labels));
    holdoutset = allidx(1:hold_n_out);
    allidx = allidx(hold_n_out+1:end);

    %% ------------- TRAINING PART -------------------

    fprintf('training models...\n');

    % leave-one-out...
    correct_front = [0 0];
    correct_rear = [0 0];
    correct_both = [0 0];
    correctbayes = [0 0];
%    correctall = [0 0];
    correctbest = [1 1];
    n = [0 0];

    for i=1:trials
        thisbayes = [0 0];
        thisn = [0 0];
        if (trials == length(allidx) && leave_n_out == 1)
            % do all (leave-one-out method)
            testset = allidx(i);
            trainset = allidx;
            trainset(i) = [];
        else
            % cross-val on random subset
            idx = randperm(length(allidx));
            testset = allidx(idx(1:leave_n_out));
            trainset = allidx(idx(leave_n_out+1:end));
        end;

        money_front = all_money_front(trainset,:);
        money_rear = all_money_rear(trainset,:);
        labels = all_labels(trainset);

        % determine EigenMoney - from the fit class or from all data?
        %l = find(labels==1, EigenConstructFrom);
        l = 1:EigenConstructFrom;
        eigen_front = genEigenFaces(money_front(l,:));
        eigen_rear = genEigenFaces(money_rear(l,:));

        %% Take vectors with n largest eigenvalues
        eigen_front = eigen_front(:, 1:NumberOfEigenVectors);
        eigen_rear = eigen_rear(:, 1:NumberOfEigenVectors);

        %% project training data on eigenvectors
        trainProjection_front = money_front*eigen_front;
        trainProjection_rear = money_rear*eigen_rear;
        money_front = []; money_rear = [];

        %% train support vector machines
        model_front = svmtrain(labels, trainProjection_front, '-t 0 -q -b 0'); % '-t 1 -q -b 1'
        model_rear = svmtrain(labels, trainProjection_rear, '-t 0 -q -b 0');
        % model_both = svmtrain(labels, [trainProjection_front trainProjection_rear], '-t 0 -q -b 0');
        %end; %% dotrain
        trainProjection_front = []; trainProjection_rear = [];


        %% -------------- TEST PART ----------------

        %% project on training eigenvectors
        for j=testset
            testnote_front = all_money_front(j,:);
            testnote_rear = all_money_rear(j,:);
            testlabel = all_labels(j);

            testProjection_front = testnote_front*eigen_front;
            testProjection_rear = testnote_rear*eigen_rear;

            %% predict using support vector machine

            [recognized_front, accuracy, prob_est_front] = svmpredict(1,testProjection_front, model_front, '-b 0');
            [recognized_rear, accuracy, prob_est_rear] = svmpredict(1,testProjection_rear, model_rear, '-b 0');
            % [recognized_both, accuracy, prob_est_both] = svmpredict(1,[testProjection_front testProjection_rear], model_both, '-b 0');

            n(testlabel+1) = n(testlabel+1)+1;
            thisn(testlabel+1) = thisn(testlabel+1)+1;

            %fprintf('both: %d ', recognized_both);
            %prob_est_both
            %class = recognized_both;
            %correct_both(testlabel+1) = correct_both(testlabel+1) + (testlabel==class);

            %testlabel

            %fprintf('front: %d ', recognized_front);
            %prob_est_front
            class = recognized_front;
            correct_front(testlabel+1) = correct_front(testlabel+1) + (testlabel==class);

            %fprintf('rear: %d ', recognized_rear);
            %prob_est_rear
            class = recognized_rear;
            correct_rear(testlabel+1) = correct_rear(testlabel+1) + (testlabel==class);

            % naive Bayes: multiply probabilities for two-class problem
%             prob_est = prob_est_front.*prob_est_rear;
%             [mx class] = max(prob_est);
%             class = (class==2);
            % for non-probabilistic svm:
            class = 1-(1-recognized_front)*(1-recognized_rear); % if not probabilistic svm
            %fprintf('naive Bayes: %d ', class);
            %prob_est

            correctbayes(testlabel+1) = correctbayes(testlabel+1) + (testlabel==class);
            thisbayes(testlabel+1) = thisbayes(testlabel+1) + (testlabel==class);

            %class = 1-(1-recognized_front)*(1-recognized_rear)*(1-recognized_both);
            %correctall(testlabel+1) = correctall(testlabel+1) + (testlabel==class);
            %thisbayes(testlabel+1) = thisbayes(testlabel+1) + (testlabel==class);
        end; % testset

        if (thisn(1) == 0)
            thisn(1) = 1;
        end;
        if (thisn(2) == 0)
            thisn(2) = 1;
        end;
        thisbayes = 1-thisbayes./thisn;
        if (thisbayes(2) < unfitaccept)
            if (thisbayes(1)<correctbest(1) || correctbest(2)>=unfitaccept)
                correctbest = thisbayes;
                best_eigen_front = eigen_front;
                best_eigen_rear = eigen_rear;
                best_model_front = model_front;
                best_model_rear = model_rear;
            end;
        else
            if (thisbayes(2) < correctbest(2))
                correctbest = thisbayes;
                best_eigen_front = eigen_front;
                best_eigen_rear = eigen_rear;
                best_model_front = model_front;
                best_model_rear = model_rear;
            end
        end;

    end; % trials
    n
%    error_naive_Bayes_all = 1-correctall./n
    error_naive_Bayes = 1-correctbayes./n
    error_front = 1-correct_front./n
    error_rear = 1-correct_rear./n
    error_best_classifier = correctbest
%    error_both = 1-correct_both./n


    %% -------------- VALIDATION PART ----------------

    fprintf('testing model...\n');

    model_front = best_model_front;
    model_rear = best_model_rear;
    eigen_front = best_eigen_front;
    eigen_rear = best_eigen_rear;

    correct_front = [0 0];
    correct_rear = [0 0];
    %correct_both = [0 0];
    correctbayes = [0 0];
    %correctall = [0 0];
    n = [0 0];

    %% project on training eigenvectors
    for j=holdoutset
        testnote_front = all_money_front(j,:);
        testnote_rear = all_money_rear(j,:);
        testlabel = all_labels(j);

        testProjection_front = testnote_front*eigen_front;
        testProjection_rear = testnote_rear*eigen_rear;

        %% predict using support vector machine

        [recognized_front, accuracy, prob_est_front] = svmpredict(1,testProjection_front, model_front, '-b 0');
        [recognized_rear, accuracy, prob_est_rear] = svmpredict(1,testProjection_rear, model_rear, '-b 0');
        %[recognized_both, accuracy, prob_est_both] = svmpredict(1,[testProjection_front testProjection_rear], model_both, '-b 1');

        hn(testlabel+1) = hn(testlabel+1)+1;
        n(testlabel+1) = n(testlabel+1)+1;

        %fprintf('both: %d ', recognized_both);
        %prob_est_both
        %correct_both(testlabel+1) = correct_both(testlabel+1) + (testlabel==recognized_rear)*1.0;

        %testlabel

        %fprintf('front: %d ', recognized_front);
        %prob_est_front
        class = recognized_front;
        hcorrect_front(testlabel+1) = hcorrect_front(testlabel+1) + (testlabel==class);
        correct_front(testlabel+1) = correct_front(testlabel+1) + (testlabel==class);

        %fprintf('rear: %d ', recognized_rear);
        %prob_est_rear
        class = recognized_rear;
        hcorrect_rear(testlabel+1) = hcorrect_rear(testlabel+1) + (testlabel==class);
        correct_rear(testlabel+1) = correct_rear(testlabel+1) + (testlabel==class);

        % naive Bayes: multiply probabilities for two-class problem
%         prob_est = prob_est_front.*prob_est_rear;
%         [mx class] = max(prob_est);
%         class = (class==2);
        % for non-probabilistic svm:
        class = 1-(1-recognized_front)*(1-recognized_rear); % if not probabilistic svm
        %fprintf('naive Bayes: %d ', class);
        %prob_est

        hcorrectbayes(testlabel+1) = hcorrectbayes(testlabel+1) + (testlabel==class);
        correctbayes(testlabel+1) = correctbayes(testlabel+1) + (testlabel==class);

        %class = 1-(1-recognized_front)*(1-recognized_rear)*(1-recognized_both);
        %hcorrectall(testlabel+1) = hcorrectall(testlabel+1) + (testlabel==class);        
        %correctall(testlabel+1) = correctall(testlabel+1) + (testlabel==class);        
    end; % holdoutset
    n
    if (n(1) == 0)
        n(1) = 1;
    end;
    if (n(2) == 0)
        n(2) = 1;
    end;
    %error_naive_Bayes_all = 1-correctall./n
    error_naive_Bayes = 1-correctbayes./n
    error_front = 1-correct_front./n
    error_rear = 1-correct_rear./n
end; % repetitions

fprintf( 'Final:\n' );

n=hn
%error_naive_Bayes_all = 1-hcorrectall./hn
error_naive_Bayes = 1-hcorrectbayes./hn
error_front = 1-hcorrect_front./hn
error_rear = 1-hcorrect_rear./hn
%error_both = 1-correct_both./n


