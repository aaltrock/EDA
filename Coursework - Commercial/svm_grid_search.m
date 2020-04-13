%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SVM GRID SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear();
clc();

rng('default') % Set random seed to default

% Load data data file
load('source.mat');

% If previous results data file already exists, load the file
if isfile('svm_grid_search.mat') == 1
   % Load save data file
    load('svm_grid_search.mat'); 
end

% If previous results data file does not exist, or val_results does not exist, proceed as
% running for the first time
if isfile('svm_grid_search.mat') == 0 || exist('val_results','var') == 0

    export_file_nm = "svm_grid_search_tst_results.xlsx";
    
    % Hyper-parameters to be reviewed by grid search
    kern_funcs = ["linear", "polynomial", "polynomial", ...
                        "polynomial", "polynomial", "rbf"];
    poly_orders = [0, 1, 2, 3, 4, 0];
    box_constrs = [.1, .2, .3, .4, .5, .6, .7, .8, .9, 1.0];
    
    % Hypter-parameter lengths
    kern_funcs_cnt = size(kern_funcs, 2);
    box_constrs_cnt = size(box_constrs, 2);
    
    % Indexes for each hyper-parmameter type
    % Note: index is unique across all hyper-parameters
    kern_funcs_idx = 1:kern_funcs_cnt;
    box_constrs_idx = max(kern_funcs_idx) + 1:max(kern_funcs_idx) + box_constrs_cnt;
    
    % Create a search grid
    search_grid = combvec(kern_funcs_idx, box_constrs_idx);
    search_grid = search_grid';
    search_grid_tbl_var_nms = {'kern_func_idx', 'box_constr'};
    search_grid = array2table(search_grid, 'VariableNames', search_grid_tbl_var_nms);
    search_grid.kern_func = repmat("func", size(search_grid, 1), 1);
    search_grid.poly_order = zeros(size(search_grid, 1),1);
    
    % Offset the original indexes to start with 1 each
    box_constrs_idx = box_constrs_idx - min(box_constrs_idx) + 1;
    
    % Offset the index in each column in search grid such that it resets to
    % start with 1
    search_grid.poly_order = search_grid.poly_order - min(search_grid.poly_order) + 1;
    search_grid.box_constr = search_grid.box_constr - min(search_grid.box_constr) + 1;
    
    % Fetch parameter (except for kernel func) values based on index in search grid
    for i = 1:size(search_grid, 1)
        k_index = search_grid{i, 'kern_func_idx'};
        search_grid{i, 'kern_func'} = kern_funcs(k_index);
        search_grid{i, 'poly_order'} = poly_orders(k_index);
        search_grid{i, 'box_constr'} = box_constrs(search_grid{i, 'box_constr'});
    end
    
    % Initialise new variables
    confs = {};
    val_results = {};
    tst_results = {};
    results = {};
    models = {};
    
    % Set counter to 1 for the for-loop execution, i.e. start from
    % beginning
    for_loop_start = 1;

% Otherwise, if previous data file exists and the previous result is
% available, then resume by recovering the last iteration number
else
    % Find the increment counter at the last point and move to the next
    % iteration (+1)
    for_loop_start = size(val_results, 1) + 1;
    disp('RESUME FROM ITERATION: ' + num2str(for_loop_start));
end



% For every row in grid search
for i = for_loop_start:size(search_grid, 1)
    
    fprintf("\nRUNNING CONFIGURATION " + string(i) + " / " + string(size(search_grid, 1)));
    
    conf = {};
    plt_title = "";
    
    % Compile activation function from parameters
    conf.kern_func = search_grid{i, 'kern_func'};
    conf.poly_order = search_grid{i, 'poly_order'};
    conf.box_constr = search_grid{i, 'box_constr'};

    % Run, train, validation, but not test
    % [model, trn_metrics, val_metrics, tst_metrics] = mlp_main(conf);
%     [model, trn_metrics, val_metrics, ~] = mlp_main(conf);
    [model, val_metrics] = svm_main(conf, trn_x, trn_y, val_x, val_y);

    % Compile results
    models{i} = model;
    confs{i} = conf;
    confText = "Kernel function: " + search_grid{i, 'kern_func'} + ...
                   "; Polynomial order: " + num2str(search_grid{i, 'poly_order'}) + ...
                   "; Box constraints: " + num2str(search_grid{i, 'box_constr'});
    trn_metrics.configuration = confText;
    val_metrics.configuration = confText;
%     tst_metrics.configuration = confText;

    % Append result to the set
    val_results = [val_results; val_metrics];
%     tst_results = [tst_results; tst_metrics];

%     % Plot ROC
%     plt_title = "ROC - " + confText;
%     plot_ROC(trn_results, val_results, [], i, plt_title(1));

    % Save matlab data file for each iteration
    save('svm_grid_search.mat');

end

% Write results to file (Configuration, Epoch to FN columns)
columnsToWrite = {'configuration', 'TPR', 'TNR', 'PPV', 'NPV', 'FNR', 'FPR', 'ACC', 'TP', 'FP', 'TN', 'FN'};
writetable(trn_results(:, columnsToWrite), export_file_nm, 'Sheet','trn_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
writetable(val_results(:, columnsToWrite), export_file_nm, 'Sheet','val_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);
% writetable(tst_results(:, columnsToWrite), export_file_nm, 'Sheet','tst_results','WriteVariableNames',false, 'Range', 'A1', 'WriteVariableNames', 1);

% Save data
save('svm_grid_search.mat');