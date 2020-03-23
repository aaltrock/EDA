function [trn_x, trn_y, trn_xy, val_x, val_y, tst_x, tst_y] = create_sample_set(src_x, src_y, trn_idx, val_idx, tst_idx);

    disp("COMPILE TRAIN, VALIDATION, TEST SETS...");
    % Compile training set
    trn_x = create_nn_sample_set(trn_idx, src_x);
    trn_y = create_nn_sample_set(trn_idx, src_y);
    trn_xy = [trn_x trn_y];

    % Compile validation set
    val_x = create_nn_sample_set(val_idx, src_x);
    val_y = create_nn_sample_set(val_idx, src_y);

    % Compile test set
    tst_x = create_nn_sample_set(tst_idx, src_x);
    tst_y = create_nn_sample_set(tst_idx, src_y);

end