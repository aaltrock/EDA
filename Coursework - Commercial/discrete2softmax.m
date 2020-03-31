% Codes adapted from: Neural Computing module Tutorial 4 train_nn function
% Original from Artur S. d'Avila Garcez, Department of Computer Science,
% City, University of London

function s_m = discrete2softmax(inp,nmax)
% Convert discrete data into softmax
sNum = size(inp,1);
s_m = zeros(sNum,nmax);
s_m([1:sNum] + (inp'-1)*sNum) = 1;
end