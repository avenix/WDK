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
        
        
        function featureExtractionComputers = TimeDomainFeatureExtractionComputers()
            featureExtractionComputers = {Min,Max,Mean,Median,Variance,STD,ZCR,...
                Skewness,Kurtosis,IQR,AUC,AAV,Correlation,...
                Energy,MAD,MaxCrossCorr,Octants,P2P,Quantile,RMS,SignalVectorMagnitude,SMA, Entropy};
        end
        
        function featureExtractionComputers = FrequencyDomainFeatureExtractionComputers()
            featureExtractionComputers = {FFT,FFTDC,MaxFrequency,PowerSpectrum,SpectralCentroid,SpectralEnergy,SpectralEntropy,SpectralFlatness,...
                SpectralSpread};
        end
        
        function featureExtractionComputers = FeatureExtractionComputers()
            timeDomainFeatures = Helper.TimeDomainFeatureExtractionComputers();
            frequencyDomainFeatures = Helper.FrequencyDomainFeatureExtractionComputers();
            featureExtractionComputers = [timeDomainFeatures; frequencyDomainFeatures];
        end
        
        function classificationComputers = ClassificationComputers()
            classificationComputers = {SVMClassifier,KNNClassifier,TreeClassifier,LDClassifier,EnsembleClassifier};
        end
        
        function validationComputers = ValidationComputers()
            validationComputers = {HoldOutValidator()};
        end
        
        function validationComputers = PostprocessingComputers()
            validationComputers = {LabelMapper()};
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