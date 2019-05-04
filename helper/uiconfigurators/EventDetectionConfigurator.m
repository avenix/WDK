classdef EventDetectionConfigurator < handle
   properties (Access = public)
       uiElements EventDetectionConfiguratorUIElements;
       computerConfigurator;
       preprocessingConfigurator;
   end
   
   methods (Access = public)
       function obj = EventDetectionConfigurator(signals, preprocessingSignalComputers, eventDetectionComputers, uiElements)
           obj.uiElements = uiElements;

            obj.preprocessingConfigurator = PreprocessingConfigurator(...
                signals,...
                preprocessingSignalComputers,...
                uiElements.preprocessingSignalsList,...
                uiElements.preprocessingSignalComputerList,...
                uiElements.preprocessingSignalComputerVariablesTable);

            obj.computerConfigurator = ComputerConfigurator(...
                eventDetectionComputers,...
                uiElements.eventDetectionList,...
                uiElements.eventDetectionVariablesTable);
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
   end
end