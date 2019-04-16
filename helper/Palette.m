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
            segmentationComputers = {EventSegmentation, SlidingWindowSegmentation};
        end
        
        function labelingStrategyComputers = LabelingStrategyComputers()
            labelingStrategyComputers = {EventsLabeler, EventSegmentsLabeler, RangeSegmentsLabeler};
        end
        
        
        function featureExtractionComputers = StatisticalFeatureExtractionComputers()
            featureExtractionComputers = {Min,Max,Mean,Median,Variance,STD,ZCR,...
                SquaredMagnitudeSum,Skewness,Kurtosis,IQR,AUC};
        end
        
        function featureExtractionComputers = FourierFeatureExtractionComputers()
            featureExtractionComputers = {FFTDC,MaxFrequency,SpectralCentroid,SpectralEnergy,SpectralEntropy,SpectralFlatness,...
                SpectralSpread,SquaredMagnitudeSum};
        end
        
        function featureExtractionComputers = FeatureExtractionComputers()
            featureExtractionComputers = {AAV, AUC, Entropy, FFTDC, IQR, Kurtosis,...
                MAD,Max,MaxCrossCorr,MaxFrequency,Mean,Median,Min,Octants,...
                P2P,PowerSpectrum,Quantile,RMS,SignalVectorMagnitude, Skewness,...
                SpectralCentroid,SpectralEnergy,SpectralEntropy,SpectralFlatness,...
                SpectralSpread,SquaredMagnitudeSum,STD,Variance,ZCR};
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