close all;

%% History component for classification
% overview of training, counting amount of instances detected
% Application: monitoring in sports, health or animals
historyComponent = HistoryComponent();
historyComponent.yLabel = 'Exercise';
classificationResult = ClassificationResult();
classificationResult.predictedClasses = [ones(1,floor(rand(1,1)*30)), zeros(1,floor(rand(1,1)*30)),ones(1,floor(rand(1,1)*30))*2,ones(1,floor(rand(1,1)*30))*3,ones(1,floor(rand(1,1)*30))*4];
n = length(classificationResult.predictedClasses);
classificationResult.table.timestamps = (1:n) * 30;
classificationResult.table.classNames = {'resting leg flex','resting leg to side','standing leg flex','standing leg to side','standing up and down'};
historyComponent.plotTitle = 'Training History';
historyComponent.plotHistory(classificationResult);

stylize();

%% History component for classification 2
% monitoring behavior / health condition over time
% Application: monitoring in sports, health or animals
historyComponent = HistoryComponent();
historyComponent.xLabel = 'Time (days)';
historyComponent.yLabel = 'Stride Classification';
classificationResult = ClassificationResult();

n = 50;
classificationResult.predictedClasses = [(rand(1,n) > 0.8), (rand(1,n) < 0.9)];

n = length(classificationResult.predictedClasses);
classificationResult.table.timestamps = (1:n);
classificationResult.table.classNames = {'normal','abnormal'};
historyComponent.plotTitle = 'Cow Stride Classification';
historyComponent.plotHistory(classificationResult);

stylize();

%% History component for regression
% typical performance improvement over time
% Applications: sports, rehabilitation
historyComponent = HistoryComponent();
historyComponent.plotTitle = 'Performance History';
historyComponent.yLabel = 'Performance';
n = 92;
regressionResult = ((1:n)/10).^2 + rand(1,n)*12;
regressionResult(50) = 16;
regressionResult(70) = 26;
regressionResults = RegressionResult(regressionResult);
historyComponent.plotHistory(regressionResults);

stylize();

%% Comparisson component
% comparison with respect to space
% Application: medical. Compare with healthy side
comparisonComponent = ComparisonComponent(1);
comparisonComponent.labels = categorical({'Left Leg','Right Leg'});
comparisonComponent.plotTitle = 'Performance Comparison';
comparisonComponent.yLabel = 'Range of Motion';
regressionResults = RegressionResult([78 100]);
comparisonComponent.compare(regressionResults);

stylize();

%% Comparisson component 2
% comparison with respect to space
% Application: sports / gamification. Compare with other users
comparisonComponent = ComparisonComponent(4);
comparisonComponent.labels = categorical({'Player1','Player2','Player3','You','Player4','Oliver Kahn'});
comparisonComponent.labels = reordercats(comparisonComponent.labels,{'Player1','Player2','Player3','You','Player4','Oliver Kahn'});

comparisonComponent.plotTitle = 'Performance Comparison';
comparisonComponent.yLabel = 'Throw intensity';
regressionResults = RegressionResult([64,70,74,85,95,100]);
comparisonComponent.compare(regressionResults);

stylize();

%% Time-Space component for classification
% monitoring performance over time
timeSpaceComponent = TimeSpaceComponent();
timeSpaceComponent.labels = {'Cow 178','Cow 126'};
timeSpaceComponent.plotTitle = 'Cow Gait Comparison';
timeSpaceComponent.yLabel = '';

n = 100;
classificationResult1 = ClassificationResult();
classificationResult1.predictedClasses = (rand(1,n) > 0.8);
classificationResult1.table.timestamps = 1:length(classificationResult1.predictedClasses);
classificationResult1.table.classNames = {'normal','lame'};

classificationResult2 = ClassificationResult();
classificationResult2.predictedClasses = (rand(1,n) > 0.2);
classificationResult2.table.timestamps = 1:length(classificationResult2.predictedClasses);
classificationResult2.table.classNames = {'normal','lame'};

timeSpaceComponent.plotComparison({classificationResult1,classificationResult2});

stylize();

%% Time-Space component for regression
%recovery / improvement over time
timeSpaceComponent = TimeSpaceComponent();
timeSpaceComponent.labels = {'Healthy Leg','Injured Leg'};
timeSpaceComponent.plotTitle = 'Rehabilitation Comparison';
timeSpaceComponent.yLabel = 'Performance';

n = 100;
regressionResults1 = ((1:n))/5+85 + rand(1,n)*5 + 30;
regressionResult1 = RegressionResult(regressionResults1);
regressionResults2 = tanh(-3:5/(n-1):2)*115 + rand(1,n)*5 + 10; 
regressionResult2 = RegressionResult(regressionResults2);

timeSpaceComponent.plotComparison({regressionResult1,regressionResult2});

stylize();

%% Achievements Component detect class
% Use case1: notify when the user started jogging

achievement = Achievement('==',categorical({'jogging'}));
achievementsComponent = AchievementsComponent(achievement);
achievementsComponent.addObserver(@joggingDetectedCallback);

classificationResult = ClassificationResult();
%classificationResult.predictedClasses = categorical({'walking','sitting','sitting','sitting','sitting','sitting','walking','walking','jogging'});
classificationResult.predictedClasses = categorical({'walking','sitting','sitting','sitting','sitting','sitting','walking','walking'});
achievementsComponent.compute(classificationResult);

%% Achievements Component compare value
% Use case2: A certain degree of flexion has been reached

achievement = Achievement('>',90);
achievementsComponent = AchievementsComponent(achievement);
achievementsComponent.notifyOnce = true;
achievementsComponent.addObserver(@rangeOfMotionCallback);

regressionResult = RegressionResult();
%regressionResult.predictedResults = [18,30,35,34,65,35,75,78,78];
regressionResult.predictedResults = [18,30,35,34,65,35,75,78,78,92,100];
achievementsComponent.compute(regressionResult);


%% helper functions
function joggingDetectedCallback(~)
fprintf('the user started jogging!\n');
end

function rangeOfMotionCallback(~)
fprintf('range of motion >= 90 degrees goal achieved!\n');
end

function stylize()

set(gca,'FontSize',22);

end