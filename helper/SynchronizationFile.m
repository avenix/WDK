classdef SynchronizationFile < handle
    properties (Access = public)
        synchronizationPointsMap;
        count;
    end
    
    methods
        function c = get.count(obj)
            c = obj.synchronizationPointsMap.Count;
        end
    end
    
    methods (Access = public)
        function obj = SynchronizationFile(samples,frames)
            obj.synchronizationPointsMap = containers.Map('KeyType','uint64','ValueType','uint32');
            if nargin > 0
                obj.synchronizationPointsMap.keys = samples;
                obj.synchronizationPointsMap.values = frames;
            end
        end
        
        function setSynchronizationPoint(obj,sample,frame)
            obj.synchronizationPointsMap(uint64(sample)) = uint32(frame);
        end
        
        function removeSynchronizationPointWithSample(obj,sample)
            obj.synchronizationPointsMap.remove(sample);
        end
        
        function videoFrame = sampleToVideoFrame(obj, sample)
            [frame1, sample1] = obj.getFirstSynchronizationPoint();
            [frame2, sample2] = obj.getLastSynchronizationPoint();
            
            a = double(frame2 - frame1) / double(sample2 - sample1);
            videoFrame = a * double(sample - sample1) + double(frame1);
            
            if videoFrame < 1
                videoFrame = 1;
            end
            
            videoFrame = uint32(videoFrame);
        end
        
        function sample = videoFrameToSample(obj, videoFrame)
            [frame1, sample1] = obj.getFirstSynchronizationPoint();
            [frame2, sample2] = obj.getLastSynchronizationPoint();
            
            a = double(sample2 - sample1) / double((frame2 - frame1));
            sample = a * double(videoFrame - frame1) + double(sample1);
            
            if sample < 1
                sample = 1;
            end
            
            sample = uint32(sample);
        end
    end
    
    methods (Access = private)
        
        function [sample, frame] = getFirstSynchronizationPoint(obj)
            samples = obj.synchronizationPointsMap.keys;
            frames = obj.synchronizationPointsMap.values;
            [~, minIdx] = min(cell2mat(obj.synchronizationPointsMap.keys));
            sample = samples{minIdx};
            frame = frames{minIdx};
        end
        
        function [sample, frame] = getLastSynchronizationPoint(obj)
            samples = obj.synchronizationPointsMap.keys;
            frames = obj.synchronizationPointsMap.values;
            [~, maxIdx] = max(cell2mat(obj.synchronizationPointsMap.keys));
            sample = samples{maxIdx};
            frame = frames{maxIdx};
        end
    end
end
