%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Plot ROC curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

function plot_ROC(trn_metrics, val_metrics, tst_metrics, i, plt_title)

    hold off
    fig = figure(i);
    set(fig,'Position',[10,20,500,500]);
    legends = [];

    % If training metrics is supplied
    if size(trn_metrics, 2) > 0
        trn_ROC_x = table2array(trn_metrics.ROC_x);
        trn_ROC_y = table2array(trn_metrics.ROC_y);
        p1 = plot(trn_ROC_x, trn_ROC_y);
        legends = [legends "Train accuracy: " + string(trn_metrics.ACC)];
        hold on
    end

    % If validation metrics is supplied
    if size(val_metrics, 2) > 0
        val_ROC_x = table2array(val_metrics.ROC_x);
        val_ROC_y = table2array(val_metrics.ROC_y);
        p2 = plot(val_ROC_x, val_ROC_y);
        legends = [legends "Validation accuracy: " + string(val_metrics.ACC)];
        hold on
    end

    % If test metrics is supplied
    if size(tst_metrics, 2) > 0
        tst_ROC_x = table2array(tst_metrics.ROC_x);
        tst_ROC_y = table2array(tst_metrics.ROC_y);
        p3 = plot(tst_ROC_x, tst_ROC_y);
        legends = [legends "Test accuracy: " + string(tst_metrics.ACC)];
    end

    % legend(["Training: ACC: " + string(trn_metrics.ACC) + "; AUC: " + string(trn_metrics.AUC), ...
    %     "Validation: ACC: " + string(val_metrics.ACC) + "; AUC: " + string(val_metrics.AUC), ...
    %     "Test: ACC: " + string(tst_metrics.ACC) + "; AUC: " + string(tst_metrics.AUC)]);
    title(plt_title);
    xlabel("False Positive Rate (FPR)");
    ylabel("True Positive Rate (TPR)");
    legend(legends);
    hold off

end