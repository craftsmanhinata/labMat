%% Cluster Data and Plot the Result
%%
% Randomly generate the sample data with 20000 observations.

% Copyright 2015 The MathWorks, Inc.

rng default; % For reproducibility
X = rand(20000,3);
%%
% Create a hierarchical cluster tree using Ward's linkage.
Z = linkage(X,'ward','euclidean','savememory','on');
%%
% If you set |savememory| to |'off'| , you can get an out-of-memory error
% if your machine doesn't have enough memory to hold the distance matrix.
%%
% Cluster data into four groups and plot the result.
c = cluster(Z,'maxclust',4);
scatter3(X(:,1),X(:,2),X(:,3),10,c)