% Read the source data
incident_src = readtable('incident_event_log.csv');



% Create new feature - duration - as target
incident_src_independent = incident_src.opened_at - incident_src.resolved_at;
incident_src_independent = hours(incident_src_independent);
incident_src_independent = normalize(incident_src_independent);

% Get column names
% col_names = incident_src.Properties.VariableNames;

% {'number','incident_state','active','reassignment_count','reopen_count','sys_mod_count','made_sla','caller_id','opened_by','opened_at','sys_created_by','sys_created_at','sys_updated_by','sys_updated_at','contact_type','location','category','subcategory','u_symptom','cmdb_ci','impact','urgency','priority','assignment_group','assigned_to','knowledge','u_priority_confirmation','notify','problem_id','rfc','vendor','caused_by','closed_code','resolved_by','resolved_at','closed_at'}

% Create training sets, exclude identifiers, assignees
incident_src_dependent = incident_src(:, {'active', 'reassignment_count', 'made_sla', 'caller_id','opened_by', 'opened_at', 'sys_created_by', 'sys_created_at', 'sys_updated_by', 'sys_updated_at', 'contact_type', 'location', 'category', 'subcategory', 'u_symptom', 'cmdb_ci','impact','urgency','priority','assignment_group','assigned_to','knowledge','u_priority_confirmation'});
% incident_src_dependent = table2array(incident_src_dependent);

% incident_src_dependent.active = cat_to_ordinal(incident_src_dependent.active);

incident_src_dependent_factors = zeros(size(incident_src_dependent));
col_n = size(incident_src_dependent);
col_n = col_n(2);
for i = 1:col_n
    series = incident_src_dependent{:,i};
    disp(class(series));
    disp(i);
    if class(series) == "double"
        newSeries = series;
    elseif class(series) == "datetime"
        series = string(datenum(series));
        series = fill_missing(series, "NA");
        newSeries = series;
        keySet = unique(newSeries);
        valSet = 1:size(keySet);
        seriesMap = containers.Map(keySet, valSet);
        newSeries = zeros(size(series));
        for j = 1:size(series)
            newSeries(j) = seriesMap(series(j));
        end
    else
        keySet = unique(series);
        valSet = 1:size(keySet);
        seriesMap = containers.Map(keySet, valSet);
        newSeries = zeros(size(series));
        for j = 1:size(series)
            newSeries(j) = seriesMap(series{j});
        end
    end
    incident_src_dependent_factors(:,i) = newSeries;
end

% Normalise data
for i = 1:col_n
    incident_src_dependent_factors(:,i) = normalize(incident_src_dependent_factors(:,i));
end

% Replace missing value for a given value
function newSeries = fill_missing(series, noneValue)
    newSeries = series;
    for i = 1:size(series)
        if ismissing(series(i))
            newSeries(i) = noneValue;
        else
            newSeries(i) = series(i);
        end
    end
end
