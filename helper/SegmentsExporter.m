%exports segments to separate files (did this for Sajjad)
classdef SegmentsExporter < handle
    properties (Constant)
        dirName = 'exportedData';
    end
    
    methods
        function obj = SegmentsExporter()
            obj.checkRemoveDirectory();
          
            segmentsLoader = AutomaticSegmentsLoader();
            
            peakDetector = SimplifiedPeakDetector();
            peakDetector.minPeakHeight = 170;
            peakDetector.minPeakDistance = 100;
            segmentationAlgorithm = PeakSegmentation(peakDetector);
            
            preprocessingAlgorithm = SignalComputer.EnergyComputer();
            segmentsLoader.preprocessingAlgorithm = preprocessingAlgorithm;
            segmentsLoader.segmentationAlgorithm = segmentationAlgorithm;
           
            segments = segmentsLoader.loadSegments();
            labelingStrategy = GroupedLabelingStrategy();
            %labelingStrategy = DefaultLabelingStrategy();
            
            segmentsGrouper = SegmentsGrouper();
            trainSegments = segments(1:end-1);
            testSegments = segments(end);
            groupedSegmentsTrain = segmentsGrouper.groupSegments(trainSegments,labelingStrategy);
            groupedSegmentsTest = segmentsGrouper.groupSegments(testSegments,labelingStrategy);
            
            obj.saveFiles(groupedSegmentsTrain,'train');
            obj.saveFiles(groupedSegmentsTest,'test');
        end
        
        function checkRemoveDirectory(obj)
            if exist(obj.dirName,'dir')
                rmdir(obj.dirName,'s');
            end
        end
        
        function saveFiles(~,groupedSegments,prefix)
            
            tableExporter = TableExporter();
            for i = 1 : length(groupedSegments)
                groupDirName = sprintf('exportedData/%s/%d',prefix,i);
                
                mkdir(groupDirName);
                segmentArray = groupedSegments{i};
                for j = 1 : length(segmentArray)
                    fileName = sprintf('%s/%d.txt',groupDirName,j);
                    
                    table = array2table(segmentArray(j).window(:,3:18));
                    table.Properties.VariableNames = {'ax','ay','az','gx','gy','gz','mx','my','mz','q0','q1','q2','lax','lay','laz','q3'};
                    tableExporter.exportTable(table,fileName);
                end
            end
        end
    end
end