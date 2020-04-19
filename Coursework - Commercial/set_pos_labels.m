% Function to replace negative class label -1 to 0
function new_y = set_pos_labels(y)
    new_y = y;
    for i = 1:size(new_y,1)
        if new_y(i) == -1
            new_y(i) = 0;
        end
    end
end