classdef AssessmentPerformanceMetricResult < handle
   properties (Access = public)
       algorithmName;
       segmentationPerformanceMetrics;
       featureExtractionPerformanceMetrics;
       classificationPerformanceMetrics;
       predictionPerformanceMetrics;
   end
   
end