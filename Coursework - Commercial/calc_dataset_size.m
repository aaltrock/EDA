function [pop_size, val_size, tst_size, trn_size] = calc_dataset_size(src, val_pct, tst_pct)
    disp("DETERMINE TRAIN, VALIDATION, TEST SET SIZES...");
    % Determine size of the training, validation and test set
    pop_size = size(src, 1);

    disp("Population size:");
    disp(pop_size);

    val_size = round(val_pct * pop_size);
    disp("Validation size:");
    disp(val_size);

    tst_size = round(tst_pct * pop_size);
    disp("Test size:");
    disp(tst_size);

    % Training set size is the remainder of population after validation and
    % test
    trn_size = pop_size - val_size - tst_size;
    disp("Training size:");
    disp(trn_size);

    % Validate the total size corresponds to original population size
    disp("Training + Validation + Test size:");
    disp(trn_size + val_size + tst_size);
end