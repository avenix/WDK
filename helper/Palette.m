classdef Palette < handle
    methods (Static)
        function preprocessingComputers = PreprocessingComputers()
            preprocessingComputers = {NoOp,...
                LowPassFilter, HighPassFilter,...
                S1,S2,...
                Magnitude, MagnitudeSquared};
        end
        
        function eventDetectionComputers = EventDetectionComputers()
            eventDetectionComputers = {NoOp, SimplePeakDetector,MatlabPeakDetector};
        end
        
        function segmentationComputers = SegmentationComputers()
            segmentationComputers = {EventSegmentation, OverlappingWindowSegmentation};
        end
        
        function labelingStrategyComputers = LabelingStrategyComputers()
            labelingStrategyComputers = {EventsLabeler, EventSegmentsLabeler, RangeSegmentsLabeler};
        end
        
        function classificationComputers = ClassificationComputers()
            classificationComputers = {SVMClassifier,KNNClassifier,TreeClassifier,LDClassifier,EnsembleClassifier};
        end
        
        function otherComputers = OtherComputers()
            otherComputers = {AxisSelector};
        end
        
        function allComputers = AllComputers()
            preprocessingComputers = Palette.PreprocessingComputers();
            eventDetectionComputers = Palette.EventDetectionComputers();
            
            allComputers = [preprocessingComputers(2:end),...
                eventDetectionComputers(2:end),...
                Palette.SegmentationComputers(),...
                Palette.ClassificationComputers(),...
                Palette.OtherComputers()];
        end
    end
    
end