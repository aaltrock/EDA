%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SVM - RUN TRAIN AND VALIDATION SET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SVMModel, val_metrics] = svm_main(conf, trn_x, trn_y, val_x, val_y)
     % Load data sets
%      load('source.mat');

    % KernelFunction: 'gaussian', 'rbf', 'linear','polynomial'
    % Alpha coefficient: 'Alpha'
    % Nu: 0 to 1 balancing between most training examples in the positive class
    % and minimise the weights int he score function
    % BoxConstraint
    % KernelScale
    % PolynomialOrder
    % Standardize: True
    % Prior probabilities: 'empirical' to relative frequency to labels or
    % 'uniform' assume 1 / no. of class

    % Default settings
    % Fixed hyper-parameter configurations
    stadardize = true;
    class_nms = {'-1','+1'};
    kernel_scale = 1;
    cost = [0,1; 1,0];
    prior = 'empirical';
    verbose = 0;
    box_constr = 0;
    
    % Get conf from conf object
    kern_func = conf.kern_func;
    poly_order = conf.poly_order;
    box_constr = conf.box_constr;

    % Convert strings to labels
    [trn_y] = to_str_labels(trn_y);
    [val_y] = to_str_labels(val_y);

    % Train model
    if strcmp(kern_func, 'polynomial') == 1
    SVMModel = fitcsvm(trn_x, trn_y, ...
        'KernelFunction', kern_func,...
        'Standardize',stadardize, ...
        'ClassNames', class_nms, ...
        'KernelScale', kernel_scale, ...
        'PolynomialOrder', poly_order, ...
        'Cost', cost, ...
        'Prior', prior, ...
        'BoxConstraint', box_constr, ...
        'Verbose', verbose);
    else
    SVMModel = fitcsvm(trn_x, trn_y, ...
        'KernelFunction', kern_func,...
        'Standardize',stadardize, ...
        'ClassNames', class_nms, ...
        'KernelScale', kernel_scale, ...
        'Cost', cost, ...
        'Prior', prior, ...
        'BoxConstraint', box_constr, ...
        'Verbose', verbose);  
    end

    % Predict using validation set
    [pred_y, pred_y_score] = predict(SVMModel, val_x);

    % Update labels from "-1" to 0 and "1" to 1
    pred_y = to_num_labels(pred_y);
    val_y = to_num_labels(val_y);

    % Calculate performance metrics
    [~, val_metrics] = calc_metrics(pred_y_score, pred_y, val_y, 1, 0, NaN);

%     % Plot ROC
%     plt_title = "ROC: SVM";
%     i = 1;
%     plot_ROC([], val_metric, [], i, plt_title);

%     fprintf('---------- END ----------\n');

    % Replace label to string '+1' or '-1'
    function [new_y] = to_str_labels(y)
        new_y = [];
        for i=1:size(y,1)
            if y(i) == 1
                new_y = [new_y; "+1"];
            elseif y(i) == -1
                new_y = [new_y; "-1"];
            else
                new_y = [new_y; NaN];
            end
        end
    end

    % Convert from string labels '+1' or '-1' to numbers
    function [new_y] = to_num_labels(y)
        new_y = [];
        for i=1:size(y,1)
            new_label = str2num(string(y(i)));
            if new_label == -1
                new_label = 0;
            end
            new_y = [new_y; new_label];
        end
    end


end
