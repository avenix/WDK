classdef Printer < handle
    methods (Access = public)
        function printSegmentationTableStatistics(~,table)
            numRelevantInstances = sum(table.label == 1);
            numIrrelevantInstances = sum(table.label == 2);
            totalInstances = numRelevantInstances + numIrrelevantInstances;
            
            fprintf("Relevant: \t %.1f%%\n",numRelevantInstances*100/totalInstances);
            fprintf("Irelevant: \t %.1f%%\n",numIrrelevantInstances*100/totalInstances);
            fprintf("Total: \t %d\n",totalInstances);
            
        end
        
        function printClasses(~)
            classes = {'diveLowRight','diveLowLeft','diveHighRight','diveHighLeft',...
                'diveStandLowRight','diveStandLowLeft','diveStandHighRight','diveStandHighLeft',...
                'catchHand','catchBody','catchGround',...
                'jumpCatchStand','jumpCatchRun',...
                'throwHigh','throwLow',...
                'shortDiveLeft','shortDiveRight',...
                'shortSprint','longSprint',...
                'joggingStart','joggingEnd','joggingJumpingStart','joggingJumpingEnd',...
                'kickBody','kickGround',...
                'pass','synchronisation','bounce','clap','null'};
            
            for i = 1 : length(classes)
                classStr = classes(i);
                %fprintf('%d %s\n',i,classStr{1});
                fprintf('%s\n',classStr{1});
            end
        end
    end
end