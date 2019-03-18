classdef DetectionAggregatedResults < handle
   properties (Access = public)
       nGoodEventsDetected;
       nBadEventsDetected;
       nGoodEvents;
   end
  
   methods (Access = public)
       function obj = DetectionAggregatedResults(nGoodEventsDetected,nBadEventsDetected,nGoodEvents)
           if nargin>1
               obj.nGoodEventsDetected = nGoodEventsDetected;
               obj.nBadEventsDetected = nBadEventsDetected;
               obj.nGoodEvents = nGoodEvents;
           end
       end
       
       function detectionMetric = computeDetectionMetric(obj)
           detectionMetric = DetectionMetric(obj.nGoodEventsDetected,obj.nBadEventsDetected,obj.nGoodEvents);
       end
   end
   
   methods (Static)
       
        %receives an array of DetectionResults
        function aggregatedDetectionStatistics = DetectionAggregatedResultsWithDetectionResults(resultsPerFile)
            totalGoodEventsDetected = 0;
            totalMissedEvents = 0;
            totalBadEventDetected = 0;
            for i = 1 : length(resultsPerFile)
                detectionResults = resultsPerFile(i);
                totalGoodEventsDetected = totalGoodEventsDetected + detectionResults.numGoodEvents();
                totalMissedEvents = totalMissedEvents + detectionResults.numMissedEvents();
                totalBadEventDetected = totalBadEventDetected + detectionResults.numBadEvents();
            end
            aggregatedDetectionStatistics = DetectionAggregatedResults(totalGoodEventsDetected,totalBadEventDetected,totalMissedEvents+totalGoodEventsDetected);
        end
   end
end