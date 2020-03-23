function net = train_mp(trn_x, trn_y, mp_hidden_layers, mp_trn_func, max_epoch, flag_batching, batch_nbr)

    disp("TRAINING Multi-layer perceptron...");
    % Construct a feed forward neural network
    net = fitnet(mp_hidden_layers, mp_trn_func);

    % Configure neural network
    net.trainParam.epochs=max_epoch; % Epoch

    % If batch is used
    if flag_batching
        disp("Batching selected.");
        batch_size = round(size(trn_x, 1) / batch_nbr, 0); % sample size per batch
        fprintf("Batch size: %d Batch no.: batch_nbr %d", batch_size, batch_nbr);
    else
        disp("Batching not selected.");
    end
    
    net.trainParam

    % Train network with re-sampled data
    net = train(net, transpose(trn_x), transpose(trn_y));
    disp(net.trainParam);
    view(net);

end