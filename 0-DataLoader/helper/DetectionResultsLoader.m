classdef DetectionResultsLoader < handle
    properties (Access = public)
        signalPreprocessor;
        peakDetector;
        labelingStrategy;
    end
    
    methods (Access = public)
        %returns a cell array of arrays of peaks
        function results = loadResults(obj)
            signalPreprocessorStr = obj.signalPreprocessor.toString();
            peakDetectorStr = obj.peakDetector.toString();
            fullFileName = sprintf('data/precomputed/detection_%s_%s.mat',signalPreprocessorStr,peakDetectorStr);
            if exist(fullFileName,'File') == 2
                results = load(fullFileName,'results');
                results = results.results;
            else
                fprintf('Creating %s...\n',fullFileName);
                results = obj.computeResults();
                save(fullFileName,'peaks');
            end
        end
        
    end
    
    methods (Access = private)
        function results = computeResults(obj)
            
            nFiles = length(Constants.fileFileNames);
            results = cell(1,nFiles);
            for fileIdx = 1 : nFiles
                fileName = Constants.fileFileNames{fileIdx};
                dataLoader = DataLoader(fileName);
                data = dataLoader.loadData();
                
                if ~isempty(data)
                
                    manualPeakData = dataLoader.loadPeaks();
                    if ~isempty(manualPeakData)
                                                
                        labeler = PeaksLabeler();
                        labeler.labelingStrategy = obj.labelingStrategy;
                                                                        
                        signal = obj.signalPreprocessor.compute(data);
                        results{fileIdx} = obj.peakDetector.detectPeaks(signal);
                    end
                end
            end
        end
    end
end