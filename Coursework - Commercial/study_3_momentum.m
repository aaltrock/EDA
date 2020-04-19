%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STUDY: MOMENTUM CONSTANT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear();
clc();
rng('default');

export_file_nm = "Momentum_tst_results.xlsx";

fprintf("\nMomentum constants for study:\n");
Momentums = linspace(0, 1, 21); %[0, 0.05, 0.1, ..., 0.95, 1.0]
Momentums = Momentums(2:end)

confs = {};
trn_results = {};
val_results = {};
tst_results = {};
results = {};

for i = 1:size(Momentums, 2)
    conf = {};
    plt_title = "";

    % Set hidden layers architecture
    conf.momentum = Momentums(i);

    % Run, train, validation, test
    [model, trn_metrics, val_metrics, tst_metrics] = mlp_main(conf);

    % Compile results
    models{i} = model;
    confs{i} = conf;
    confText = "Momentum Constant: " + num2str(conf.momentum);
    trn_metrics.configuration = confText;
    val_metrics.configuration = confText;
    tst_metrics.configuration = confText;

    % Append result to the set
    trn_results = [trn_results; trn_metrics];
    val_results = [val_results; val_metrics];
    tst_results = [tst_results; tst_metrics];

    % Plot ROC
    plt_title = "ROC: Momentum Constant: " + num2str(conf.momentum);
    plot_ROC([], [], tst_metrics, i, plt_title(1));
end

% Write results to file (Configuration, Epoch to FN columns)
columnsToWrite = {'configuration', 'TPR', 'TNR', 'PPV', 'NPV', 'FNR', 'FPR', 'ACC', 'TP', 'FP', 'TN', 'FN'};
writetable(trn_results(:, columnsToWrite), export_file_nm, 'Sheet','trn_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
writetable(val_results(:, columnsToWrite), export_file_nm, 'Sheet','val_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
writetable(tst_results(:, columnsToWrite), export_file_nm, 'Sheet','tst_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);

% Save data
save('study_3_Momentum.mat');
