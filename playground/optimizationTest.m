%chains = createChains();
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
    
    [events, ~] = Computer.ExecuteChain(chain,'start',true);
    events = labeler.compute(events);
    events = mapper.compute(events);
    results = resultsComputer.computeDetectionResults({events},annotation);
    metrics(i) = ARCMetric(results.goodEventRate,results.badEventRate);
end

function chains = createChains()

axisSelectors = createAxisSelectors();
preprocessingTestFixes = createPreprocessingTestFixes();
eventDetectionTestFixes = createEventDetectionTestFixes();

preprocessingAlgorithms = createAlgorithmsWithTestFixes(preprocessingTestFixes);
eventDetectionAlgorithms = createAlgorithmsWithTestFixes(eventDetectionTestFixes);

nChains = length(axisSelectors) * length(preprocessingAlgorithms) * length(eventDetectionAlgorithms);
chains = cell(1,nChains);


chainCount = 1;

for axisIdx = 1 : length(axisSelectors)
    axisSelector = axisSelectors(axisIdx);
    
    for preprocessingIdx = 1 : length(preprocessingAlgorithms)
        preprocessingAlgorithm = preprocessingAlgorithms{preprocessingIdx};
        
        for eventDetectionIdx = 1 : length(eventDetectionAlgorithms)
            eventDetectionAlgorithm = eventDetectionAlgorithms{eventDetectionIdx};
            
            fileLoader = FileLoader();
            fileLoader.fileName = '1-niklas.mat';
            propertyGetter = PropertyGetter('data');
            propertyGetter.outputPort = ComputerPort(ComputerPortType.kSignalN);
            
            arcChain = CompositeComputer();
            arcChain.addComputer(fileLoader);
            arcChain.addComputer(propertyGetter);
            arcChain.addComputer(axisSelector.copy());
            arcChain.addComputer(preprocessingAlgorithm.copy());
            arcChain.addComputer(eventDetectionAlgorithm.copy());
            
            chains{chainCount} = arcChain;
            chainCount = chainCount + 1;
        end
    end
end

end

function axisSelectors = createAxisSelectors()
axes = [3:11,15,16,17];
nAxes = length(axes);
axisSelectors = repmat(AxisSelector,1,nAxes);
for i = 1 : length(axes)
    axisSelectors(i) = AxisSelector(axes(i));
end
end

function preprocessingTestFixes = createPreprocessingTestFixes()
lowPassTestFix = ComputerTestFix(LowPassFilter);
lowPassTestFix.propertyTestFixes =  [PropertyTestFix('order',1,1,4), PropertyTestFix('cutoff',1,5,20)];

highPassTestFix = ComputerTestFix(HighPassFilter);
highPassTestFix.propertyTestFixes =  [PropertyTestFix('order',1,1,4), PropertyTestFix('cutoff',1,5,20)];

preprocessingTestFixes = [lowPassTestFix,highPassTestFix];
end

function eventDetectionTestFixes = createEventDetectionTestFixes()
simplePeakDetectorTestFix = ComputerTestFix(SimplePeakDetector);
simplePeakDetectorTestFix.propertyTestFixes =  [PropertyTestFix('minPeakHeight',80,20,180), PropertyTestFix('minPeakDistance',80,20,200)];

eventDetectionTestFixes = [simplePeakDetectorTestFix];
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
