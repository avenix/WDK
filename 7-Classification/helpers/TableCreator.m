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
        
        function obj = TableCreator()
            obj.classesMap = ClassesMap.instance();
            obj.featureExtractor = FeatureExtractor();
            obj.segmentsLoader = SegmentsLoader();
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
            featureVectors = zeros(nSegments,nFeatures+1);
            segmentsCounter = 0;
            for i = 1 : nSegments
                segment = segments(i);
                if segment.class ~= obj.classesMap.synchronisationClass ...
                        && segment.class ~= ClassesMap.kInvalidClass
                    
                    segmentsCounter = segmentsCounter + 1;
                    
                    featureVectors(segmentsCounter,1:end-1) = obj.featureExtractor.extractFeaturesForSegment(segment.window);
                    featureVectors(segmentsCounter,end) = segment.class;
                end
            end
            
            table = array2table(featureVectors(1:segmentsCounter,:));
            table.Properties.VariableNames = [obj.featureExtractor.featureNames, 'label'];
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
    end
end

