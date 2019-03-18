classdef TableRowSelector < Computer
    
    properties (Access = public)
        selectedLabels;
    end
    
    methods (Access = public)
        
        function obj = TableRowSelector(selectedLabels)
            if nargin > 0
                obj.selectedLabels = selectedLabels;
            end
            obj.name = 'TableRowSelector';
            obj.inputPort = ComputerPort(ComputerPortType.kTable);
            obj.outputPort = ComputerPort(ComputerPortType.kTable);
        end
        
        function table = compute(obj,table)
            table = Table(table.table);
            table.filterTableToLabelFlags(obj.selectedLabels);
        end
        
        function str = toString(obj)
            selectedLabelsStr = Helper.arrayToString(obj.selectedLabels);
            selectedLabelsStr = strrep(selectedLabelsStr,'\n','');
            str = sprintf('%s%s',obj.name,selectedLabelsStr);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('selectedLabels',array2JSON(obj.selectedLabels));
        end
    end
    
end
