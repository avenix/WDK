classdef FeatureExtractor < Computer

    properties (Access = public)
        computers;
    end
    
    methods (Access = public)
        
        function obj = FeatureExtractor(computers)
            if nargin > 0 
                obj.computers = computers;
            end
            obj.name = 'FeatureExtractor';
            obj.inputPort = ComputerPort(ComputerPortType.kSegment);
            obj.outputPort = ComputerPort(ComputerPortType.kTable);
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
                    featureVectors(i,j) = Computer.ExecuteChain(obj.computers{j},segment.window);
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
                    [~, metrics] = Computer.ExecuteChain(obj.computers{j},segment.window);
                    metricSum.addMetric(metrics);
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
        
        function featureExtractors = CreateDefaultFeatureExtractors()
            featureExtractors = {Min(), Max(), Mean(), Median(), Variance(), STD(),...
                AUC(), AAV(), MAD(),IQR(),RMS(),Skewness(),Kurtosis()};
        end
        
        function axisSelectors = CreateAxisSelectorsForSignals(numSignals)
            axisSelectors = repmat(AxisSelector,1,numSignals);
            for i = 1 : numSignals
                axisSelectors(i) = AxisSelector(i);
            end
        end
        
        function rangeSelectors = CreateRangeSelectorsForRanges(ranges)
            nRanges = length(ranges);
            rangeSelectors = repmat(RangeSelector,1,nRanges);
            for i = 1 : nRanges
                range = ranges(i);
                rangeSelectors(i) = RangeSelector(range.rangeStart,range.rangeEnd);
            end
        end
        
    end
end