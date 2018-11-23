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
        function obj = EventDetectorConfigurator(eventDetectorList,eventDetectorVariablesTable)
            obj.eventDetectorList = eventDetectorList;
            obj.eventDetectorVariablesTable = eventDetectorVariablesTable;
            obj.eventDetectors = {SimplePeakDetector,MatlabPeakDetector};
            
            obj.updateSelectedEventDetector();
            obj.fillEventDetectionList();
            obj.updateVariablesTable();
            
            obj.eventDetectorList.Callback = @obj.handleEventDetectionChanged;
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
            idx = obj.eventDetectorList.Value;
            eventDetector = obj.eventDetectors{idx};
        end
        
        function fillEventDetectionList(obj)
            obj.eventDetectorList.String = Helper.generateEventDetectorNames(obj.eventDetectors);
            obj.eventDetectorList.Value = 1;
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