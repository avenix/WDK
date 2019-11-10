classdef Palette < handle
    methods (Static)
        function preprocessingAlgorithms = PreprocessingAlgorithms()
            preprocessingAlgorithms = {NoOp,...
                LowPassFilter, HighPassFilter,...
                Derivative,S1,S2,...
                Norm,Magnitude, MagnitudeSquared,Resampler};
        end
        
        function eventDetectionAlgorithms = EventDetectionAlgorithms()
            eventDetectionAlgorithms = {NoOp, SimplePeakDetector,MatlabPeakDetector};
        end
        
        function segmentationAlgorithms = SegmentationAlgorithms()
            segmentationAlgorithms = {NoOp,EventSegmentation, SlidingWindowSegmentation};
        end
        
        function labelingStrategyAlgorithms = LabelingStrategyAlgorithms()
            labelingStrategyAlgorithms = {EventsLabeler, EventSegmentsLabeler, RangeSegmentsLabeler};
        end
        
        
        function featureExtractionAlgorithms = TimeDomainFeatureExtractionAlgorithms()
            featureExtractionAlgorithms = {Min,Max,Mean,Median,Variance,STD,ZCR,...
                Skewness,Kurtosis,IQR,AUC,AAV,Correlation,...
                Energy,MAD,MaxCrossCorr,Octants,P2P,Quantile,RMS,SignalVectorMagnitude,SMA, Entropy};
        end
        
        function featureExtractionAlgorithms = FrequencyDomainFeatureExtractionAlgorithms()
            featureExtractionAlgorithms = {FFT,FFTDC,MaxFrequency,PowerSpectrum,SpectralCentroid,SpectralEnergy,SpectralEntropy,SpectralFlatness,...
                SpectralSpread};
        end
        
        function featureExtractionAlgorithms = FeatureExtractionAlgorithms()
            timeDomainFeatures = Helper.TimeDomainFeatureExtractionAlgorithms();
            frequencyDomainFeatures = Helper.FrequencyDomainFeatureExtractionAlgorithms();
            featureExtractionAlgorithms = [timeDomainFeatures; frequencyDomainFeatures];
        end
        
        function classificationAlgorithms = ClassificationAlgorithms()
            classificationAlgorithms = {SVMClassifier,KNNClassifier,TreeClassifier,LDClassifier,EnsembleClassifier};
        end
        
        function validationAlgorithms = ValidationAlgorithms()
            validationAlgorithms = {HoldOutValidator()};
        end
        
        function postprocessingAlgorithms = PostprocessingAlgorithms()
            postprocessingAlgorithms = {NoOp, LabelMapper(), LabelSlidingWindowMaxSelector()};
        end
        
        function otherAlgorithms = OtherAlgorithms()
            otherAlgorithms = {AxisSelector};
        end
        
        function allAlgorithms = AllAlgorithms()
            preprocessingAlgorithms = Palette.PreprocessingAlgorithms();
            eventDetectionAlgorithms = Palette.EventDetectionAlgorithms();
            
            allAlgorithms = [preprocessingAlgorithms(2:end),...
                eventDetectionAlgorithms(2:end),...
                Palette.SegmentationAlgorithms(),...
                Palette.ClassificationAlgorithms(),...
                Palette.OtherAlgorithms()];
        end
        
        %returns the algorithms that take a specific input type
        function algorithms = AlgorithmsWithInputType(inputType)
            allAlgorithms = Palette.AllAlgorithms();
            
            algorithms = Palette.FilterAlgorithmsToInputType(allAlgorithms,inputType);
        end
        
        %filters an array of algorithms to those algorithms that take a
        %specific input type
        function outputAlgorithms = FilterAlgorithmsToInputType(algorithms,inputType)
            nOutputAlgorithms = Palette.CountNumAlgorithmsForInputType(algorithms,inputType);
            outputAlgorithms = cell(1,nOutputAlgorithms);
            algorithmCount = 0;
            for i = 1 : length(algorithms)
                algorithm = algorithms{i};
                if algorithm.inputPort == DataType.kAny || ...
                        algorithm.inputPort == inputType || ...
                        inputType == DataType.kAny
                    
                    algorithmCount = algorithmCount + 1;
                    outputAlgorithms{algorithmCount} = algorithm;
                end
            end
        end
    end
    
    methods (Static, Access = private)
        function nAlgorithms = CountNumAlgorithmsForInputType(algorithms,inputType)
            nAlgorithms = 0;
            for i = 1 : length(algorithms)
                algorithm = algorithms{i};
                if algorithm.inputPort == DataType.kAny || algorithm.inputPort == inputType
                    nAlgorithms = nAlgorithms + 1;
                end
            end
        end
    end
end