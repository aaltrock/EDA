function [trn_idx, val_idx, tst_idx] = rand_select_src(pop_size, val_size, tst_size, trn_size)

disp("SELECTION FOR TRAIN, VALIDATION, TEST SETS...");
% Randomly select from index for test per calculated size
tst_idx = randsample(pop_size,tst_size);

    % Remove samples selected for testing
    trn_val_idx = [];
    for i = 1:pop_size
        % If sample not selected in test, add to training and validation set
        if ~ismember(i, tst_idx)
            trn_val_idx = [trn_val_idx; i];
        end
    end

    % Randomly select from remainder for validation per calculated size
    trn_val_rand_idx = randsample(size(trn_val_idx, 1), tst_size);

    % Compile validation samples set
    val_idx = [];
    for i = trn_val_rand_idx
        % Add validation set samples selected randomly by index
        val_idx = [val_idx; trn_val_idx(i)];
    end

    % Compile training samples set by remainder after test and validation
    % selections
    trn_idx = [];
    for i = 1:size(trn_val_idx,1)
        % If sample not selected in validation, add to training
        if ~ismember(trn_val_idx(i), val_idx)
            trn_idx = [trn_idx; trn_val_idx(i)];
        end
    end

end