classdef TableExporter < handle
    
    properties (Access = public)
        writeVariableNames = true;
        writeRowNames = false;
        delimiter = ',';
    end
    
    methods (Access = public)
        
        function testExportTableForFileNames(obj,fileNames)
            
            labelingStrategy = DefaultLabelingStrategy();
            tableCreator = TableCreator();
            table = tableCreator.loadFeaturesTableFiltered(fileNames, labelingStrategy);
            featureSelector = FeatureSelector();
            bestFeatureIdxs = featureSelector.getBestNFeatures(9);
            table = table(:,[bestFeatureIdxs end]);
            obj.exportTable(table);
        end
        
        function exportTable(obj,table,fileName)
            writetable(table,fileName,'Delimiter',obj.delimiter,'WriteVariableNames',obj.writeVariableNames,'WriteRowNames',obj.writeRowNames);
        end
    end
end