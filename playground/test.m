clear Cache;

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

res = Computer.ExecuteChain(compositeComputer.root,'start',true);
disp(res);