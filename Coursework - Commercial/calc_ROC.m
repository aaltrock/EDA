% Implementation adapted from:
% ROC Curve, a Complete Introduction by R. Bagheri, Medium.com
% https://towardsdatascience.com/roc-curve-a-complete-introduction-2f2da2e0434c

function [TPRs, FPRs, Thresholds] = calc_ROC(y, prob, label_pos, label_neg)
    TPRs = [];
    FPRs = [];
    
    % Create an linearly spaced thresholds
    Thresholds = linspace(1.1,0,100);
    
    % For every threshold check if prediction probability is over
    % thresholds
    for i = 1:size(Thresholds,2)
        
        t = Thresholds(i);
        
        y_pred = zeros(size(y, 1), 1);
        
        prob_above_t = prob >= t;
        
        for j = 1:size(prob_above_t, 1)
            if prob_above_t(j) == 1
                y_pred(j, 1) = 1;
            end
        end
        
        TN = 0; TP = 0; FP = 0; FN = 0;
        for k = 1:size(y_pred, 1)
            if y_pred(k) == y(k) && y(k) == label_neg
                TN = TN + 1;
            end
            if y_pred(k) == y(k) && y(k) == label_pos
                TP = TP + 1;
            end
            if y_pred(k) ~= y(k) && y(k) == label_neg
                FP = FP + 1;
            end
            if y_pred(k) ~= y(k) && y(k) == label_pos
                FN = FN + 1;
            end
        end

        TPR = TP / (TP + FN);
        FPR = FP / (FP + TN);
        TPRs = [TPRs TPR];
        FPRs = [FPRs FPR];
    end
    
    % Transpose before returning
    TPRs = TPRs';
    FPRs = FPRs';
end