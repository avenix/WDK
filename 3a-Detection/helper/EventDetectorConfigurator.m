%this class retrieves an event detector algorithm from the UI
classdef EventDetectorConfigurator < handle

    properties (Access = public)
        eventDetectors;
    end
    
    properties (Access = private)
        currentEventDetectorVariables;
        
        eventDetectorList;
        eventDetectorVariablesTable;
        eventDetectorVariables;
    end
    
    methods (Access = public)
        function obj = EventDetectorConfigurator(eventDetectors, eventDetectorList,eventDetectorVariablesTable)
            obj.eventDetectors = eventDetectors;
            obj.eventDetectorList = eventDetectorList;
            obj.eventDetectorVariablesTable = eventDetectorVariablesTable;
            
            obj.fillEventDetectionList();
            obj.updateSelectedEventDetector();
            obj.updateVariablesTable();
            
            obj.eventDetectorList.ValueChangedFcn = @obj.handleEventDetectionChanged;
        end
        
        function eventDetector = createEventDetectorWithUIParameters(obj)
            eventDetector = obj.getSelectedEventDetector();  
            
            data = obj.eventDetectorVariablesTable.Data;
            for i = 1 : length(data)
                variableName = data{i,1};
                variableValue = data{i,2};
                setExpression = sprintf('eventDetector.%s=%d;',variableName,variableValue);
                eval(setExpression);
            end
        end
        
    end
    
    methods (Access = private)   
        
        function eventDetector = getSelectedEventDetector(obj)
            idxStr = obj.eventDetectorList.Value;
            [~,idx] = ismember(idxStr, obj.eventDetectorList.Items);
            eventDetector = obj.eventDetectors{idx};
        end
        
        function fillEventDetectionList(obj)
            eventDetectorStrs = Helper.generateComputerNamesArray(obj.eventDetectors);
            obj.eventDetectorList.Items = eventDetectorStrs;
            obj.eventDetectorList.Value = eventDetectorStrs{1};
        end
        
        function updateSelectedEventDetector(obj)
            eventDetector = obj.getSelectedEventDetector();
            obj.currentEventDetectorVariables = eventDetector.getEditableProperties();
        end
        
        function updateVariablesTable(obj)
            obj.eventDetectorVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentEventDetectorVariables);
        end
        
        function handleEventDetectionChanged(obj,~,~)
            obj.updateSelectedEventDetector();
            obj.updateVariablesTable();
        end
    end
end