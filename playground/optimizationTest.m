close all;

chains = createChains();
%save('chains','chains');
%chains = load('chains','chains');
%chains = chains.chains;

dataLoader = DataLoader();
annotations = dataLoader.loadAllAnnotations();
annotation = annotations(1);
labelingStrategies = dataLoader.loadAllLabelingStrategies();
labelingStrategy = labelingStrategies(3);
resultsComputer = DetectionResultsComputer();
resultsComputer.tolerance = uint32(10);
resultsComputer.labelingStrategy = labelingStrategy;
resultsComputer.positiveLabels = [ones(1,labelingStrategy.numClasses-1) 0];
labeler = EventsLabeler();
mapper = LabelMapper(labelingStrategy);
Computer.SetSharedContextVariable(Constants.kSharedVariableCurrentAnnotationFile, annotation);

nChains = length(chains);
metrics = repmat(ARCMetric,1,nChains);
for i = 1  : nChains
    chain = chains{i};
    
    [events, ~] = Computer.ExecuteChain(chain,'start',false);
    events = labeler.compute(events);
    events = mapper.compute(events);
    results = resultsComputer.computeDetectionResults({events},annotation);
    metrics(i) = ARCMetric(results.f1Score);
end

[bestF1Score,bestIdx] = max([metrics.detectionf1Score]);
fprintf('best detection f1score: %.2f\n',100 * bestF1Score);
bestChain = chains{bestIdx};

Computer.FlattenChain(bestChain);
Helper.PlotComputerGraph(bestChain);

function chains = createChains()

axisSelectors = createAxisSelectors();
preprocessingTestFixes = createPreprocessingTestFixes();
eventDetectionTestFixes = createEventDetectionTestFixes();
postpreprocessingTestFixes = createPostPreprocessingTestFixes();

preprocessingAlgorithms = createAlgorithmsWithTestFixes(preprocessingTestFixes);
eventDetectionAlgorithms = createAlgorithmsWithTestFixes(eventDetectionTestFixes);
postpreprocessingAlgorithms = createAlgorithmsWithTestFixes(postpreprocessingTestFixes);

preprocessingCombinations = generateSignalsPreprocessingCombinations(axisSelectors,preprocessingAlgorithms);
postPreprocessingCombinations = generatePostPreprocessingCombinations(preprocessingCombinations,postpreprocessingAlgorithms);

nChains = length(postPreprocessingCombinations) * length(eventDetectionAlgorithms);
chains = cell(1,nChains);

chainCount = 1;

for postpreprocessingIdx = 1 : length(postPreprocessingCombinations)
    postpreprocessingComputer = postPreprocessingCombinations(postpreprocessingIdx);
    
    for eventDetectionIdx = 1 : length(eventDetectionAlgorithms)
        eventDetectionAlgorithm = eventDetectionAlgorithms{eventDetectionIdx};
        
        fileLoader = FileLoader();
        fileLoader.fileName = '1-niklas.mat';
        propertyGetter = PropertyGetter('data');
        propertyGetter.outputPort = ComputerPort(ComputerPortType.kSignalN);
        
        fileLoader.addNextComputer(propertyGetter);
        propertyGetter.addNextComputer(postpreprocessingComputer);
        postpreprocessingComputer.addNextComputer(eventDetectionAlgorithm.copy());
                       
        chains{chainCount} = fileLoader;
        chainCount = chainCount + 1;
    end
end

end

function combinations = generateSignalsPreprocessingCombinations(axisSelectors,preprocessingAlgorithms)
nAxisSelectors = length(axisSelectors);
nPreprocessingAlgorithms = length(preprocessingAlgorithms);
combinations = repmat(AxisSelector,1,nAxisSelectors * nPreprocessingAlgorithms);

combinationCount = 1;
for i = 1 : nAxisSelectors
    for j = 1 : nPreprocessingAlgorithms
        axisSelector = axisSelectors(i).copy();
        if ~isa(preprocessingAlgorithms{j},'NoOp')
            axisSelector.addNextComputer(preprocessingAlgorithms{j}.copy());
        end
        
        combinations(combinationCount) = axisSelector;
        combinationCount = combinationCount + 1;
    end
end
end

function combinations = generatePostPreprocessingCombinations(preprocessingCombinations, postPreprocessingAlgorithms)
nPreprocessingCombinations = length(preprocessingCombinations);
nPostpreprocessingAlgorithms = length(postPreprocessingAlgorithms);

nCombinations = nchoosek(nPreprocessingCombinations,3) * nPostpreprocessingAlgorithms;

combinations = repmat(CompositeComputer,1,nCombinations);%check
combinationCount = 1;
for algorithmIdx = 1 : nPostpreprocessingAlgorithms
    postPreprocessingAlgorithm = postPreprocessingAlgorithms{algorithmIdx};
    for i = 1 : nPreprocessingCombinations-2
        for j = i+1 : nPreprocessingCombinations-1
            for k = j+1 : nPreprocessingCombinations
                
                root = NoOp();
                
                preprocessingAlgorithm1 = preprocessingCombinations(i).copy();
                preprocessingAlgorithm2 = preprocessingCombinations(j).copy();
                preprocessingAlgorithm3 = preprocessingCombinations(k).copy();
                
                root.addNextComputer(preprocessingAlgorithm1);
                root.addNextComputer(preprocessingAlgorithm2);
                root.addNextComputer(preprocessingAlgorithm3);
                
                merger = AxisMerger(3);
                preprocessingAlgorithm1.addNextComputer(merger);
                preprocessingAlgorithm2.addNextComputer(merger);
                preprocessingAlgorithm3.addNextComputer(merger);
                
                postPreprocessingAlgorithmCopy = postPreprocessingAlgorithm.copy();
                merger.addNextComputer(postPreprocessingAlgorithmCopy);
                
                combinations(combinationCount) = CompositeComputer(root,{postPreprocessingAlgorithmCopy});
                combinationCount = combinationCount + 1;
            end
        end
    end
end
end

function axisSelectors = createAxisSelectors()
%axes = 1:9;%accel, gyro, magneto
axes = 1:3;%acel
nAxes = length(axes);
axisSelectors = repmat(AxisSelector,1,nAxes);
for i = 1 : length(axes)
    axisSelectors(i) = AxisSelector(axes(i));
end
end

function preprocessingTestFixes = createPreprocessingTestFixes()

lowPassTestFix = ComputerTestFix(LowPassFilter);
lowPassTestFix.propertyTestFixes =  [PropertyTestFix('order',1,1,2), PropertyTestFix('cutoff',1,5,20)];

highPassTestFix = ComputerTestFix(HighPassFilter);
highPassTestFix.propertyTestFixes =  [PropertyTestFix('order',1,1,2), PropertyTestFix('cutoff',1,5,20)];

preprocessingTestFixes = [ComputerTestFix(NoOp), lowPassTestFix, highPassTestFix];
%preprocessingTestFixes = ComputerTestFix(NoOp);
end

function postpreprocessingTestFixes = createPostPreprocessingTestFixes()

magnitudeTestFix = ComputerTestFix(Magnitude);

postpreprocessingTestFixes = magnitudeTestFix;

end

function eventDetectionTestFixes = createEventDetectionTestFixes()
simplePeakDetectorTestFix = ComputerTestFix(SimplePeakDetector);
simplePeakDetectorTestFix.propertyTestFixes =  [PropertyTestFix('minPeakHeight',0.8,0.1,0.9), PropertyTestFix('minPeakDistance',80,20,120)];

eventDetectionTestFixes = simplePeakDetectorTestFix;
end

function algorithms = createAlgorithmsWithTestFixes(testFixes)
nAlgorithms = 0;
for i = 1 : length(testFixes)
    nAlgorithms = nAlgorithms + testFixes(i).nCombinations;
end

algorithms = cell(1,nAlgorithms);
currentCount = 1;
for i = 1 : length(testFixes)
    testFix = testFixes(i);
    combinations = testFix.generateCombinations();
    nCombinations = length(combinations);
    algorithms(currentCount:currentCount + nCombinations - 1) = combinations;
    currentCount = currentCount + nCombinations;
end
end
