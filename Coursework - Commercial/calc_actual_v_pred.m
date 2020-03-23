% Function returns calculation matrix and sample classification variances
function [confusion_tbl, samples_tbl, performance_tbl] = calc_actual_v_pred(pred_y, actual_y)
    % Compile table of actual vs predicted
    samples_tbl = pred_y;
    
    % Initialise table variables
    samples_tbl(:,2) = zeros(size(samples_tbl, 1), 1);
    samples_tbl(:,3) = actual_y;
    samples_tbl(:,4) = zeros(size(samples_tbl, 1), 1);
    samples_tbl(:,5) = zeros(size(samples_tbl, 1), 1);
    
    % Set to table
    samples_tbl = array2table(samples_tbl);
    samples_tbl.Properties.VariableNames = {'Pred_Raw', 'Pred_Class', 'Actual_Class', 'is_Match', 'Match_Type'};
    
    % Create a table variable to hold prediction type
    samples_tbl.Match_Class = strings([size(samples_tbl, 1), 1]);
    
    % Counter for actual positive and negative
    P_cnt = 0; N_cnt = 0;
    
    % Counter for TP, FP, TN, FP
    TP_cnt = 0; FP_cnt = 0; TN_cnt = 0; FN_cnt = 0;
    
    % For each sample
    for i = 1:size(samples_tbl, 1)
        % Count positive and negative of actual
        if samples_tbl.Actual_Class(i) == 1
            P_cnt = P_cnt + 1;
        elseif samples_tbl.Actual_Class(i) == -1
            N_cnt = N_cnt + 1;
        end
        
        % Round the results to get predicted class value (-1 or +1)
        if samples_tbl.Pred_Raw(i) < 0 %samples_tbl(i, 1) < 0
            samples_tbl.Pred_Class(i) = -1;
        else
            samples_tbl.Pred_Class(i) = 1;
        end
        % Determine variance between predicted vs actual class values
        if samples_tbl.Pred_Class(i) == samples_tbl.Actual_Class(i)
            samples_tbl.is_Match(i) = 1;
        else
            samples_tbl.is_Match(i) = 0;
        end
        % Determine:
        % 1: True Positive (TP)
        % 2: True Negative (TN)
        % 3: False Negative (FN)
        % 4: False Positive (FP)
        % True positive - Actual = 1 and Pred = 1
        if samples_tbl.Pred_Class(i) == 1 && samples_tbl.Actual_Class(i) == 1
            samples_tbl.Match_Type(i) = 1;
            samples_tbl.Match_Class(i) = 'TP';
            TP_cnt = TP_cnt + 1;
        % True Negative - Actual = 0 and Pred = 0
        elseif samples_tbl.Pred_Class(i) == -1 && samples_tbl.Actual_Class(i) == -1
            samples_tbl.Match_Type(i) = 2;
            samples_tbl.Match_Class(i) = 'TN';
            TN_cnt = TN_cnt + 1;
        % False negative - Actual = 1 and Pred = 0
        elseif samples_tbl.Pred_Class(i) == -1 && samples_tbl.Actual_Class(i) == 1
            samples_tbl.Match_Type(i) = 3;
            samples_tbl.Match_Class(i) = 'FN';
            FN_cnt = FN_cnt + 1;
        % False positive - Actual = 0 and Pred = 1
        elseif samples_tbl.Pred_Class(i) == 1 && samples_tbl.Actual_Class(i) == -1
            samples_tbl.Match_Type(i) = 4;
            samples_tbl.Match_Class(i) = 'FP';
            FP_cnt = FP_cnt + 1;
        end
    end
    
    % Compile confusion matrix
    % Columns: "Predicted Yes" "Predicted No"
    % Rows: "Actual Yes" "Actual No"
    confusion_tbl = zeros(2,2);
    
    % Populate confusion matrix with frequencies of TP, TN, FP and FN
    confusion_tbl(1, 1) = TP_cnt;
    confusion_tbl(2, 2) = TN_cnt;
    confusion_tbl(2, 1) = FN_cnt;
    confusion_tbl(1, 2) = FP_cnt;
    
    confusion_tbl = array2table(confusion_tbl);
    confusion_tbl.Properties.VariableNames = {'Pred_Yes', 'Pred_No'};
    confusion_tbl.Properties.RowNames = {'Actual_Yes', 'Actual_No'};
    
    % Calculate sensitivity (TPR)
    tpr = TP_cnt/size(samples_tbl, 1);
    
    % Calculate specificity (TNR)
    tnr = TN_cnt/size(samples_tbl, 1);
    
    % Calculate positive prediction rate (PPV)
    ppv = TP_cnt/(TP_cnt + FP_cnt);
    
    % Calculate negative prediction rate (NPV)
    npv = TN_cnt/(TN_cnt + FN_cnt);
    
    % Calculate miss rate (FNR)
    fnr = FN_cnt/size(samples_tbl, 1);
    
    % Calculate fall-out rate (FPR)
    fpr = FP_cnt/size(samples_tbl, 1);
    
    % Calculate Accuracy
    acc = (TP_cnt + TN_cnt)/(P_cnt + N_cnt);
    
    % Compile into a table
    performance_tbl = array2table([tpr tnr ppv npv fnr fpr acc]);
    performance_tbl.Properties.VariableNames = {'TPR', 'TNR', 'PPV', 'NPV', 'FNR', 'FPR', 'ACC'};

end