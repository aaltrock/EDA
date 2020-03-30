% INITIAL ANALYSIS
% IMPORTANT: REQUIRES MATLAB R2019b TO WORK

clear();
clc();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA IMPORT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

src = readtable('src_df.xlsx');

% Get variable names
vars_nm = src.Properties.VariableNames;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPLETENESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Count frequency of NaN for each variable
count_nan = sum(isnan(table2array(src)))./size(src,1);

% Compile table
count_nan = array2table(count_nan,'VariableNames', src.Properties.VariableNames);
count_nan.Properties.RowNames = {'NaNPct'};
count_nan = rows2vars(count_nan);

% Discretize percentage of NaN into decile bins for each variable
[bins,E] = discretize(count_nan.NaNPct,10);
count_nan.Bin = bins;

% Summarise for each bin, number of variables
count_nan_grp = groupcounts(count_nan, 'Bin');
count_nan_grp = table2array(count_nan_grp);
Y = count_nan_grp(:,2);
X = count_nan_grp(:,1);

% Plot bar chart
barh(X,Y)
title('Percentage of NaN distributions across variables');
xlabel('Count of variables');
ylabel('Percentile bins: % of NaN in variable');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLASSIFICATION DISTRIBUTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Frequency table for dependent variable
tab_y = tabulate(src.y);

% Plot for 
tile = tiledlayout(10,25);


x = linspace(0,10,50);
y1 = sin(x);
y2 = rand(50,1);
tile = tiledlayout(10,25);

% Top plot
nexttile;
histogram(src.y);
title('y')

% Bottom plot
nexttile
histogram(src.x1);
title('x1')

% Bottom plot
nexttile
histogram(src.x2);
title('x2')

tile.Padding = 'none';
tile.TileSpacing = 'none';