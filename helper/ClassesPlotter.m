classdef ClassesPlotter < handle
    properties
        colors = {[1 0 0]; [0 0 1]; [1 1 0]; ...
            [1 0 1]; [0.5 0 0.5]; [0 1 0];...
            [0.5 0 1]; [0 0.5 0]; [0 0.5 0.5];...
            [0,0,0];[0,0,0];[0,0,0]...
            };
    end
    
    methods (Access = public)
        function obj = ClassesPlotter()
            manualSegmentsLoader = ManualSegmentsLoader();
            segments = manualSegmentsLoader.loadSegments();
            
            segmentsGrouper = SegmentsGrouper();
            labelingStrategy = DefaultLabelingStrategy();
            groupedSegments = segmentsGrouper.groupSegments(segments,labelingStrategy);
            
            close all;
            obj.showSegments(groupedSegments,labelingStrategy.classNames);
        end
        
        function showSegments(~,groupedSegments,classNames)
            plotter = Plotter();
            %1 is ts!
            signalAxis = 4;
            for class = 1 : length(groupedSegments)
            %for class = 1 : 2
                segments = groupedSegments{class};
                plotter.plotSegmentArray(segments,signalAxis,classNames{class});
                ax = gca;
                ax.YAxis.Exponent = 4;
                
            %axis([1,200,-5000,10000]);
            end
        end
                
    end
end