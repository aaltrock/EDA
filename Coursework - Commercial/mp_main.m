%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reference:                                            %
% The code is modified from Neural Computing tutorial   %
% MSc Data Science, CITY UNIVERSITY LONDON              %
% Authors: Son Tran, Artur Garcez                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STUDY 1: NETWORK ARCHITECTURE - 
% HIDDEN LAYER SIZE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear();
clc();

export_file_nm = "hidden_layers_tst_results.xlsx";

neurons = {10, 20, 30, 40, 50, ...
    [10, 10], [20, 10], [30, 10], [40, 10], [50, 10]};

act_funcs_single_hidden = {'tansig', 'tansig'};
act_funcs_two_hidden = {'tansig', 'tansig', 'tansig'};

confs = {};
trn_results = {};
val_results = {};
tst_results = {};
results = {};

for i = 1:size(neurons, 2)
    conf = {};
    plt_title = "";
    
    % Set hidden layers architecture
    conf.hidNum = neurons{i};
    
    % Set activation:
    if size(conf.hidNum, 2) == 1
        % If single hidden layer
        conf.activationFnc = act_funcs_single_hidden;
    elseif size(conf.hidNum, 2) == 2
        % If two hidden layers
        conf.activationFnc = act_funcs_two_hidden;
    end
    
    % Run, train, validation, test
    [trn_metrics, val_metrics, tst_metrics] = run(conf);
    
    % Compile results
    confs{i} = conf;
    confText = num2str(conf.hidNum) + "; " + strjoin(conf.activationFnc);
    trn_metrics.configuration = confText;
    val_metrics.configuration = confText;
    tst_metrics.configuration = confText;
    
    % Append result to the set
    trn_results = [trn_results; trn_metrics];
    val_results = [val_results; val_metrics];
    tst_results = [tst_results; tst_metrics];
    
    % Plot ROC
    plt_title = "ROC: Hidden Layers: " + num2str(conf.hidNum) + ...
        "; " + " Activation Functions: " + string(conf.activationFnc);
    plot_ROC([], [], tst_metrics, i, plt_title(1));
end

% Write results to file (Configuration, Epoch to FN columns)
columnsToWrite = {'configuration', 'TPR', 'TNR', 'PPV', 'NPV', 'FNR', 'FPR', 'ACC', 'TP', 'FP', 'TN', 'FN'};
writetable(trn_results(:, columnsToWrite), export_file_nm, 'Sheet','trn_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
writetable(val_results(:, columnsToWrite), export_file_nm, 'Sheet','val_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
writetable(tst_results(:, columnsToWrite), export_file_nm, 'Sheet','tst_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);

% Save data
save('study_1_hidden_layers_size.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STUDY 2: BATCH SIZE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STUDY 3: EPOCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STUDY 4: LEARNING RATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



fprintf("---------- END ----------");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONFIGURATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [best_trn_metrics, best_val_metrics, tst_metrics] = run(override_conf)

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DATA IMPORT, COMPILE TRAIN, VALIDATION & TEST SETS
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Load MATLAB data file with the compiled training, validation and test
    % sets
    load('source.mat');

    % Replace negative negative class labels -1 to 0
    trn_y = set_pos_labels(trn_y);
    val_y = set_pos_labels(val_y);
    tst_y = set_pos_labels(tst_y);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DEFAULT CONFIGURATIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Default configurations for neural networks below unless overrode by
    % function parameters
    hidNum = [20]; % number of nodes in each hidden layer
    activationFnc = {'tansig', 'tansig'}; % tansig, logsig, purelin
    eNum = 100;
    bNum = 1;
    sNum = floor(size(trn_x, 1)/bNum);
    lRate = 0.5;
    momentum = 0.1;
    regCost = 0.0001;

    % EARLY STOPPING: EITHER ONE OF THE FOLLOWING STRATEGIES:
    % 'NO_EARLY_STOP' - no early stopping
    % 'VAL_ACC_REDUCE_MULTI_STOP' - after repeated decrease in validation
    % accuracy, stop
    % repeated deteriations
    % 'VAL_ACC_REDUCE_LOWER_LR' - same as VAL_ACC_REDUCE_MULTI_STOP except reduce LR and re-train
    % from the point where the optimal solutionw as found at the time
    % 'DESIRE_VAL_ACC' - stop as soon as desired validaiton accuracy is
    % achieved
    early_stopping_option = "NO_EARLY_STOP";

    % Initialise all early stopping option variables
    E_STOP_VAL_DESIRE_ACC = 0;
    E_STOP_REPEAT = 0;
    E_STOP_VAL_ACC_REDUCE = 0;
    E_STOP_LR_REDUCE = 0;
    LR_REDUCE_FACTOR = 0;

    % Early stopping strategy 'VAL_ACC_REDUCE_MULTI_STOP' - by n times validation
    % accuracy deteriates
    E_STOP_REPEAT = floor(0.02*eNum);

    % Early stopping strategy 'VAL_ACC_REDUCE_REDUCE_LR' - extension to  stop after a set number of epochs with
    % continually degrading 
    E_STOP_REPEAT = floor(0.05*eNum);
    LR_REDUCE_FACTOR = 0.1;

    % Early stopping strategy 'DESIRE_VAL_ACC' - stop once desired validation
    % accuracy is reached
    E_STOP_VAL_DESIRE_ACC = 0.8;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % OVERRIDE DEFAUILT CONFIGS
    % FOR EACH STUDY
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    % Hidden layer(s)
    if isfield(override_conf,'hidNum')
        hidNum = override_conf.hidNum;
    end
    
    % Activation functions
    if isfield(override_conf,'activationFnc')
        activationFnc = override_conf.activationFnc;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INITIALISATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    % Compile above parameters into a conf variable
    conf = compile_mp_conf(hidNum, activationFnc, eNum, bNum, sNum, lRate, momentum, regCost, ...
        early_stopping_option, E_STOP_VAL_DESIRE_ACC, E_STOP_REPEAT, E_STOP_VAL_ACC_REDUCE, E_STOP_LR_REDUCE, LR_REDUCE_FACTOR)
    bs = [];
    Ws = [];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TRAIN AND VALIDATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    % Compile MP, run training, validation and testing per the configuration
    [model, e_best, trn_cout_raws, trn_couts, ...
    val_cout_raws, val_couts, best_trn_metrics, best_val_metrics] = train_mp(conf, Ws, bs, trn_x, trn_y, val_x, val_y);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  TEST
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Run best performing model based on test set
    [tst_pred_y_raw, tst_pred_y] = run_nn(conf.activationFnc,model,tst_x);
    % Update the predicted labels 2 to 1 and 1 to 0
    tst_pred_y = tst_pred_y - 1;
    % Run metrics on the output based on test data
    [tst_samples, tst_metrics] = calc_metrics(tst_pred_y_raw, tst_pred_y, tst_y, 1, 0, 1);

end
