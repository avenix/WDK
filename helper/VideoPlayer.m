classdef VideoPlayer < handle
    
    properties (Access = public)
        delegate;
    end
    
    properties (Access = private)
        videoPlayerHandle;
        figureHandle;
        timer;
        previousFrame;
    end
    
    properties (GetAccess = public)
        numFrames;
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
        
        function obj = VideoPlayer(fileName,delegate)
            obj.videoPlayerHandle = implay(fileName);
            obj.delegate = delegate;
            obj.figureHandle = obj.videoPlayerHandle.Parent;
            obj.numFrames = str2double(obj.videoPlayerHandle.Visual.VideoInfo.PlaybackInfo.Widgets{2,2});
            obj.figureHandle.KeyPressFcn = @obj.handleKeyPress;
            obj.figureHandle.CloseRequestFcn = @obj.handleWindowClosed;
            obj.timer = timer('TimerFcn', @obj.timerTick,'Period',0.03,'ExecutionMode','fixedRate');
            start(obj.timer);
        end
        
        function displayFrame(obj,frame)
            if frame < obj.numFrames
                obj.videoPlayerHandle.DataSource.Controls.jumpTo(double(frame));
                obj.previousFrame = frame;
            end
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
        
        function close(obj)
            close(obj.figureHandle);
        end
    end
    
    methods (Access = private)
        
        function timerTick(obj,~,~)
            if(obj.currentFrame ~= obj.previousFrame)
                obj.previousFrame = obj.currentFrame;
                obj.delegate.handleFrameChanged(obj.previousFrame);
            end
        end
        
        function handleWindowClosed(obj,~,~)
            stop(obj.timer);
            delete(obj.timer);
            delete(obj.figureHandle);
            obj.delegate.handleVideoPlayerWindowClosed();
        end
    end
end
