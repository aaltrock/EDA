%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STUDY: NETWORK ARCHITECTURE - 
% ACTIVATION FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear();
clc();

export_file_nm = "activation_func_tst_results.xlsx";

%           purelin             logsig              tansig
%   purelin {purelin, purelin}  {purelin, logsig}   {purelin, tansig}
%   logsig  {logsig, purelin}   {logsig, logsig}    {logsig, tansig}
%   tansig  {tansig, purelin}   {tansig, logsig}    {tansig, tansig}

act_funcs = {{'purelin', 'purelin'}, ...
                {'purelin', 'logsig'}, ...
                    {'purelin', 'tansig'}, ...
                        {'logsig', 'purelin'}, ...
                            {'logsig', 'logsig'}, ...
                                {'logsig', 'tansig'}, ...
                                    {'tansig', 'purelin'}, ...
                                        {'tansig', 'logsig'}, ...
                                            {'tansig', 'tansig'}};

neurons = {30};

confs = {};
trn_results = {};
val_results = {};
tst_results = {};
results = {};

for i = 1:size(act_funcs, 2)
    conf = {};
    plt_title = "";

    % Set hidden layers architecture
    conf.activationFnc = act_funcs{i};

    % Run, train, validation, test
    [model, trn_metrics, val_metrics, tst_metrics] = mlp_main(conf);

    % Compile results
    models{i} = model;
    confs{i} = conf;
    confText = "Activation Func: " + string(strjoin(conf.activationFnc));
    trn_metrics.configuration = confText;
    val_metrics.configuration = confText;
    tst_metrics.configuration = confText;

    % Append result to the set
    trn_results = [trn_results; trn_metrics];
    val_results = [val_results; val_metrics];
    tst_results = [tst_results; tst_metrics];

    % Plot ROC
    plt_title = "ROC: Activation functions: " + string(strjoin(conf.activationFnc));
    plot_ROC([], [], tst_metrics, i, plt_title(1));
end

% Write results to file (Configuration, Epoch to FN columns)
columnsToWrite = {'configuration', 'TPR', 'TNR', 'PPV', 'NPV', 'FNR', 'FPR', 'ACC', 'TP', 'FP', 'TN', 'FN'};
writetable(trn_results(:, columnsToWrite), export_file_nm, 'Sheet','trn_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
writetable(val_results(:, columnsToWrite), export_file_nm, 'Sheet','val_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
writetable(tst_results(:, columnsToWrite), export_file_nm, 'Sheet','tst_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);

% Save data
save('study_4_activation_func.mat');