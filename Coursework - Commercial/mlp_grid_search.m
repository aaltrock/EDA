%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEURAL NETWORK GRID SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear();
clc();

rng('default') % Set random seed to default

export_file_nm = "mlp_grid_search_tst_results.xlsx";

% Define hypter-parameter ranges
% Exhaustive
% hidden_layers = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
% act_func_hidden = ["purelin", "logsig", "tansig"];
% act_func_output = ["purelin", "logsig", "tansig"];
% momentum_const = linspace(0, 1, 21); %[0, 0.05, 0.1, ..., 0.95, 1.0]
% learning_rate = linspace(0, 1, 21); %[0, 0.05, 0.1, ..., 0.95, 1.0]

% Selection based on initial analysis for each hypter-parameter changes
hidden_layers = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
act_func_hidden = "tansig";
act_func_output = "tansig";
momentum_const = [0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75];
learning_rate = [0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6];


% Hypter-parameter lengths
hidden_layers_cnt = size(hidden_layers, 2);
act_func_hidden_cnt = size(act_func_hidden, 2);
act_func_output_cnt = size(act_func_output, 2);
momentum_const_cnt = size(momentum_const, 2);
learning_rate_cnt = size(learning_rate, 2);

% Indexes for each hyper-parmameter type
% Note: index is unique across all hyper-parameters
hidden_layers_idx = 1:hidden_layers_cnt;
act_func_hidden_idx = max(hidden_layers_idx) + 1:max(hidden_layers_idx) + act_func_hidden_cnt;
act_func_output_idx = max(act_func_hidden_idx) + 1:max(act_func_hidden_idx) + act_func_output_cnt;
momentum_const_cnt_idx = max(act_func_output_idx) + 1:max(act_func_output_idx) + momentum_const_cnt;
learning_rate_cnt_idx = max(momentum_const_cnt_idx) + 1:max(momentum_const_cnt_idx) + learning_rate_cnt;

% Create a search grid
search_grid = combvec(hidden_layers_idx, act_func_hidden_idx, ...
                        act_func_output_idx, momentum_const_cnt_idx, learning_rate_cnt_idx);
search_grid = search_grid';
search_grid_tbl_var_nms = {'hidden_size', 'act_func_hidden_idx', 'act_func_output_idx', 'mo', 'lr'};
search_grid = array2table(search_grid, 'VariableNames', search_grid_tbl_var_nms);

% Offset the index in each column in search grid such that it resets to
% start with 1
search_grid.act_func_hidden_idx = search_grid.act_func_hidden_idx - min(search_grid.act_func_hidden_idx) + 1;
search_grid.act_func_output_idx = search_grid.act_func_output_idx - min(search_grid.act_func_output_idx) + 1;
search_grid.mo = search_grid.mo - min(search_grid.mo) + 1;
search_grid.lr = search_grid.lr - min(search_grid.lr) + 1;

% Fetch parameter (except for activation func) values based on index in search grid
for i = 1:size(search_grid, 1)
    search_grid{i, 'hidden_size'} = hidden_layers(search_grid{i, 'hidden_size'});
    search_grid{i, 'mo'} = momentum_const(search_grid{i, 'mo'});
    search_grid{i, 'lr'} = learning_rate(search_grid{i, 'lr'});
end

confs = {};
trn_results = {};
val_results = {};
tst_results = {};
results = {};
models = {};

% For every row in grid search
for i = 1:size(search_grid, 1)
    
    fprintf("RUNNING CONFIGURATION " + string(i) + " / " + string(size(search_grid, 1)));
    
    conf = {};
    plt_title = "";
    
    % Compile activation function from parameters
    act_func1 = act_func_hidden(search_grid{i, 'act_func_hidden_idx'});
    act_func2 = act_func_output(search_grid{i, 'act_func_output_idx'});
    activationFnc = {act_func1, act_func2};

    % Set hyper-parameter options for each row in grid search
    conf.hidNum = search_grid{i, 'hidden_size'};
    conf.activationFnc = activationFnc;
    conf.momentum = search_grid{i, 'mo'};
    conf.lRate = search_grid{i, 'lr'};

    % Run, train, validation, but not test
    % [model, trn_metrics, val_metrics, tst_metrics] = mlp_main(conf);
    [model, trn_metrics, val_metrics, ~] = mlp_main(conf);

    % Compile results
    models{i} = model;
    confs{i} = conf;
    confText = "Hidden layer: " + string(conf.hidNum) + ...
                   "; Activation Func: " + strjoin(string(conf.activationFnc)) + ...
                   "; Learning Rate: " + string(conf.lRate) + ...
                   "; Momentum: " + string(conf.momentum);
    trn_metrics.configuration = confText;
    val_metrics.configuration = confText;
%     tst_metrics.configuration = confText;

    % Append result to the set
    trn_results = [trn_results; trn_metrics];
    val_results = [val_results; val_metrics];
%     tst_results = [tst_results; tst_metrics];

%     % Plot ROC
%     plt_title = "ROC - " + confText;
%     plot_ROC(trn_results, val_results, [], i, plt_title(1));

    % Save matlab data file for each iteration
    save('mlp_grid_search.mat');

end

% Write results to file (Configuration, Epoch to FN columns)
columnsToWrite = {'configuration', 'TPR', 'TNR', 'PPV', 'NPV', 'FNR', 'FPR', 'ACC', 'TP', 'FP', 'TN', 'FN'};
writetable(trn_results(:, columnsToWrite), export_file_nm, 'Sheet','trn_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
writetable(val_results(:, columnsToWrite), export_file_nm, 'Sheet','val_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
% writetable(tst_results(:, columnsToWrite), export_file_nm, 'Sheet','tst_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);

% Save data
save('mlp_grid_search.mat');