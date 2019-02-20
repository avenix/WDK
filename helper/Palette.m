classdef Palette < handle
    methods (Static)
        function preprocessingComputers = PreprocessingComputers()
            preprocessingComputers = {NoOp(),...
                LowPassFilter(), HighPassFilter(),...
                S1(),S2(),...
                Magnitude(), MagnitudeSquared()};
        end
        
        function eventDetectionComputers = EventDetectionComputers()
            eventDetectionComputers = {NoOp(), SimplePeakDetector,MatlabPeakDetector};
        end
        
        function segmentationComputers = SegmentationComputers()
            segmentationComputers = {EventSegmentation};
        end
        
        function classificationComputers = ClassificationComputers()
            classificationComputers = {SVMClassifier,KNNClassifier,TreeClassifier,LDClassifier,EnsembleClassifier};
        end
    end
    
end