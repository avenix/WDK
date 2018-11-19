classdef AggregatedDetectionResults < handle
   properties (Access = public)
       nGoodEventsDetected;
       nBadEventsDetected;
       nGoodEvents;
   end
   
   methods (Access = public)
       function obj = AggregatedDetectionResults(nGoodEventsDetected,nBadEventsDetected,nGoodEvents)
           if nargin>1
               obj.nGoodEventsDetected = nGoodEventsDetected;
               obj.nBadEventsDetected = nBadEventsDetected;
               obj.nGoodEvents = nGoodEvents;
           end
       end
       
       function detectionMetric = computeDetectionMetric(obj)
           detectionMetric = DetectionMetric(obj.nGoodEventsDetected,obj.nBadEventsDetected,obj.nGoodEvents);
       end
       
       function str = toString(obj)
            str = sprintf('%6.1f%%|x%3.2f(%d)',...
                100 * obj.nGoodEventsDetected/obj.nGoodEvents,...
                obj.nBadEventsDetected/obj.nGoodEvents,...
                obj.nBadEventsDetected);
       end
   end
   
   methods (Static)
       
        %receives an array of DetectionResults
        function aggregatedDetectionStatistics = AggregatedDetectionResultsWithDetectionResults(resultsPerFile)
            totalGoodEventsDetected = 0;
            totalMissedEvents = 0;
            totalBadEventDetected = 0;
            for i = 1 : length(resultsPerFile)
                detectionResults = resultsPerFile(i);
                totalGoodEventsDetected = totalGoodEventsDetected + detectionResults.numGoodEvents();
                totalMissedEvents = totalMissedEvents + detectionResults.numMissedEvents();
                totalBadEventDetected = totalBadEventDetected + detectionResults.numBadEvents();
            end
            aggregatedDetectionStatistics = AggregatedDetectionResults(totalGoodEventsDetected,totalBadEventDetected,totalMissedEvents+totalGoodEventsDetected);
        end
   end
end