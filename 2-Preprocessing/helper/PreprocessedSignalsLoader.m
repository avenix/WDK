classdef PreprocessedSignalsLoader < handle
    
    properties (Access = public)
        preprocessor;
    end

    methods (Access = public)
        
        function obj = PreprocessedSignalsLoader(preprocessor)
            if nargin == 1
                obj.preprocessor = preprocessor;
            else
                obj.preprocessor = NoOp();
            end
        end
        
        %returns a cell array of arrays of processed data files
        function data = loadOrCreateData(obj)
            fullFileName = obj.getFullFileName();
            if exist(fullFileName,'File') == 2
                data = load(fullFileName,'data');
                data = data.data;
            else
                fprintf('Creating %s...\n',fullFileName);
                dataLoader = DataLoader();
                data = dataLoader.loadAllDataFiles();
                data = obj.preprocess(data);
                
                save(fullFileName,'data');
            end
        end
    end
    
    methods (Access = private)
        function fullFileName = getFullFileName(obj)
            
            preprocessorStr = obj.preprocessor.toString();
            if isempty(preprocessorStr)
                fullFileName = sprintf('%s/2-preprocessed.mat',Constants.precomputedPath);
            else
                fullFileName = sprintf('%s/2-preprocessed_%s.mat',Constants.precomputedPath,preprocessorStr);
            end
        end
        
        function preprocessedData = preprocess(obj,dataFiles)
            nFiles = length(dataFiles);
            preprocessedData = cell(1,nFiles);
            
            for i = 1 : nFiles
                data = dataFiles{i};
                preprocessedData{i} = obj.preprocessor.compute(data);
            end
        end
    end
end