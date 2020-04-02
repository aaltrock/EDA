clear();
clc();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONFIGURATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exprimental code for Neural Networks                  %
% The code is developed for Neural Computing tutorial   %
% MSc Data Science, CITY UNIVERSITY LONDON              %
% Authors: Son Tran, Artur Garcez                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% conf.hidNum = [20, 30]; % number of nodes in each hidden layer
% conf.activationFnc =  % tansig, logsig, purelin
% conf.eNum   = 10;% epoch number
% conf.bNum   = 10; % batch number
% conf.sNum   = round(trn_size/10); % sample size per batch
% conf.params = [0.5 0.1 0.1 0.0001];
% 
% conf.E_STOP = 10;

% Configuration - percentage of population for validation and test
% Note: training size is the remainder of validation and test
val_pct = 0.15;
tst_pct = 0.15;

% conf.hidNum = [20, 30]; % number of nodes in each hidden layer
% conf.activationFnc = ('tansig','logsig','tansig'); % tansig, logsig, purelin
% conf.eNum   = 10;% set number of epochs
% conf.bNum   = 0; % set later in each dataset
% conf.sNum   = 0; % set later in each dataset
% conf.params = [0.5 0.1 0.1 0.0001];

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA IMPORT, COMPILE TRAIN, VALIDATION & TEST SETS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[src_x, src_y, ...
    pop_size, val_size, tst_size, trn_size, ...
    trn_x, trn_y, val_x, val_y, tst_x, tst_y] ...
    = compile_trn_val_tst_sets('matlab_df.xlsx', val_pct, tst_pct);

% Replace negative negative class labels -1 to 0
trn_y = set_pos_labels(trn_y);
val_y = set_pos_labels(val_y);
tst_y = set_pos_labels(tst_y);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPILE NETWORK CONFIGURATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hidNum = [20]; % number of nodes in each hidden layer
activationFnc = {'tansig', 'tansig'}; % tansig, logsig, purelin
eNum = 100;
bNum = 1;
sNum = floor(size(trn_x, 1)/bNum);
lRate = 0.5;
momentum = 0.1;
regCost = 0.0001;

% Early stopping strategy - by reaching desired accuracy before epoch
E_STOP = 10;
desire_acc = 0.8;

% Early stopping strategy - stop after a set number of epochs with
% continually degrading 
E_STOP_LR_REDUCE = 0.1*eNum;

% Compile above parameters into a conf variable
conf = compile_mp_conf(trn_x, hidNum, activationFnc, eNum, bNum, sNum, lRate, momentum, regCost, E_STOP, desire_acc, E_STOP_LR_REDUCE)
bs = [];
Ws = [];

% Compile MP, run training, validation and testing per the configuration
model = train_mp(conf, Ws, bs, trn_x, trn_y, val_x, val_y);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % TRAINING FEEDFORWARD
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% disp("(1) EXPERMENT TO FIND OPTIMAL HIDDEN LAYER SIZE:")
% 
% % Function Parameters for 'trainbr'
% %  
% %     Show Training Window Feedback   showWindow: true
% %     Show Command Line Feedback showCommandLine: false
% %     Command Line Frequency                show: 25
% %     Maximum Epochs                      epochs: 20
% %     Maximum Training Time                 time: Inf
% %     Performance Goal                      goal: 0
% %     Minimum Gradient                  min_grad: 1e-07
% %     Maximum Validation Checks         max_fail: 0
% %     Mu                                      mu: 0.005
% %     Mu Decrease Ratio                   mu_dec: 0.1
% %     Mu Increase Ratio                   mu_inc: 10
% %     Maximum mu                          mu_max: 10000000000
% 
% % Configuration
% % mp_hidden_layers = [20]; % Vector of neuro numbers per hidden layer
% activationFnc = "tansig"; % Activation functions: 'tansig','logsig'
% mp_trn_func = "trainb"; % Training function
% batch_nbr = 10; % Batch number
% flag_batching = true;
% max_epoch = 50; % Max no. of epoch
% E_STOP = 10; % 
% 
% % Set range of hidden layer size to experiment
% % From 1 to half the number of input features
% min_hidden_layers = 2;
% max_hidden_layer = 10;
% run_nr = max_hidden_layer - min_hidden_layers + 1; % Number of runs to compare performance of varying hidden layer size
% fprintf("RANGE OF HIDDEN LAYERS: %d to %d\n", min_hidden_layers, max_hidden_layer);
% 
% % Generate a number range of hidden neuron sizes
% hidden_layer_size_range = round(linspace(min_hidden_layers, max_hidden_layer, run_nr), 0)
% 
% all_val_p_confusion_tbl = [];
% all_val_performance_tbl = [];
% % For each hidden layer size selected
% for i = hidden_layer_size_range
%     % Set hidden layer size as the 
%     mp_hidden_layers = i;
%     fprintf("HIDDEN LAYER SIZE: %d\n", i);
%     mp_net = train_mp(trn_x, trn_y, mp_hidden_layers, mp_trn_func, max_epoch, flag_batching, batch_nbr);
%     [val_p_confusion_tbl, val_p_tbl, val_performance_tbl] = evaluate_mp(mp_net, val_x, val_y);
%     
%     all_val_p_confusion_tbl = [all_val_p_confusion_tbl; [[i; i] table2array(val_p_confusion_tbl)]];
%     all_val_performance_tbl = [all_val_performance_tbl; [i table2array(val_performance_tbl)]];
%     
% end
% 
% % Set variable names in the table
% all_val_p_confusion_tbl = array2table(all_val_p_confusion_tbl);
% all_val_p_confusion_tbl.Properties.VariableNames = {'Hidden_Layer_Size', 'Pred_Yes', 'Pred_No'};
% all_val_performance_tbl = array2table(all_val_performance_tbl);
% all_val_performance_tbl.Properties.VariableNames = {'Hidden_Layer_Size', 'TPR', 'TNR', 'PPV', 'NPV', 'FNR', 'FPR', 'ACC'};
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % EVALUATE WITH VALIDATION SET
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% % disp("VALIDATE MP...");
% % [val_p_confusion_tbl, val_p_tbl, val_performance_tbl] = evaluate_mp(mp_net, val_x, val_y);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % EVALUATE WITH TEST SET
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% disp("TEST MP...");
% [tst_p_confusion_tbl, tst_p_tbl, tst_performance_tbl] = evaluate_mp(mp_net, tst_x, tst_y);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % RESAMPLE TO BALANCE MINORITY CLASSES IN TARGET VARIABLE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % % Apply SMOTE to balance minor classes
% % [trn_x_SMOTE, trn_y_SMOTE] = SMOTE(trn_x, trn_y);
% % 
% % % In training set, count the frequency per class in the target variable
% % [grp_cnt, grp_class] = groupcounts(trn_y);
% % trn_y_cnt = [grp_class, grp_cnt];
% % grp_cnt_pct = trn_y_cnt(:,2) ./ sum(trn_y_cnt(:,2)) .* 100; %Frequency per closed code
% % grp_cnt_rank_idc = floor(tiedrank(trn_y_cnt(:,2))); %Rank incdices of count ascending
% % trn_y_cnt = [trn_y_cnt, grp_cnt_pct, grp_cnt_rank_idc];
% % 
% % % In training set, count the frequency per class in the target variable
% % [grp_SMOTE_cnt, grp_SMOTE_class] = groupcounts(trn_y_SMOTE);
% % trn_y_SMOTE_cnt = [grp_SMOTE_class, grp_SMOTE_cnt];
% % grp_cnt_SMOTE_pct = trn_y_SMOTE_cnt(:,2) ./ sum(trn_y_SMOTE_cnt(:,2)) .* 100; %Frequency per closed code
% % grp_cnt_rank_SMOTE_idc = floor(tiedrank(trn_y_SMOTE_cnt(:,2))); %Rank incdices of count ascending
% % trn_y_SMOTE_cnt = [trn_y_SMOTE_cnt, grp_cnt_SMOTE_pct, grp_cnt_rank_SMOTE_idc];
% % 
% 
% % % In training set, count the frequency per class in the target variable
% % [grp_cnt, grp_class] = groupcounts(trn_y);
% % trn_y_cnt = [grp_class, grp_cnt];
% % grp_cnt_pct = trn_y_cnt(:,2) ./ sum(trn_y_cnt(:,2)) .* 100; %Frequency per closed code
% % grp_cnt_rank_idc = floor(tiedrank(trn_y_cnt(:,2))); %Rank incdices of count ascending
% % trn_y_cnt = [trn_y_cnt, grp_cnt_pct, grp_cnt_rank_idc];
% % 
% % disp('No. of classes:');
% % disp(size(trn_y_cnt,1));
% % 
% % % Calculate mean class size
% % class_mean = floor(mean(trn_y_cnt(:,2)));
% % 
% % % Re-sample by adjusting the class size in training set to mean class size
% % trn_xy_resampled = [];
% % for i = 1:size(trn_y_cnt,1)
% %     disp(i);
% %     class_val = trn_y_cnt(i,1);
% %     new_trn_xy = adjust_samples(class_val, trn_xy, class_mean);
% %     trn_xy_resampled = [trn_xy_resampled; new_trn_xy];
% % end
% % 
% % % Split training set to dependent and independent variables
% % trn_x_resampled = trn_xy_resampled(:,1:size(trn_xy_resampled,2)-1);
% % trn_y_resampled = trn_xy_resampled(:,size(trn_xy_resampled,2));
% % 
% % 
% % % In training set, re-count the frequency per class in re-sampled training set
% % [grp_cnt_resampled, grp_class_resampled] = groupcounts(trn_y_resampled);
% % trn_y_cnt_resampled = [grp_class_resampled, grp_cnt_resampled];
% % grp_cnt_resampled_pct = trn_y_cnt_resampled(:,2) ./ sum(trn_y_cnt_resampled(:,2)) .* 100; %Frequency per closed code
% % grp_cnt_rank_resampled_idc = floor(tiedrank(trn_y_cnt_resampled(:,2))); %Rank incdices of count ascending
% % trn_y_cnt_resampled = [trn_y_cnt_resampled, grp_cnt_resampled_pct, grp_cnt_rank_resampled_idc];
% 
% 
% 
% % % Evaluate with validation set
% % val_perf = perform(mp_net, val_x, val_y);
% % disp(mp_net.performFcn);
% % fprintf("MSE: %d\n", val_perf);


