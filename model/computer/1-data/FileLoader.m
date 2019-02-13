classdef FileLoader < Computer
    properties (Access = public)
        fileName;
    end
    
    properties (Access = private)
        dataLoader;
    end
    
    methods (Access = public)
        function obj = FileLoader()
            obj.name = 'fileLoader';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kEvent);
            obj.dataLoader = DataLoader();
        end
        
        function file = compute(obj,~)
            file = obj.dataLoader.loadDataFile(obj.fileName);
            Computer.SetSharedContextVariable(Constants.kSharedVariableCurrentDataFile,file);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s',obj.name, obj.fileName);
        end
        
        function fileNameProperty = getEditableProperties(obj)
            fileNameProperty = Property('fileName',obj.fileName);
        end
    end
end