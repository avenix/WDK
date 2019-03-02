classdef DataAnnotationVideoPlayer < handle
    
    properties (Access = private)
        videoReader;
        plotAxes;
    end
    
    methods (Access = public)
        function obj = DataAnnotationVideoPlayer(fileName,plotAxes)
            obj.videoReader = VideoReader(fileName);
            obj.plotAxes = plotAxes;
        end
        
        function play(obj, frame)
            while hasFrame(obj.videoReader)
                obj.displayFrame(frame);
                obj.currAxes.Visible = 'off';
                pause(1/v.FrameRate);
            end
        end
        
        function displayFrame(obj, frame)
            obj.videoReader.CurrentTime = double(frame) / obj.videoReader.FrameRate;
            vidFrame = readFrame(obj.videoReader);
            image(vidFrame, 'Parent', obj.plotAxes);
        end
    end
end