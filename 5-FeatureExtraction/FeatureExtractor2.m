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
        function defaultFeatureExtractor = createDefaultFeatureExtractor()
            
            kDefaultNumSignals = 7;
            kDefaultSegmentSize = 451;
            
            kMiddlePartStart = 200;
            kMiddlePartEnd = 350;
            
            %kDefaultRange = FeatureRange(1,kDefaultSegmentSize);
            
            segmentRanges = [FeatureRange(1,kMiddlePartStart-1),...
                FeatureRange(kMiddlePartStart,kMiddlePartEnd),...
                FeatureRange(kMiddlePartEnd+1,kDefaultSegmentSize)];
            
            %nSegmentRanges = length(segmentRanges);
            
            statisticalFeatureExtractors = FeatureExtractor2.createStatisticalFeatureExtractors(kDefaultNumSignals,segmentRanges);
            %nStatisticalFeatureExtractors = length(statisticalFeatureExtractors);
            %defaultFeatureExtractor = SequentialComputer(statisticalFeatureExtractors);
            
            %featureExtractors = repmat(SequentialComputer(),1,500);
            %featureExtractors(1:nStatisticalFeatureExtractors) = statisticalFeatureExtractors;
            %featureExtractorCounter = nStatisticalFeatureExtractors;
            
            %{
            %quantile
            quantileComputer = QuantileComputer(4);

            for currentSignal = 1 : kDefaultNumSignals
                featureComputer = SequentialComputer({quantileComputer,currentSignal,kDefaultRange});
                featureComputer.numOutputSignals = 4;
                featureExtractorCounter = featureExtractorCounter + 1;
                featureExtractors(featureExtractorCounter) = featureComputer;
            end
            %}
            
            %{
            %zrc
            zeroCrossingComputer = Zrc();
            for currentSignal = 1 : kDefaultNumSignals-1
                
                for currentRange = 1 : nSegmentRanges
                    range = segmentRanges(currentRange);
                    featureComputer = SequentialComputer({zeroCrossingComputer,currentSignal,range});
                    featureExtractorCounter = featureExtractorCounter + 1;
                    featureExtractors(featureExtractorCounter) = featureComputer;
                end
            end
            
            %sma acceleration
            smaComputer = SignalComputer('smaAccel',@sma);
            featureComputer = SequentialComputer(smaComputer,1:3,kDefaultRange);
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
            %}
            
            %featureExtractors = featureExtractors(1:featureExtractorCounter);
        end
        
        function featureExtractors = createDefaultFeatureExtractionComputers()
            featureExtractors = {Min(), Max(), Mean(), Median()};
            %featureExtractorHandles = {@min,@max,@mean,@var,@std,@median,@trapz,@aav,...
            %   @mad,@iqr,@rms,@mySkewness,@myKurtosis};
        end
        
        function axisSelectors = createAxisSelectorsForSignals(numSignals)
            axisSelectors = repmat(AxisSelector,1,numSignals);
            for i = 1 : numSignals
                axisSelectors(i) = AxisSelector(i);
            end
        end
        
        function rangeSelectors = createRangeSelectorsForRanges(ranges)
            nRanges = length(ranges);
            rangeSelectors = repmat(RangeSelector,1,nRanges);
            for i = 1 : nRanges
                range = ranges(i);
                rangeSelectors(i) = RangeSelector(range.rangeStart,range.rangeEnd);
            end
        end
        
        
        function featureComputers = createStatisticalFeatureExtractors(numSignals,segmentRanges)
            
            featureExtractors = FeatureExtractor2.createDefaultFeatureExtractionComputers();
            axisSelectors = FeatureExtractor2.createAxisSelectorsForSignals(numSignals);
            rangeSelectors = FeatureExtractor2.createRangeSelectorsForRanges(segmentRanges);
            
            nFeatureExtractors = length(featureExtractors);
            nAxisSelectors = length(axisSelectors);
            nRangeSelectors = length(segmentRanges);
            
            nFeatureComputers = nFeatureExtractors * numSignals * nRangeSelectors;
            
            featureComputers = cell(1,nFeatureComputers);
            featureExtractorCounter = 1;
            
            for featureExtractorIdx = 1 : nFeatureExtractors
                
                featureExtractor = featureExtractors{featureExtractorIdx};
                
                for axisSelectorIdx = 1 : nAxisSelectors
                    
                    axisSelector = axisSelectors(axisSelectorIdx);
                    
                    for rangeSelectorIdx = 1 : nRangeSelectors
                        
                        rangeSelector = rangeSelectors(rangeSelectorIdx);
                        
                        featureComputer = SequentialComputer({rangeSelector,axisSelector,featureExtractor});
                        featureComputers{featureExtractorCounter} = featureComputer;
                        featureExtractorCounter = featureExtractorCounter + 1;
                    end
                end
            end
        end
        
    end
end
