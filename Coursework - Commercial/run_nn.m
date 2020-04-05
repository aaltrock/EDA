% Codes adapted from: Neural Computing module Tutorial 4 train_nn function
% Original from Artur S. d'Avila Garcez, Department of Computer Science,
% City, University of London

function [cout_raw, cout] = run_nn(actFncs,model,dat)
    for i=1:length(actFncs)
        input = bsxfun(@plus,dat*model.Ws{i},model.bs{i});
        actFunc =  str2func(actFncs{i});
        dat = actFunc(input);
    end
    cout_raw = dat;
    [~,cout] = max(dat,[],2);
    
    % Apply soft max to convert to probability distribution
    for i=1:size(cout_raw, 1)
        cout_raw(i,:) = softmax(cout_raw(i,:)')';
%         cout_raw(i, 1) = cout_raw(i, 1) / (cout_raw(i, 1) + cout_raw(i, 2));
%         cout_raw(i, 2) = cout_raw(i, 2) / (cout_raw(i, 1) + cout_raw(i, 2));
    end
    
end

