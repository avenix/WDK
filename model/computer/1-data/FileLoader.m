classdef FileLoader < Computer
    properties (Access = public)
        %fileNames;
    end
    
    properties (Access = private)
        dataLoader;
    end
    
    methods
        function obj = FileLoader()
            obj.name = 'fileLoader';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kEvent);
            obj.dataLoader = DataLoader();
        end
        
        function files = compute(obj,~)
             [files, ~] = obj.dataLoader.loadAllDataFiles();
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s',obj.name,obj.fileName);
        end
        
        function fileNameProperty = getEditableProperties(obj)
            fileNameProperty = Property('fileName',obj.fileName);
        end
        
    end
end