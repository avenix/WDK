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
        
        function obj = VideoPlayer(fileName,delegate,windowPosition)
            obj.videoPlayerHandle = implay(fileName);
            if nargin > 2
                obj.videoPlayerHandle.Parent.OuterPosition = windowPosition;
            end
            
            obj.delegate = delegate;
            obj.figureHandle = obj.videoPlayerHandle.Parent;
            obj.numFrames = str2double(obj.videoPlayerHandle.Visual.VideoInfo.PlaybackInfo.Widgets{2,2});
            obj.figureHandle.KeyPressFcn = @obj.handleKeyPress;
            obj.figureHandle.CloseRequestFcn = @obj.handleWindowClosed;
            obj.timer = timer('TimerFcn', @obj.timerTick,'Period',0.03,'ExecutionMode','fixedRate');
            start(obj.timer);
        end
        
        function frame = displayFrame(obj,frame)
            if frame > obj.numFrames
                frame = obj.numFrames;
            elseif frame < 1
                frame = 1;
            end
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
            if ~isempty(obj.delegate)
                obj.delegate.handleVideoPlayerFrameChanged(obj.currentFrame);
            end
        end
        
        function close(obj)
            close(obj.figureHandle);
        end
        
        function makeForeGround(obj)
            figure(obj.videoPlayerHandle.Parent);
        end
    end
    
    methods (Access = private)
        
        function timerTick(obj,~,~)
            if(obj.currentFrame ~= obj.previousFrame)
                obj.previousFrame = obj.currentFrame;
                if ~isempty(obj.delegate)
                    obj.delegate.handleVideoPlayerFrameChanged(obj.previousFrame,obj);
                end
            end
        end
        
        function handleWindowClosed(obj,~,~)
            stop(obj.timer);
            delete(obj.timer);
            delete(obj.figureHandle);
            if ~isempty(obj.delegate)
                obj.delegate.handleVideoPlayerWindowClosed(obj);
            end
        end
    end
end
