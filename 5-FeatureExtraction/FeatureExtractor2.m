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
                
                FeatureExtractor2.createDefaultFeatureExtractionComputers();
                
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
            nFeatures = 0;
            
            for i = 1 : length(obj.featureComputers)
                featureComputer = obj.featureComputers(i);
                nFeatures = nFeatures + featureComputer.getNFeatures();
            end
        end
        
        function featureNames = getFeatureNames(obj)
            nFeatures = obj.getNFeatures();
            featureNames = cell(1,nFeatures);
            featureCounter = 0;
            for i = 1 : length(obj.featureComputers)
                featureComputer = obj.featureComputers(i);
                str = featureComputer.toString();
                nSubFeatures = featureComputer.getNFeatures();
                if nSubFeatures == 1
                    featureNames{featureCounter + 1} = str;
                else
                    for j = 1 : nSubFeatures
                        featureNames{featureCounter + j} = sprintf('%s_%d',str,j);
                    end
                end
                featureCounter = featureCounter + nSubFeatures;
            end
        end
    end
    
    methods (Access = private)
        
        function featureVector = extractFeaturesForData(obj,data)
            nFeatures = obj.getNFeatures();
            featureVector = zeros(1,nFeatures);
            featureCounter = 1;
            for i = 1 : length(obj.featureComputers)
                featureComputer = obj.featureComputers(i);
                features = featureComputer.compute(data);
                nSubFeatures = length(features);
                featureVector(featureCounter:featureCounter + nSubFeatures-1) = features;
                featureCounter = featureCounter + nSubFeatures;
            end
        end
    end
    
    methods (Static)
        function featureExtractors = createDefaultFeatureExtractors()
            
            kDefaultNumSignals = 7;
            kDefaultSegmentSize = 451;
            
            kMiddlePartStart = 200;
            kMiddlePartEnd = 350;
            
            kDefaultRange = FeatureRange(1,kDefaultSegmentSize);
            
            segmentRanges = [FeatureRange(1,kMiddlePartStart-1),...
                FeatureRange(kMiddlePartStart,kMiddlePartEnd),...
                FeatureRange(kMiddlePartEnd+1,kDefaultSegmentSize)];
            
            nSegmentRanges = length(segmentRanges);
            
            statisticalFeatureExtractors = FeatureExtractor2.createStatisticalFeatureExtractors(kDefaultNumSignals,segmentRanges);
            nStatisticalFeatureExtractors = length(statisticalFeatureExtractors);
            
            featureExtractors = repmat(FeatureComputer(),1,500);
            featureExtractors(1:nStatisticalFeatureExtractors) = statisticalFeatureExtractors;
            featureExtractorCounter = nStatisticalFeatureExtractors;
            
            %{
            %quantile
            quantileComputer = QuantileComputer(4);

            for currentSignal = 1 : kDefaultNumSignals
                featureComputer = FeatureComputer(quantileComputer,currentSignal,kDefaultRange);
                featureComputer.numOutputSignals = 4;
                featureExtractorCounter = featureExtractorCounter + 1;
                featureExtractors(featureExtractorCounter) = featureComputer;
            end
            %}
            
            %zrc
            zeroCrossingComputer = SignalComputer("zrc",@zrc);
            for currentSignal = 1 : kDefaultNumSignals-1
                
                for currentRange = 1 : nSegmentRanges
                    range = segmentRanges(currentRange);
                    featureComputer = FeatureComputer(zeroCrossingComputer,currentSignal,range);
                    featureExtractorCounter = featureExtractorCounter + 1;
                    featureExtractors(featureExtractorCounter) = featureComputer;
                end
            end
            
            %sma acceleration
            smaComputer = SignalComputer('smaAccel',@sma);
            featureComputer = FeatureComputer(smaComputer,1:3,kDefaultRange);
            featureExtractorCounter = featureExtractorCounter + 1;
            featureExtractors(featureExtractorCounter) = featureComputer;
            
            %sma gravity
            smaComputer = SignalComputer('smaGrav',@sma);
            featureComputer = FeatureComputer(smaComputer,4:6,kDefaultRange);
            featureExtractorCounter = featureExtractorCounter + 1;
            featureExtractors(featureExtractorCounter) = featureComputer;
            
            %svm
            smaComputer = SignalComputer('svmEnergy',@svmFeature);
            featureComputer = FeatureComputer(smaComputer,7,kDefaultRange);
            featureExtractorCounter = featureExtractorCounter + 1;
            featureExtractors(featureExtractorCounter) = featureComputer;
            
            %energy
            energyAxes = [1,2,3,7];
            energyComputer = SignalComputer("energy",@energy);
            for currentSignal = 1 : length(energyAxes)
                signalAxis = energyAxes(currentSignal);
                featureComputer = FeatureComputer(energyComputer,signalAxis,kDefaultRange);
                featureExtractorCounter = featureExtractorCounter + 1;
                featureExtractors(featureExtractorCounter) = featureComputer;
            end

            featureExtractors = featureExtractors(1:featureExtractorCounter);
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
        
        function featureExtractors = createStatisticalFeatureExtractors(numSignals,segmentRanges)
            
            signalComputers = FeatureExtractor2.createDefaultFeatureExtractionComputers();
            nSignalComputers = length(signalComputers);
            nSegmentRanges = length(segmentRanges);
            
            nFeatureComputers = nSignalComputers * numSignals * nSegmentRanges;
            
            featureExtractors = repmat(FeatureComputer,1,nFeatureComputers);
            featureExtractorCounter = 0;
            
            for currentSignalComputer = 1 : nSignalComputers
                
                signalComputer = signalComputers(currentSignalComputer);
                
                for currentSignal = 1 : numSignals
                    
                    for currentRange = 1 : nSegmentRanges
                        range = segmentRanges(currentRange);
                        featureComputer = FeatureComputer(signalComputer,currentSignal,range);
                        
                        featureExtractorCounter = featureExtractorCounter + 1;
                        featureExtractors(featureExtractorCounter) = featureComputer;
                    end
                end
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
            
            energySelector = SimultaneousComputer({laxSelector,laxSelector,laxSelector});
            
            energyComputer = SequentialComputer({energySelector, SignalComputer.EnergyComputer()});
            
            signalComputer = SimultaneousComputer({laxSelector,laySelector,lazSelector,gravxComputer,gravyComputer,gravzComputer, energyComputer});
        end 
    end
  end
  