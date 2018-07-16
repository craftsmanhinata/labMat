%% Find Multiple Class Boundaries Using Binary SVM
%%
% Load Fisher's iris data set. Use the petal lengths and widths.

% Copyright 2015 The MathWorks, Inc.

load fisheriris
X = meas(:,3:4);
Y = species;
%%
% Examine a scatter plot of the data.
figure
gscatter(X(:,1),X(:,2),Y);
h = gca;
lims = [h.XLim h.YLim]; % Extract the x and y axis limits
title('{\bf Scatter Diagram of Iris Measurements}');
xlabel('Petal Length (cm)');
ylabel('Petal Width (cm)');
legend('Location','Northwest');

%%
% There are three classes, one of which is linearly separable from the
% others.
%%
% For each class:
%
% # Create a logical vector (|indx|) indicating whether an observation is
% a member of the class.
% # Train an SVM classifier using the predictor data and |indx|.
% # Store the classifier in a cell of a cell array. 
%
% It is good practice to define the class order.
SVMModels = cell(3,1);
classes = unique(Y);
rng(1); % For reproducibility

for j = 1:numel(classes);
    indx = strcmp(Y,classes(j)); % Create binary classes for each classifier
    SVMModels{j} = fitcsvm(X,indx,'ClassNames',[false true],'Standardize',true,...
        'KernelFunction','rbf','BoxConstraint',1);
end
%%
% |SVMModels| is a 3-by-1 cell array, with each cell containing a
% |ClassificationSVM| classifier.  For each cell, the positive class is
% setosa, versicolor, and virginica, respectively.
%%
% Define a fine grid within the plot, and treat the coordinates as new observations
% from the distribution of the training data.  Estimate the score of the new
% observations using each classifier.
d = 0.02;
[x1Grid,x2Grid] = meshgrid(min(X(:,1)):d:max(X(:,1)),...
    min(X(:,2)):d:max(X(:,2)));
xGrid = [x1Grid(:),x2Grid(:)];
N = size(xGrid,1);
Scores = zeros(N,numel(classes));

for j = 1:numel(classes);
    [~,score] = predict(SVMModels{j},xGrid);
    Scores(:,j) = score(:,2); % Second column contains positive-class scores
end
%%
% Each row of |Scores| contains three scores.  The index of the element
% with the largest score is the index of the class to which the new class
% observation most likely belongs.
%%
% Associate each new observation with the classifier that gives it the
% maximum score.  
[~,maxScore] = max(Scores,[],2);
%%
% Color in the regions of the plot based on which class the
% corresponding new observation belongs.

figure
h(1:3) = gscatter(xGrid(:,1),xGrid(:,2),maxScore,...
    [0.1 0.5 0.5; 0.5 0.1 0.5; 0.5 0.5 0.1]);
hold on
h(4:6) = gscatter(X(:,1),X(:,2),Y);
title('{\bf Iris Classification Regions}');
xlabel('Petal Length (cm)');
ylabel('Petal Width (cm)');
legend(h,{'setosa region','versicolor region','virginica region',...
    'observed setosa','observed versicolor','observed virginica'},...
    'Location','Northwest');
axis tight
hold off
