function [src_x, src_y, pop_size, val_size, tst_size, trn_size, trn_x, trn_y, val_x, val_y, tst_x, tst_y] = compile_trn_val_tst_sets(fileNm, val_pct, tst_pct)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DATA IMPORT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [src_x, src_y] = import_data(fileNm);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SIZES FOR TRAINING, VALIDATION & TESTING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [pop_size, val_size, tst_size, trn_size] = calc_dataset_size(src_x, val_pct, tst_pct);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % RANDOM SELECTIONS FOR TESTING, VALIDATION & TRAINING SETS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [trn_idx, val_idx, tst_idx] = rand_select_src(pop_size, val_size, tst_size, trn_size);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % COMPILE TRAINING, VALIDATION & TEST SETS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [trn_x, trn_y, trn_xy, val_x, val_y, tst_x, tst_y] = create_sample_set(src_x, src_y, trn_idx, val_idx, tst_idx);

end