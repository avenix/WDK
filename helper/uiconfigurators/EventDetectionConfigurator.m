%UI Controller class to create an EventDetection algorithm from a UI
classdef EventDetectionConfigurator < handle
    properties (Access = public)
        uiElements EventDetectionConfiguratorUIElements;
        computerConfigurator;
        preprocessingConfigurator;
        delegate;
    end
    
    properties (Access = private)
        eventDetectionComputers;
    end
    
    methods (Access = public)
        function obj = EventDetectionConfigurator(signals, preprocessingSignalComputers,...
                eventDetectionComputers, uiElements,delegate)
            
            obj.uiElements = uiElements;
            obj.eventDetectionComputers = eventDetectionComputers;
            
            if nargin > 4
                obj.delegate = delegate;
            end
            
            obj.preprocessingConfigurator = PreprocessingConfigurator(...
                signals,...
                preprocessingSignalComputers,...
                uiElements.preprocessingSignalsList,...
                uiElements.preprocessingSignalComputerList,...
                uiElements.preprocessingSignalComputerVariablesTable,...
                obj);
            
            obj.computerConfigurator = ComputerConfigurator(...
                eventDetectionComputers,...
                uiElements.eventDetectionList,...
                uiElements.eventDetectionVariablesTable,...
                obj);
        end
        
        function computer = createEventDetectorWithUIParameters(obj)
            preprocessingAlgorithm = obj.createPreprocessingComputerWithUIParameters();
            if isempty(preprocessingAlgorithm)
                computer = [];
            else
                eventDetector = obj.computerConfigurator.createComputerWithUIParameters();
                if isa(eventDetector,'NoOp')
                    computer = [];
                else
                    preprocessingAlgorithm.lastComputers{1}.addNextComputer(eventDetector);
                    computer = preprocessingAlgorithm;
                end
            end
        end
        
        function computer = createPreprocessingComputerWithUIParameters(obj)
            computer = obj.preprocessingConfigurator.createPreprocessingComputerWithUIParameters();
        end
        
        function setSignals(obj,signals)
            obj.preprocessingConfigurator.setSignals(signals);
        end
        
        %% handles
        function handlePreprocessingAlgorithmChanged(obj,preprocessingAlgorithm,~)
            outputType = preprocessingAlgorithm.outputPort;
            obj.computerConfigurator.computers = ...
                Palette.FilterAlgorithmsToInputType(obj.eventDetectionComputers,outputType);
            
            obj.computerConfigurator.reloadUI();
        end
        
        function handleAlgorithmChanged(obj,algorithm,~)
            obj.delegate.handleAlgorithmChanged(algorithm,obj);
        end
        
    end
end