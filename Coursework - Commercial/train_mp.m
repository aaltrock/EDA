% Codes adapted from: Neural Computing module Tutorial 4 train_nn function
% Original from Artur S. d'Avila Garcez, Department of Computer Science,
% City, University of London

% conf = neural network configurations (see compile_mp_conf.m)
% Ws = supplied weights
% bs = supplied biases
% trn_lab = Trained classification labels
% trn_dat = Training features
% val_lab = Validation classification labels
% val_dat = Validation features

function model = train_mp(conf,Ws,bs,trn_dat,trn_lab,vld_dat,vld_lab)

% INTERNAL VARIABLES:
% SZ = sample size
% VisNum = feature size
% depth = no. of layers (hiddena nd output)
% labNum = no. of output classes

% Determine training samples and features sizes
[SZ,visNum] = size(trn_dat);

% Calculate no. of layers (hidden + output)
depth = length(conf.hidNum)+1;

% Calculate output class size
labNum = size(unique(trn_lab),1);

if isempty(Ws)
 % Random initialisation of Weights Ws if not provided
    model.Ws{1} = (1/visNum)*(2*rand(visNum,conf.hidNum(1))-1);
    DW{1} = zeros(size(model.Ws{1}));
    % Add another layer of weights for each layer after 1st hidden
    % layer
    for i=2:depth-1
        model.Ws{i} = (1/conf.hidNum(i-1))*(2*rand(conf.hidNum(i-1),conf.hidNum(i))-1);
        DW{i} = zeros(size(model.Ws{i}));
    end
    model.Ws{depth} = (1/conf.hidNum(depth-1))*(2*rand(conf.hidNum(depth-1),labNum)-1);
    DW{depth} = zeros(size(model.Ws{depth}));
else
    model.Ws = Ws;
    for i=1:depth, DW{i} = zeros(size(model.Ws{i})); size(model.Ws{i}); end
    clear Ws
end

if isempty(bs)
 % Initialize bs
    % For every layer
    for i=1:depth-1
        model.bs{i} = zeros(1,conf.hidNum(i));
        DB{i} = model.bs{i};
    end
    model.bs{depth} = zeros(1,labNum);
    DB{depth} = model.bs{depth};
else 
    model.bs  = bs;
end
bNum = conf.bNum;

% Set batch nr 1 if not defined (i.e. 0)
if conf.bNum == 0, bNum   = round(SZ/conf.sNum); end

% Variables to hold plot data points
plot_trn_acc = [];
plot_vld_acc = [];
plot_mse = [];

vld_best = 0;
es_count = 0;
acc_drop_count = 0;
vld_acc  = 0;
tst_acc  = 0;

% Initialise epoch count
e = 0;

% Set running flag as 1
running = 1;

lr = conf.params(1);
% While no early stopping or witin epoch limit set
while running
    MSE = 0;
    e = e+1;
    % For each batch
   for b=1:bNum
       % Get indexes of observations for batch from training set
       inx = (b-1)*conf.sNum+1:min(b*conf.sNum,SZ);
       
       % Compile batch features and output classification
       batch_x = trn_dat(inx,:);
       batch_y = trn_lab(inx)+1;
       
       % Batch size
       sNum = size(batch_x,1);
       % Forward mesage to get output
       input{1} = bsxfun(@plus,batch_x*model.Ws{1},model.bs{1});
       % Hidden layer activation function
       actFunc = str2func(conf.activationFnc{1});
       output{1} = actFunc(input{1});
       % For each hidden layer, from first (i=2) to other hidden layers
       for i=2:depth
           
           % Calculate current hidden layer = output of previous layer * weight + bias
           input{i} = bsxfun(@plus,output{i-1}*model.Ws{i},model.bs{i});
           
           % Caluclate input values for next layer per layer activation function
           actFunc=  str2func(conf.activationFnc{i});
           output{i} = actFunc(input{i});
       end
       %output{depth} = output{depth}
       
       % BACKPROPAGATION UPDATE
       
       y = discrete2softmax(batch_y,labNum);
       %disp([y output{depth}]);
       
       % Calculate instaneous energy of neurons
       err{depth} = (y-output{depth}).*deriv(conf.activationFnc{depth},input{depth});
       
       % Calculate output based on maximum of each row across the two
       % labels
       [~,cout] = max(output{depth},[],2);                                                                                                  
       %sum(sum(batch_y+1==cout))
       
       % Calculate and aggregate MSE
       MSE = MSE + mean(sqrt(mean((output{depth}-y).^2)));
       
       % For every layer backward decrementally
       for i=depth:-1:2
           
           % Error total
           diff = output{i-1}'*err{i}/sNum;
           % Weights adjustment as partial derivative of total error
           DW{i} = lr*(diff - conf.params(4)*model.Ws{i}) + conf.params(3)*DW{i};
           model.Ws{i} = model.Ws{i} + DW{i};
           
           % Bias adjustment
           DB{i} = lr*mean(err{i}) + conf.params(3)*DB{i};
           model.bs{i} = model.bs{i} + DB{i};
           
           % Refresh error to the output of the preceding layer
           err{i-1} = err{i}*model.Ws{i}'.*deriv(conf.activationFnc{i},input{i-1});
       end
       
       diff = batch_x'*err{1}/sNum;        
       DW{1} = lr*(diff - conf.params(4)*model.Ws{1}) + conf.params(3)*DW{1};
       model.Ws{1} = model.Ws{1} + DW{1};       
       
       DB{1} = lr*mean(err{1}) + conf.params(3)*DB{1};
       model.bs{1} = model.bs{1} + DB{1};       
   end
   
   % Get training classification error
   %trn_dat
   %model.Ws{1} = 0*model.Ws{1};
   %model.Ws{2} = 0*model.Ws{2};
   %pause
   cout = run_nn(conf.activationFnc,model,trn_dat); 
   %cout
   trn_acc = sum((cout-1)==trn_lab)/size(trn_lab,1);
   
   % Run again with validation set
   cout = run_nn(conf.activationFnc,model,vld_dat);
   vld_acc = sum((cout-1)==vld_lab)/size(vld_lab,1);
   fprintf('[Eppoch %4d] MSE = %.5f| Train acc = %.5f|Validation acc = %.5f\n',e,MSE,trn_acc,vld_acc);
   
   % Collect data for plot
   plot_trn_acc = [plot_trn_acc trn_acc];
   plot_vld_acc = [plot_vld_acc vld_acc];
   plot_mse     = [plot_mse MSE];
   %pause;
   
   %% EARLY STOPPING
   % PARAM DECAY
   % Early stopping based on no. of early termination runs
    if isfield(conf,'E_STOP_LR_REDUCE')
        % If current epoch validation performance is not the best
        if vld_acc<=vld_best
            % Increment counter for dropping validation performance
            acc_drop_count = acc_drop_count + 1;
            % If accuracy reduces for a number of time, then turn back to the
            % best model and reduce the learning rate
            if acc_drop_count > conf.E_STOP_LR_REDUCE
                fprintf('Learning rate reduced!\n');
                acc_drop_count = 0;
                es_count = es_count + 1; %number of reduce learning rate
                lr = lr/10;
                model = model_best;
            end
        % Else performance is best yet over the validation data set
        else
            % Reset counter of degrading validation set perfroamcne
            es_count = 0;
            acc_drop_count = 0;
            % Set current validation accuracy performance as best
            vld_best = vld_acc;
            % Set current test accuracy performance as best
            tst_best = tst_acc;
            % Set current model as best performing model
            model_best = model;
        end
    end
    % Early stopping
    if isfield(conf,'E_STOP') 
        % Terminate upon reaching the desired accuracy
        if isfield(conf,'desire_acc') && vld_acc >= conf.desire_acc, running=0;end
        if es_count > conf.E_STOP, running=0; end
    end

    % Check stop
    if e>=conf.eNum, running=0; end
    
end
    fig1 = figure(1);
    set(fig1,'Position',[10,20,300,200]);
    plot(1:size(plot_trn_acc,2),plot_trn_acc,'r');
    hold on;
    plot(1:size(plot_vld_acc,2),plot_vld_acc);    
    legend('Training','Validation');
    xlabel('Epochs');ylabel('Accuracy');
    
    fig2 = figure(2);
    set(fig2,'Position',[10,20,300,200]);
    plot(1:size(plot_mse,2),plot_mse);    
    xlabel('Epochs');ylabel('MSE');
end





% function net = train_mp(trn_x, trn_y, mp_hidden_layers, mp_trn_func, max_epoch, flag_batching, batch_nbr)
% 
% 
% 
% 
%     disp("CONSTRUCTING Multi-layer perceptron...");
%     net = 
% 
%     disp("TRAINING Multi-layer perceptron...");
%     % Construct a feed forward neural network
%     net = fitnet(mp_hidden_layers, mp_trn_func);
% 
%     % Configure neural network
%     net.trainParam.epochs=max_epoch; % Epoch
% 
%     % If batch is used
%     if flag_batching
%         disp("Batching selected.");
%         batch_size = round(size(trn_x, 1) / batch_nbr, 0); % sample size per batch
%         fprintf("Batch size: %d Batch no.: batch_nbr %d", batch_size, batch_nbr);
%         % Set network property to batch size
%         net.trainFcn = 'trainb';
%         net.
%     else
%         disp("Batching not selected.");
%     end
%     
%     net.trainParam
% 
%     % Train network with re-sampled data
%     net = train(net, transpose(trn_x), transpose(trn_y));
%     disp(net.trainParam);
%     view(net);
% 
% end