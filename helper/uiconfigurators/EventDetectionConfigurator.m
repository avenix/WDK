%UI Controller class to create an EventDetection algorithm from a UI
classdef EventDetectionConfigurator < handle
    properties (Access = public)
        uiElements EventDetectionConfiguratorUIElements;
        algorithmConfigurator;
        preprocessingConfigurator;
        delegate;
    end
    
    properties (Access = private)
        eventDetectionAlgorithms;
    end
    
    methods (Access = public)
        function obj = EventDetectionConfigurator(signals, preprocessingSignalAlgorithms,...
                eventDetectionAlgorithms, uiElements,delegate)
            
            obj.uiElements = uiElements;
            obj.eventDetectionAlgorithms = eventDetectionAlgorithms;
            
            if nargin > 4
                obj.delegate = delegate;
            end
            
            obj.preprocessingConfigurator = PreprocessingConfigurator(...
                signals,...
                preprocessingSignalAlgorithms,...
                uiElements.preprocessingSignalsList,...
                uiElements.preprocessingAlgorithmsList,...
                uiElements.preprocessingAlgorithmVariablesTable,...
                obj);
            
            obj.algorithmConfigurator = AlgorithmConfigurator(...
                eventDetectionAlgorithms,...
                uiElements.eventDetectionList,...
                uiElements.eventDetectionVariablesTable,...
                obj);
        end
        
        function algorithm = createEventDetectorWithUIParameters(obj)
            preprocessingAlgorithm = obj.createPreprocessingAlgorithmWithUIParameters();
            if isempty(preprocessingAlgorithm)
                algorithm = [];
            else
                eventDetector = obj.algorithmConfigurator.createAlgorithmWithUIParameters();
                if isa(eventDetector,'NoOp')
                    algorithm = [];
                else
                    preprocessingAlgorithm.lastAlgorithms{1}.addNextAlgorithm(eventDetector);
                    algorithm = preprocessingAlgorithm;
                end
            end
        end
        
        function algorithm = createPreprocessingAlgorithmWithUIParameters(obj)
            algorithm = obj.preprocessingConfigurator.createPreprocessingAlgorithmWithUIParameters();
        end
        
        function setSignals(obj,signals)
            obj.preprocessingConfigurator.setSignals(signals);
        end
        
        %% handles
        function handlePreprocessingAlgorithmChanged(obj,preprocessingAlgorithm,~)
            outputType = preprocessingAlgorithm.outputPort;
            obj.algorithmConfigurator.algorithms = ...
                Palette.FilterAlgorithmsToInputType(obj.eventDetectionAlgorithms,outputType);
            
            obj.algorithmConfigurator.reloadUI();
        end
        
        function handleAlgorithmChanged(obj,algorithm,~)
            obj.delegate.handleAlgorithmChanged(algorithm,obj);
        end
        
    end
end