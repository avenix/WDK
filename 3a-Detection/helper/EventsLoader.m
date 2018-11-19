classdef EventsLoader < handle
    properties (Access = public)
        preprocessedSignalsLoader;
        eventDetector;
    end

    methods (Access = public)
        %returns a cell array of arrays of peaks
        function events = loadOrCreateEvents(obj)
            signalPreprocessorStr = obj.preprocessedSignalsLoader.preprocessor.toString();
            peakDetectorStr = obj.eventDetector.toString();
            fullFileName = sprintf('%s/3a-events%s_%s.mat',Constants.precomputedPath,signalPreprocessorStr,peakDetectorStr);
            if exist(fullFileName,'File') == 2
                events = load(fullFileName,'events');
                events = events.events;
            else
                fprintf('Creating %s...\n',fullFileName);
                data = obj.preprocessedSignalsLoader.loadOrCreateData();
                events = obj.detectEvents(data);
                save(fullFileName,'events');
            end
        end
        
        function savePeaks(obj,peaksArray, fileName)
            
            fileID = fopen(fileName,'w');
            
            for i = 1 : length(peaksArray)-1
                peak = peaksArray(i);
                obj.printPeakToFile(fileID,peak);
                fprintf(fileID, '\n');
            end
            peak = peaksArray(end);
            obj.printPeakToFile(fileID,peak);
            fclose(fileID);
        end
    end
    
    methods (Access = private)
        
        function printPeakToFile(~,fileID, peak)
            fprintf(fileID, '%d',peak);
        end
        
        function events = detectEvents(obj, dataFiles)
            nFiles = length(dataFiles);
            events = cell(1,nFiles);
                        
            for i = 1 : nFiles
                data = dataFiles{i};
                if ~isempty(data)
                    events{i} = obj.eventDetector.detectEvents(data);
                end
            end
        end
    end
end



