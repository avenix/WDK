classdef PreprocessedSignalsLoader < handle
    properties (Access = public)
        preprocessor;
    end

    methods (Access = public)
        function obj = PreprocessedSignalsLoader(preprocessor)
            if nargin == 1
                obj.preprocessor = preprocessor;
            else
                obj.preprocessor = SignalComputer.NoOpComputer();
            end
        end
        
        %returns a cell array of arrays of processed data files
        function data = loadOrCreateData(obj)
            preprocessorStr = obj.preprocessor.toString();
            fullFileName = sprintf('%s/2-preprocessed_%s.mat',Constants.precomputedPath,preprocessorStr);
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

        function str = toString(obj)
            signalPreprocessorStr = obj.preprocessor.toString();
            str = sprintf('%s_%s',signalPreprocessorStr);
        end
    end
    
    methods (Access = private)
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