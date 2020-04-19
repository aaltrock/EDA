%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main script to run for each given study               %
% Reference:                                            %
% The code is modified from Neural Computing tutorial   %
% MSc Data Science, CITY UNIVERSITY LONDON              %
% Authors: Son Tran, Artur Garcez                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [model, best_trn_metrics, best_val_metrics, tst_metrics] = mlp_main(override_conf)

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
    regCost = 0.0001;
    momentum = 0.1;

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
    
    % Learning Rate
    if isfield(override_conf,'lRate')
        lRate = override_conf.lRate;
    end

    % Momentum Constant
    if isfield(override_conf,'momentum')
        momentum = override_conf.momentum;
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
