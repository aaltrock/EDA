% Codes adapted from: Neural Computing module Tutorial 4
% Original from Artur S. d'Avila Garcez, Department of Computer Science,
% City, University of London

% conf = configuration, consisting of:
%   .hidNum = array of hidden layer neurons number
%   .activationFnc = list defined activation functions for hidden and
%   output layers {'tnasig', 'logsig'} for one hidden and one output layers
%   .eNum = no. of training epochs
%   .bNum = no. of batches per epoch
%   .sNum = no. of samples per batch
%   .params = array of learning parameters: params(1) = params(2) as
%   learning rates, params(3) as momentum, params(4) as regularisation cost
%   .E_STOP_VAL_DESIRE_ACC = early stopping criteria
%   .desire_acc = desired accuracy
%   .E_STOP_REPEAT = no. of epochs for early termination where
%   performance based on validation set is degraded, then revert to best
%   performance and reduce learning rate.
%   .LR_REDUCE_FACTOR = factor (0 to 1) in rate of reducing Learning Rate

% conf = compile_mp_conf(trn_x, [10 20], {'tansig', 'tansig', 'tansig'}, 50, 1, 0.5,
% 0.1, 0.0001, 10)

function conf = compile_mp_conf(hidNum, activationFnc, eNum, bNum, ...
    sNum, lRate, momentum, regCost, ....
    early_stopping_option, E_STOP_VAL_DESIRE_ACC, E_STOP_REPEAT, E_STOP_VAL_ACC_REDUCE, E_STOP_LR_REDUCE, LR_REDUCE_FACTOR)
    disp("COMPILING Multi-layer perceptron configurations...");
    
    conf.hidNum = hidNum;
    conf.activationFnc = activationFnc;
    conf.eNum = eNum;
    conf.bNum = bNum;
    conf.sNum = sNum;
    conf.params = [lRate lRate momentum regCost];
    conf.early_stopping_option = early_stopping_option;
    conf.E_STOP_VAL_DESIRE_ACC = E_STOP_VAL_DESIRE_ACC;
    conf.E_STOP_REPEAT = E_STOP_REPEAT;
    conf.E_STOP_VAL_ACC_REDUCE = E_STOP_VAL_ACC_REDUCE;
    conf.E_STOP_LR_REDUCE = E_STOP_LR_REDUCE;
    conf.LR_REDUCE_FACTOR = LR_REDUCE_FACTOR;
end