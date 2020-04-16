function [confusion_tbl, mp_net_output_tbl, performance_tbl] = evaluate_mp(mp_net, actual_x, actual_y)

    % Predict with validation set
    mp_net_output = transpose(mp_net(transpose(actual_x)));

    % Compare predicted with actuals
    [confusion_tbl, mp_net_output_tbl, performance_tbl] = calc_actual_v_pred(mp_net_output, actual_y);

end