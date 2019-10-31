classdef FeatureExtractor < Computer

    properties (Access = public)
        computers;
    end
    
    methods (Access = public)
        
        function obj = FeatureExtractor(computers,signalIndices)
            if nargin > 0
                if nargin > 1
                    obj.computers = FeatureExtractor.CreateFeatureExtractionComputers(signalIndices,computers);
                else
                    obj.computers = computers;
                end
            end
            obj.name = 'FeatureExtractor';
            obj.inputPort = DataType.kSegment;
            obj.outputPort = DataType.kTable;
        end
        
        %creates a table from a set of segments
        function table = compute(obj,segments)
            nSegments = length(segments);
            nFeatures = length(obj.computers);
            shouldCreateLabelColumn = obj.areSegmentsLabeled(segments);
            nColumns = nFeatures + int32(shouldCreateLabelColumn);
            featureVectors = zeros(nSegments,nColumns);
            
            for i = 1 : nSegments
                segment = segments(i);
                for j = 1 : length(obj.computers)
                    featureVectors(i,j) = Computer.ExecuteChain(obj.computers{j},segment.data);
                end
            end
            
            if shouldCreateLabelColumn
                for i = 1 : nSegments
                    segment = segments(i);
                    featureVectors(i,nColumns) = segment.label;
                end
            end
            
            table = array2table(featureVectors);
            if shouldCreateLabelColumn
                table.Properties.VariableNames = [obj.getFeatureNames(), 'label'];
            end
            table = Table(table);
        end
        
        function names = getFeatureNames(obj)
            nComputers = length(obj.computers);
            names = cell(1,nComputers);
            
            for i = 1 : nComputers
                featureStr = obj.computers{i}.toString();
                maxChars = min(Constants.kMaxFeatureNameCharacters,length(featureStr));
                featureStr = featureStr(1:maxChars);
                featureName = sprintf('%s_%d',featureStr,i);
                featureName = strrep(featureName,', ','_');
                names{i} = featureName;
            end
        end
        
        function str = toString(obj)
            str = "";
            if ~isempty(obj.computers)
                
                for i = 1 : length(obj.computers)
                    computerStr = obj.computers{i}.toString();
                    if ~isequal(computerStr,"")
                        str = sprintf('%s%s_',str,computerStr);
                    end
                end
            end
        end
        
        function metricSum = computeMetrics(obj,segments)
            metricSum = Metric();
            for i = 1 : length(segments)
                segment = segments(i);
                for j = 1 : length(obj.computers)
                    computer = obj.computers{j};
                    [~, metrics] = Computer.ExecuteChain(computer,segment.data);
                    metricSum.flops = metricSum.flops + metrics.flops;
                    if isempty(computer.tag)
                        metricSum.memory = metricSum.memory + metrics.memory;
                        computer.tag = true;
                    end
                    metricSum.outputSize = metricSum.outputSize + metrics.outputSize;
                end
            end
        end
    end
    
    methods (Access = private)
        function labeled = areSegmentsLabeled(~,segments)
            labeled = false;
            if ~isempty(segments)
                if ~isempty(segments(1).label)
                    labeled = true;
                end
            end
        end
    end
    
    methods (Static)
        
        function featureExtractor = CreateFeatureExtractor(signalIndices,featureExtractors)
            featureExtractionComputers = FeatureExtractor.CreateFeatureExtractionComputers(signalIndices,featureExtractors);
            featureExtractor = FeatureExtractor(featureExtractionComputers);
        end
        
        function featureExtractionComputers = CreateFeatureExtractionComputers(signalIndices,featureExtractors)
            
            nFeatureExtractors = length(featureExtractors);
            axisSelectors = FeatureExtractor.AxisSelectorsForSignalIndices(signalIndices);
            
            nAxisSelectors = length(axisSelectors);
            featureExtractionComputers = cell(1,nFeatureExtractors * nAxisSelectors);
            
            count = 1;
            for i = 1 : length(featureExtractors)
                for j = 1 : length(axisSelectors)
                    featureExtractor = featureExtractors{i}.copy();
                    axisSelector = axisSelectors(j).copy();
                    featureExtractionComputer = Computer.ComputerWithSequence({axisSelector,featureExtractor});
                    featureExtractionComputers{count} = featureExtractionComputer;
                    count = count + 1;
                end
            end
        end
        
        function featureExtractors = DefaultFeatures()
            featureExtractors = {Min(), Max(), Mean(), Median(), Variance(), STD(),...
                AUC(), AAV(), MAD(), IQR(), RMS(), Skewness(), Kurtosis()};
        end
            
        function axisSelectors = AxisSelectorsForSignalIndices(signalIndices)
            numSignals = length(signalIndices);
            axisSelectors = repmat(AxisSelector,1,numSignals);
            for i = 1 : numSignals
                axisSelectors(i) = AxisSelector(signalIndices(i));
            end
        end
                
        function rangeSelectors = RangeSelectorsForRanges(ranges)
            nRanges = length(ranges);
            rangeSelectors = repmat(RangeSelector,1,nRanges);
            for i = 1 : nRanges
                range = ranges(i);
                rangeSelectors(i) = RangeSelector(range.rangeStart,range.rangeEnd);
            end
        end
        
    end
end
