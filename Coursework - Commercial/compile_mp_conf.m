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
%   .E.STOP = early stopping criteria
%   .desire_acc = desired accuracy

% conf = compile_mp_conf(trn_x, [10 20], {'tansig', 'tansig', 'tansig'}, 50, 1, 0.5,
% 0.1, 0.0001, 10)

function conf = compile_mp_conf(trn_x, hidNum, activationFnc, eNum, bNum, sNum, lRate, momentum, regCost, E_STOP, desire_acc)
    disp("COMPILING Multi-layer perceptron configurations...");
    
    conf.hidNum = hidNum;
    conf.activationFnc = activationFnc;
    conf.eNum = eNum;
    conf.bNum = bNum;
    conf.sNum = sNum;
    conf.params = [lRate lRate momentum regCost];
    conf.E_STOP = E_STOP;
    conf.desire_acc = desire_acc;
end