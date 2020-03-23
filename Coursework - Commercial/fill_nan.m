function x = fill_nan(x)

    disp("REPLACING NaN WITH VARIABLE MEAN...");

    % For every column in the independent variable set
    for j = 1:size(x,2)
        % Calculate variable mean (excluding NaN)
        x_mean = mean(x(:,j), "omitnan");
        fprintf('Column: %d Mean: %d.2', j, x_mean);
        % For every row in the column
        for i = 1:size(x,1)
            if isnan(x(i, j))
                % Replace NaN with mean
                x(i,j) = x_mean;
            end
        end
    end

end