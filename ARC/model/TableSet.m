%contains a set of tales (cell array) and operations to merge them
classdef TableSet < handle
    
    properties (Access = public)
        tables;
    end
    
    properties (Dependent)
        nRows;
        nTables;
    end
    
    methods
        function nRows = get.nRows(obj)
            nRows = TableSet.CountNumberOfRows(obj.tables);
        end
        
        function nTables = get.nTables(obj)
            nTables = length(obj.tables);
        end
    end
    
    methods (Access = public)
        function obj = TableSet(tables)
            obj.tables = tables;
        end
        
        function table = mergedTableForIndices(obj,indices)
            selectedTables = obj.tables(indices);
            table = TableSet.MergeTables(selectedTables);
        end
        
        function table = mergedTables(obj)
            table = TableSet.MergeTables(obj.tables);
        end
        
        function labels = getAllLabels(obj)
            labels = {obj.tables.label};
            %labels = cat(1,obj.tables.label);
        end
    end
    
    methods (Static)
        function mergedTable = MergeTables(tables)
            if isempty(tables) 
                mergedTable = [];
            else
                
                nRows = TableSet.CountNumberOfRows(tables);
                if nRows > 0
                    firstTable = tables(1).table;
                    mergedTableArray = zeros(nRows,width(firstTable));
                    
                    currentRow = 1;
                    for i = 1 : length(tables)
                        currentTable = tables(i).table;
                        nRowsCurrentTable = height(currentTable);
                        mergedTableArray(currentRow : currentRow + nRowsCurrentTable - 1,:) = table2array(currentTable);
                        currentRow = currentRow + nRowsCurrentTable;
                    end
                    
                    mergedTable = array2table(mergedTableArray);
                    mergedTable.Properties.VariableNames = firstTable.Properties.VariableNames;
                    mergedTable = Table(mergedTable);
                end
            end
        end
        
        function nRows = CountNumberOfRows(tables)
            nRows = 0;
            for i = 1 : length(tables)
                nRows = nRows + tables(i).height;
            end
        end
        
    end
end
