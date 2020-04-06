clear();
clc();
load('source.mat');

[trn_y] = to_str_labels(trn_y);
[val_y] = to_str_labels(val_y);
[tst_y] = to_str_labels(tst_y);

SVMModel = fitcsvm(trn_x, trn_y,'KernelFunction','rbf',...
    'Standardize',true,'ClassNames',{'-1','+1'});

[pred_y, score] = predict(SVMModel, val_x);

fprintf('---------- END ----------');

% Replace label to string '+1' or '-1'
function [new_y] = to_str_labels(y)
    new_y = [];
    for i=1:size(y,1)
        if y(i) == 1
            new_y = [new_y; "+1"];
        elseif y(i) == -1
            new_y = [new_y; "1"];
        else
            new_y = [new_y; NaN];
        end
    end
end