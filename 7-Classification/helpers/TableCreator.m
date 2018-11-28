classdef TableCreator < handle
    
    properties (Access = public)
        fileName = 'featureTables';
        segmentsLoader;
    end
    
    properties (Access = private)
        featureExtractor;
        classesMap;
    end
    
    methods (Access = public)
        
        function obj = TableCreator(featureExtractor)
            obj.classesMap = ClassesMap.instance();
            obj.segmentsLoader = SegmentsLoader();
            if nargin > 0 
                obj.featureExtractor = featureExtractor;
            end 
        end
        
        %loads or creates a TableSet
        function tableSet = loadAllTables(obj)
            segmentsStr = obj.segmentsLoader.segmentsCreator.toString(true);
            fullFileName = sprintf('%s/%s_%s.mat',Constants.precomputedPath, obj.fileName,segmentsStr);
            if exist(fullFileName,'File') == 2
                tableStruct = load(fullFileName);
                tableSet = TableSet(tableStruct.myTables);
            else
                fprintf('Creating table %s...\n',fullFileName);
                myTables = obj.createTables();
                save(fullFileName,'myTables');
                tableSet = TableSet(myTables);
            end
        end
        
        %creates a single table from a set of segments
        function table = createTable(obj,segments)
            
            
            nSegments = length(segments);
            nFeatures = obj.featureExtractor.nFeatures;
            shouldCreateLabelColumn = obj.areSegmentsLabeled(segments);
            nColumns = nFeatures + int32(shouldCreateLabelColumn);
            featureVectors = zeros(nSegments,nColumns);
            segmentsCounter = 0;
            
            for i = 1 : nSegments
                segment = segments(i);
                if isempty(segment.class) || (segment.class ~= obj.classesMap.synchronisationClass ...
                        && segment.class ~= ClassesMap.kInvalidClass)
                    
                    segmentsCounter = segmentsCounter + 1;
                    
                    featureVectors(segmentsCounter,1:nFeatures) = obj.featureExtractor.extractFeaturesForSegment(segment.window);
                    
                    if ~isempty(segment.class)
                        featureVectors(segmentsCounter,nColumns) = segment.class;
                    end
                end
            end
            
            table = array2table(featureVectors(1:segmentsCounter,:));
            if shouldCreateLabelColumn
                table.Properties.VariableNames = [obj.featureExtractor.featureNames, 'label'];
            end
        end
    end
    
    methods (Access = private)
        
        function tables = createTables(obj)
            segments = obj.segmentsLoader.loadOrCreateSegments();
            
            nTables = length(segments);
            tables = cell(1,nTables);
            
            for i = 1 : nTables
                table = obj.createTable(segments{i});
                tables{i} = table;
                fprintf('created table %d\n',i);
            end
        end
        
        function labeled = areSegmentsLabeled(~,segments)
            labeled = true;
            for i = 1 : length(segments)
                if isempty(segments(i).class)
                    labeled = false;
                    break;
                end
            end
        end
    end
end

