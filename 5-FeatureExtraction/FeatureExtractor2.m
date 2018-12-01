  classdef FeatureExtractor2 < handle

    properties (Access = public)
        kSignalNames = {'lax','lay','laz','GravX','GravY','GravZ','MA'};
    end
    
    properties (Access = public)
        signalComputer;
        featureComputers;
    end
    
    methods (Access = public)
        
        function obj = FeatureExtractor2(signalComputer,featureComputers)
            if nargin > 0
                obj.signalComputer = signalComputer;
                obj.featureComputers = featureComputers;
            end
        end
        
        function featureVector = extractFeaturesForSegment(obj,segment)
            data = segment.window;
            if ~isempty(obj.signalComputer)
                data = obj.signalComputer.compute(data);
            end
            featureVector = obj.extractFeaturesForData(data);
        end
        
        function nFeatures = getNFeatures(obj)
            nFeatures = length(obj.featureComputers);
        end
        
        function featureNames = getFeatureNames(obj)
            nFeatures = obj.getNFeatures();
            featureNames = cell(1,nFeatures);
            for i = 1 : nFeatures
                featureComputer = obj.featureComputers(i);
                featureNames{i} = featureComputer.toString();
            end
        end
    end
    
    methods (Access = private)
        
        function featureVector = extractFeaturesForData(obj,data)
            nFeatures = obj.getNFeatures();
            featureVector = zeros(1,nFeatures);
            for i = 1 : length(obj.featureComputers)
                featureComputer = obj.featureComputers(i);
                feature = featureComputer.compute(data);
                featureVector(i) = feature;
            end
        end
    end
    
    methods (Static)
        function featureComputers = createDefaultFeatureExtractors()
            signalComputers = FeatureExtractor2.createDefaultFeatureExtractionComputers();
            
            nSignalComputers = length(signalComputers);
            
            kDefaultNumSignals = 6;
            kDefaultSegmentSize = 451;
            
            kMiddlePartStart = 200;
            kMiddlePartEnd = 350;
            
            kDefaultRange = FeatureRange(1,kDefaultSegmentSize);
            
            segmentRanges = [FeatureRange(1,kMiddlePartStart-1),...
                FeatureRange(kMiddlePartStart,kMiddlePartEnd),...
                FeatureRange(kMiddlePartEnd+1,kDefaultSegmentSize)];
            
            nSegmentRanges = length(segmentRanges);
            
            nFeatureComputers = nSignalComputers * kDefaultNumSignals * nSegmentRanges;
            featureComputers = repmat(FeatureComputer,1,nFeatureComputers);
            featureExtractorCounter = 0;
            
            for currentSignalComputer = 1 : nSignalComputers
                
                signalComputer = signalComputers(currentSignalComputer);
                
                for currentSignal = 1 : kDefaultNumSignals
                    
                    for currentRange = 1 : nSegmentRanges
                        
                        featureComputer = FeatureComputer(signalComputer);
                        featureComputer.signalAxis = currentSignal;
                        range = segmentRanges(currentRange);
                        
                        featureComputer.range = range;
                        
                        featureExtractorCounter = featureExtractorCounter + 1;
                        featureComputers(featureExtractorCounter) = featureComputer;
                    end
                end
            end
            
            %quantile
            quantileComputer = QuantileComputer(4);

            for currentSignal = 1 : kDefaultNumSignals
                featureComputer = FeatureComputer(quantileComputer,currentSignal,kDefaultRange);
                featureExtractorCounter = featureExtractorCounter + 1;
                featureComputers(featureExtractorCounter) = featureComputer;
            end
            
            %zrc
            zeroCrossingComputer = SignalComputer(@zrc,"zrc");
            for currentSignal = 1 : kDefaultNumSignals-1
                
                for currentRange = 1 : nSegmentRanges
                    range = segmentRanges(currentRange);
                    featureComputer = FeatureComputer(zeroCrossingComputer,currentSignal,range);
                    featureExtractorCounter = featureExtractorCounter + 1;
                    featureComputers(featureExtractorCounter) = featureComputer;
                end
            end
            
            %sma acceleration
            smaComputer = SignalComputer(@sma,'sma');
            featureComputer = FeatureComputer(smaComputer);
            featureComputer.signalAxis = 1:3;
            featureComputer.range = kDefaultRange;
            featureExtractorCounter = featureExtractorCounter + 1;
            featureComputers(featureExtractorCounter) = featureComputer;
            
            %energy
            energyAxes = [1,2,3,7];
            energyComputer = SignalComputer(@energy,"energy");
            for currentSignal = 1 : length(energyAxes)
                featureComputer = FeatureComputer(energyComputer);
                featureComputer.signalAxis = energyAxes(currentSignal);
                featureExtractorCounter = featureExtractorCounter + 1;
                featureComputers(featureExtractorCounter) = featureComputer;
            end

        end
        
        function signalComputers = createDefaultFeatureExtractionComputers()
            
            featureExtractorHandles = {@min,@max,@mean,@var,@std,@median,@trapz,@aav,...
                @mad,@iqr,@rms,@mySkewness,@myKurtosis};
            
            nFeatureExtractorHandles = length(featureExtractorHandles);
            
            signalComputers = repmat(SignalComputer(),1,nFeatureExtractorHandles);
            
            for i = 1 : nFeatureExtractorHandles
                featureExtractorHandle = featureExtractorHandles{i};
                featureHandleStr = func2str(featureExtractorHandle);
                signalComputers(i) = SignalComputer(featureHandleStr,featureExtractorHandle);
            end
        end
        
        function signalComputer = createDefaultSignalComputer()
            laxSelector = AxisSelectorComputer(15);
            laySelector = AxisSelectorComputer(16);
            lazSelector = AxisSelectorComputer(17);
            
            axSelector = AxisSelectorComputer(3);
            aySelector = AxisSelectorComputer(4);
            azSelector = AxisSelectorComputer(5);
            
            multiplier = ConstantMultiplicationComputer(0.1);
            
            scaledAxComputer = SequentialComputer({axSelector,multiplier});
            scaledAyComputer = SequentialComputer({aySelector,multiplier});
            scaledAzComputer = SequentialComputer({azSelector,multiplier});
            
            gravxSelector = SimultaneousComputer({scaledAxComputer,laxSelector});
            gravySelector = SimultaneousComputer({scaledAyComputer,laySelector});
            gravzSelector = SimultaneousComputer({scaledAzComputer,lazSelector});
            
            subtraction = SignalComputer.SubtractionComputer();
            
            gravxComputer = SequentialComputer({gravxSelector,subtraction});
            gravyComputer = SequentialComputer({gravySelector,subtraction});
            gravzComputer = SequentialComputer({gravzSelector,subtraction});
            
            signalComputer = SimultaneousComputer({laxSelector,laySelector,lazSelector,gravxComputer,gravyComputer,gravzComputer});
        end 
    end
  end
  