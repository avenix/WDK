classdef AnnotationSynchronisationFile < handle
    properties
        frame1;
        frame2;
        sample1;
        sample2;
    end
    
    methods (Access = public)
        function obj = AnnotationSynchronisationFile(sample1,sample2,frame1,frame2)
            if nargin > 0
                obj.sample1 = sample1;
                obj.sample2 = sample2;
                obj.frame1 = frame1;
                obj.frame2 = frame2;
            end
        end
        
        function videoFrame = sampleToVideoFrame(obj, sample)
            
            a = (obj.frame2 - obj.frame1) / (obj.sample2 - obj.sample1);
            videoFrame = a * (sample - obj.sample1) + obj.frame1;
            
            if videoFrame < 1
                videoFrame = 1;
            end
            
            videoFrame = uint32(videoFrame);
        end
        
        function sample = videoFrameToSample(obj, videoFrame)
            
            a = (obj.sample2 - obj.sample1) / (obj.frame2 - obj.frame1);
            sample = a * (videoFrame - obj.frame1) + obj.sample1;
            
            if sample < 1
                sample = 1;
            end
            
            sample = uint32(sample);
        end
    end
    
    
end
