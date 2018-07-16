%% Compare Cluster Assignments to Clusters
%%
% Load the sample data.

% Copyright 2015 The MathWorks, Inc.

load fisheriris
%%
% Compute four clusters of the Fisher iris data using Ward linkage and
% ignoring species information.
Z = linkage(meas,'ward','euclidean');
c = cluster(Z,'maxclust',4);
%%
% See how the cluster assignments correspond to the three species.
crosstab(c,species)
%%
% Display the first five rows of Z.
firstfive = Z(1:5,:)
%%
% Create a dendrogram plot of |Z| .
dendrogram(Z)

