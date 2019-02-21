clear Cache;
%{
dataLoader = DataLoader();
labelingStrategies = dataLoader.loadAllLabelingStrategies();
annotations = dataLoader.loadAllAnnotations();
compositeComputer = CompositeComputer();
fileLoader = FileLoader();
compositeComputer.addComputer(fileLoader);
fileLoader.fileName = '1-niklas.mat';
manualSegmentation = ManualSegmentation(annotations);
manualSegmentation.includeRanges = false;
compositeComputer.addComputer(manualSegmentation);

mapper = LabelMapper(labelingStrategies(3));
compositeComputer.addComputer(mapper);

featureExtractor = dataLoader.LoadComputer('goalplayFeatures2.mat');
compositeComputer.addComputer(featureExtractor);
%}

compositeComputer = CompositeComputer();
compositeComputer.addComputer(Magnitude());
compositeComputer.addComputer(SimplePeakDetector());

[res,metrics] = Computer.ExecuteChain(compositeComputer.root,[1 2 3;4 5 6; 7 8 9],true);
disp(res);
%disp(metrics);