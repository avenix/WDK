classdef TableExporter < handle
    
    methods (Access = public)
        function obj = TableExporter()
            %addpath(genpath('../'));
            %fileNames = {'1-lukas'};
            %obj.testExportTableForFileNames(fileNames);
        end
        
        function testExportTableForFileNames(obj,fileNames)
            
            labelingStrategy = DefaultLabelingStrategy();
            tableCreator = TableCreator();
            table = tableCreator.loadFeaturesTableFiltered(fileNames, labelingStrategy);
            featureSelector = FeatureSelector();
            bestFeatureIdxs = featureSelector.getBestNFeatures(9);
            table = table(:,[bestFeatureIdxs end]);
            obj.exportTable(table);
        end
        
        function exportTable(~,table,fileName)
            writetable(table,fileName,'Delimiter',',');
        end
    end
end