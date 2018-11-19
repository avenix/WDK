classdef AggregatedDetectionResultsPerClass < handle
   properties (Access = public)
       nGoodEventsDetectedPerClass;
       nBadEventsDetected;
       nGoodEventsPerClass;
   end
   
   methods (Access = public)
       function obj = AggregatedDetectionResultsPerClass(nGoodEventsDetectedPerClass,nBadEventsDetected,nGoodEventsPerClass)
           if nargin>1
               obj.nGoodEventsDetectedPerClass = nGoodEventsDetectedPerClass;
               obj.nBadEventsDetected = nBadEventsDetected;
               obj.nGoodEventsPerClass = nGoodEventsPerClass;
           end
       end
       
       function [nGoodEvents, nBadEvents, nTotalEvents] = aggregate(obj)
           nGoodEvents = sum(obj.nGoodEventsDetectedPerClass);
           nBadEvents = obj.nBadEventsDetected;
           nTotalEvents = sum(obj.nGoodEventsPerClass);
       end
       
       function detectionMetric = computeDetectionMetric(obj)
           [nGoodEvents, nBadEvents, nTotalEvents] = obj.aggregate();
           detectionMetric = DetectionMetric(nGoodEvents,nBadEvents,nTotalEvents);
       end
       
       function str = toString(obj)
           str = "";
           numClasses = length(obj.nGoodEventsDetectedPerClass);
           for i = 1 : numClasses
               nGoodEventsDetected = obj.nGoodEventsDetectedPerClass(i);
               nGoodEvents = obj.nGoodEventsPerClass(i);
               detectionRate = 100 * nGoodEventsDetected / nGoodEvents;
               str = sprintf('%s|%9.1f%%',str,detectionRate);
           end
          nTotalGoodEvents = sum(obj.nGoodEventsPerClass);
          badEventsRate = obj.nBadEventsDetected / nTotalGoodEvents;
          str = sprintf('%s|x%.2f(%d)',str,badEventsRate,obj.nBadEventsDetected);
       end
   end
   
   methods (Static)
         
         %returns an array of integers with the amounts of detected classs
         function detectionStatistics = computeAggregatedClassStatistics(resultsPerFile,nClasses)
            
            nFiles = length(resultsPerFile);
            nTotalGoodEventsDetectedPerClass = zeros(1,nClasses);
            nTotalBadEventsPerClass = 0;
            nTotalGoodEventsPerClass = zeros(1,nClasses);
            
            for i = 1 : nFiles
                results = resultsPerFile(i);
                
                nGoodEventsDetectedPerClass = results.numGoodEventsPerClass(nClasses);
                nBadEventsDetected = results.numBadEvents();
                nMissedEventsDetectedPerClass = results.numMissedEventsPerClass(nClasses);
                nEventsPerClass = nGoodEventsDetectedPerClass + nMissedEventsDetectedPerClass;
                
                nTotalGoodEventsDetectedPerClass = nTotalGoodEventsDetectedPerClass + nGoodEventsDetectedPerClass;
                nTotalBadEventsPerClass = nTotalBadEventsPerClass + nBadEventsDetected;
                nTotalGoodEventsPerClass = nTotalGoodEventsPerClass + nEventsPerClass;
            end
            detectionStatistics = AggregatedDetectionResultsPerClass(nTotalGoodEventsDetectedPerClass,...
                nTotalBadEventsPerClass, nTotalGoodEventsPerClass);
        end
        
   end
end