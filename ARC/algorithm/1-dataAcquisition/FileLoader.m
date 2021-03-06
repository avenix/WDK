classdef FileLoader < Algorithm
    properties (Access = public)
        fileName;
        selectedSignalIndices;
        loadedFile;
    end
    
    methods (Access = public)
        function obj = FileLoader(fileName,selectedSignalIndices)
            if nargin > 0
                obj.fileName = fileName;
                if nargin > 1
                    obj.selectedSignalIndices = selectedSignalIndices;
                end
            end
            
            obj.name = 'fileLoader';
            obj.inputPort = DataType.kNull;
            obj.outputPort = DataType.kDataFile;
        end
        
        function file = compute(obj,~)
            file = obj.loadFile();
            Algorithm.SetSharedContextVariable(Constants.kSharedVariableCurrentDataFile,file);
        end
                
        function file = loadFile(obj)
            file = DataLoader.LoadDataFile(obj.fileName);
            if ~isempty(obj.selectedSignalIndices)
                file = file.createFileWithColumnIndices(obj.selectedSignalIndices);
            end
            obj.loadedFile = file;
        end
        
        function file = getOrCreateFile(obj)
            if isempty(obj.loadedFile)
                obj.loadFile();
            end
            file = obj.loadedFile;
        end
        
        function str = toString(obj)
            selectedSignalsStr = sprintf('[%s]',Helper.ArrayToString(obj.selectedSignalIndices,','));
            str = sprintf('%s_%s_%s',obj.name, obj.fileName,selectedSignalsStr);
        end
        
        function fileNameProperty = getEditableProperties(obj)
            fileNameProperty = Property('fileName',obj.fileName);
        end
    end

end
