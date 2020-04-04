clear();
clc();

hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONFIGURATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exprimental code for Neural Networks                  %
% The code is developed for Neural Computing tutorial   %
% MSc Data Science, CITY UNIVERSITY LONDON              %
% Authors: Son Tran, Artur Garcez                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Compile above parameters into a conf variable
conf = compile_mp_conf(hidNum, activationFnc, eNum, bNum, sNum, lRate, momentum, regCost, ...
    early_stopping_option, E_STOP_VAL_DESIRE_ACC, E_STOP_REPEAT, E_STOP_VAL_ACC_REDUCE, E_STOP_LR_REDUCE, LR_REDUCE_FACTOR)
bs = [];
Ws = [];

% Compile MP, run training, validation and testing per the configuration
[model, metrics] = train_mp(conf, Ws, bs, trn_x, trn_y, val_x, val_y);

% Flatten the array of performance metrics tables into one
if size(metrics,2) > 0
    metrics_flatten = metrics{1};
    for i = 2:size(metrics,2)
        metrics_flatten = [metrics_flatten; metrics{i}];
    end
end
    
% Find output with highest Accuracy over AUC and plot ROC curve with highest AUC
metrics_flatten.ACC_by_AUC = 0.5 .* (metrics_flatten.ACC + metrics_flatten.AUC);
[AUC_max_ACC_by_AUC, max_ACC_by_AUC_epoch] = max(metrics_flatten.ACC_by_AUC);
max_ACC_by_AUC = table2array(metrics_flatten(max_ACC_by_AUC_epoch, 'ACC'));
max_AUC_by_AUC = table2array(metrics_flatten(max_ACC_by_AUC_epoch, 'AUC'));
max_ACC_by_AUC_ROC_x = table2array(table2array(metrics_flatten(max_ACC_by_AUC_epoch, 'ROC_x')));
max_ACC_by_AUC_ROC_y = table2array(table2array(metrics_flatten(max_ACC_by_AUC_epoch, 'ROC_y')));
fig1 = figure(1);
p1 = plot(max_ACC_by_AUC_ROC_x, max_ACC_by_AUC_ROC_y);
legend("ACC: " + string(max_ACC_by_AUC) + "; AUC: " + string(max_AUC_by_AUC));
hold on
title("ROC Curve");
set(fig1,'Position',[10,20,500,500]);
xlabel("False Positive Rate (FPR)");
ylabel("True Positive Rate (TPR)");
hold off
