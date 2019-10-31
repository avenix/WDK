classdef Palette < handle
    methods (Static)
        function preprocessingComputers = PreprocessingComputers()
            preprocessingComputers = {NoOp,...
                LowPassFilter, HighPassFilter,...
                Derivative,S1,S2,...
                Norm,Magnitude, MagnitudeSquared,Resampler};
        end
        
        function eventDetectionComputers = EventDetectionComputers()
            eventDetectionComputers = {NoOp, SimplePeakDetector,MatlabPeakDetector};
        end
        
        function segmentationComputers = SegmentationComputers()
            segmentationComputers = {NoOp,EventSegmentation, SlidingWindowSegmentation};
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
        
        function postprocessingComputers = PostprocessingComputers()
            postprocessingComputers = {NoOp, LabelMapper(), LabelSlidingWindowMaxSelector()};
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
        
        %returns the algorithms that take a specific input type
        function algorithms = AlgorithmsWithInputType(inputType)
            allAlgorithms = Palette.AllComputers();
            
            algorithms = Palette.FilterAlgorithmsToInputType(allAlgorithms,inputType);
        end
        
        %filters an array of algorithms to those algorithms that take a
        %specific input type
        function outputAlgorithms = FilterAlgorithmsToInputType(algorithms,inputType)
            nOutputAlgorithms = Palette.CountNumComputersForInputType(algorithms,inputType);
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
        function nAlgorithms = CountNumComputersForInputType(algorithms,inputType)
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