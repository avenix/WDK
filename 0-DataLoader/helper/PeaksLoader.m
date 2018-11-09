classdef PeaksLoader < handle
    properties (Access = public)
        signalPreprocessor;
        peakDetector;
    end

    methods (Access = public)
        %returns a cell array of arrays of peaks
        function peaks = loadPeaks(obj)
            signalPreprocessorStr = obj.signalPreprocessor.toString();
            peakDetectorStr = obj.peakDetector.toString();
            fullFileName = sprintf('data/precomputed/peaks%s_%s.mat',signalPreprocessorStr,peakDetectorStr);
            if exist(fullFileName,'File') == 2
                peaks = load(fullFileName,'peaks');
                peaks = peaks.peaks;
            else
                fprintf('Creating %s...\n',fullFileName);
                peaks = obj.detectPeaks();
                save(fullFileName,'peaks');
            end
        end

        function str = toString(obj)
            signalPreprocessorStr = obj.signalPreprocessor.toString();
            peakDetectorStr = obj.peakDetector.toString();
            str = sprintf('%s_%s',signalPreprocessorStr,peakDetectorStr);
        end
    end
    
    methods (Access = private)
        function peaks = detectPeaks(obj)
            dataFiles = Helper.listDataFiles();
            nFiles = length(dataFiles);
            peaks = cell(1,nFiles);
            dataLoader = DataLoader();
            
            for fileIdx = 1 : nFiles
                fileName = dataFiles{fileIdx};
                data = dataLoader.loadData(fileName);
                
                if ~isempty(data)
                    signal = obj.signalPreprocessor.compute(data);
                    peaks{fileIdx} = obj.peakDetector.detectPeaks(signal);
                end
            end
        end
    end
end