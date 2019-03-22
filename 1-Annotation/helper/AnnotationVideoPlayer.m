classdef AnnotationVideoPlayer < handle
    
    properties (Access = public)
        delegate;
    end
    
    properties (Access = private)
        videoPlayerHandle;
        figureHandle;
        timer;
        previousFrame;
    end
    
    properties (Dependent)
        currentFrame;
    end
    
    methods
        function f = get.currentFrame(obj)
            f = obj.videoPlayerHandle.DataSource.Controls.CurrentFrame;
        end
    end
    
    methods (Access = public)
        
        function obj = AnnotationVideoPlayer(fileName,delegate)
            obj.videoPlayerHandle = implay(fileName);
            obj.delegate = delegate;
            obj.figureHandle = obj.videoPlayerHandle.Parent;
            obj.figureHandle.KeyPressFcn = @obj.handleKeyPress;
            obj.timer = timer('TimerFcn', @obj.timerTick,'Period',0.03,'ExecutionMode','fixedRate');
            start(obj.timer);
        end
        
        function displayFrame(obj,frame)
            obj.videoPlayerHandle.DataSource.Controls.jumpTo(double(frame));
            obj.previousFrame = frame;
        end
        
        function handleKeyPress(obj, ~, event)
            switch event.Key
                case 'leftarrow'
                    obj.videoPlayerHandle.DataSource.Controls.stepBack();
                case 'rightarrow'
                    obj.videoPlayerHandle.DataSource.Controls.stepFwd();
                case 'space'
                    obj.videoPlayerHandle.DataSource.Controls.playPause();
            end
            obj.previousFrame = obj.currentFrame;
            obj.delegate.handleFrameChanged(obj.currentFrame);
        end
        
        function timerTick(obj,~,~)
            if(obj.currentFrame ~= obj.previousFrame)
                obj.previousFrame = obj.currentFrame;
                obj.delegate.handleFrameChanged(obj.previousFrame);
            end
        end
        
        function delete(obj)
            stop(obj.timer);
            delete(obj.timer);
            close(obj.figureHandle);
        end
    end
end
