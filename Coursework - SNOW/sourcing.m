% Read the source data
incident_src = readtable('new_state_src_subset_timestamp_factors_df.xlsx');

% Convert to matrix
incident_m = table2array(incident_src);

% Normalise data
col_n = size(incident_m);
col_n = col_n(2);
for i = 1:col_n
    incident_m(:,i) = normalize(incident_m(:,i));
end

% Split the data sets into dependent and independent variables
incident_m_x = incident_m(:, 2:end-1);
incident_m_y = incident_m(:, end);

