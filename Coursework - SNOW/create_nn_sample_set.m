% Function to create a set of dependent or independent variables
% from sample selecton index
function m = create_nn_sample_set(sample_idx, src_data)
    m = [];
    % For every index selected as sample
    for i = 1:size(sample_idx, 1)
        % Add row selected by index to the table
        m = [m; src_data(sample_idx(i), :)];
    end
end