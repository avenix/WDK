classdef AnnotationVideoPlayer < handle
    
    properties (SetAccess = private, GetAccess = public)
        currentFrame = 1;
    end
    
    properties (Constant)
        BigScroll = 30;
    end
    
    properties (Access = public)
        delegate;
    end
    
    properties (Access = private)
        videoReader;
        plotAxes;
        figureHandle;
        playTimer;
        scrollBarHandles;
        scrollBarFunction;
        click;
        scrollBarWidth;
    end
    
    properties (Dependent)
        frameRate;
        numFrames;
    end
    
    methods
        function frameRate = get.frameRate(obj)
            frameRate = obj.videoReader.FrameRate;
        end
        
        function numFrames = get.numFrames(obj)
            numFrames = obj.videoReader.NumberOfFrames;
        end
    end
    
    methods (Access = public)
        
        function obj = AnnotationVideoPlayer(fileName,delegate)
            obj.delegate = delegate;
            fprintf('%s - %s\n',Constants.kLoadingVideoMessage,fileName);
            obj.videoReader = VideoReader(fileName);            
            videoTitle = sprintf('Reference Video: %s',fileName);
            obj.createFigure(videoTitle);
        end
        
        function displayFrame(obj,frame)
            f = obj.videoReader.read(frame);
            image(obj.plotAxes,f);
            set(obj.plotAxes,'DataAspectRatio',[1 1 1]);
            set(obj.plotAxes,'DataAspectRatioMode','manual');
            set(obj.plotAxes,'Visible','off');
            obj.currentFrame = frame;
        end
        
        function handleKeyPress(obj, ~, event)
            switch event.Key
                case 'leftarrow'
                    obj.scroll(obj.currentFrame - 1);
                case 'rightarrow'
                    obj.scroll(obj.currentFrame + 1);
                case 'pageup'
                    if obj.currentFrame - obj.BigScroll < 1
                        obj.scroll(1);
                    else
                        obj.scroll(obj.currentFrame - obj.BigScroll);
                    end
                case 'pagedown'
                    if obj.currentFrame + obj.BigScroll > obj.numFrames
                        obj.scroll(obj.numFrames);
                    else
                        obj.scroll(obj.currentFrame + obj.BigScroll);
                    end
                case 'home'
                    obj.scroll(1);
                case 'end'
                    obj.scroll(obj.numFrames);
                case 'space'
                    timeInterval = floor((1/obj.frameRate) * 1000) / 1000;
                    obj.play(timeInterval);
            end
        end
        
        function delete(obj)
            close(obj.figureHandle);
            delete(obj.playTimer);
        end
    end
    
    methods (Access = private)
        function createFigure(obj,videoTitle)
            
            obj.click = 0;
            obj.currentFrame = 1;  %current frame
            
            %initialize figure
            obj.figureHandle = figure('Name',videoTitle,'Color',[.3 .3 .3], 'MenuBar','none', 'Units','norm', ...
                'WindowButtonDownFcn',@obj.handleButtonDown, 'WindowButtonUpFcn',@obj.handleButtonUp, ...
                'WindowButtonMotionFcn', @obj.handleClick, 'KeyPressFcn', @obj.handleKeyPress);
            
            %axes for scroll bar
            scrollAxesHandle = axes('Parent',obj.figureHandle, 'Position',[0 0 1 0.03], ...
                'Visible','off', 'Units', 'normalized');
            axis([0 1 0 1]);
            axis off
            
            %scroll bar
            obj.scrollBarWidth = max(1 / obj.numFrames, 0.01);
            scroll_handle = patch([0 1 1 0] * obj.scrollBarWidth, [0 0 1 1], [.8 .8 .8], ...
                'Parent',scrollAxesHandle, 'EdgeColor','none', 'ButtonDownFcn', @obj.handleClick);
            
            %timer to play video
            obj.playTimer = timer('TimerFcn',@obj.playTimerCallback, 'ExecutionMode','fixedRate');
            
            %main drawing axes for video display
            obj.plotAxes = axes('Position',[0 0.03 1 0.97],'Parent',obj.figureHandle);
            
            set(obj.figureHandle,'CurrentAxes',obj.plotAxes);
            
            %return handles
            obj.scrollBarHandles = [scrollAxesHandle; scroll_handle];
            obj.scrollBarFunction = @obj.scroll;
            
        end
        
        function handleFrameChanged(obj,frame)
            obj.displayFrame(frame);
            obj.delegate.handleFrameChanged(frame);
        end
        
        %mouse handler
        function handleButtonDown(obj,src, ~)
            set(src,'Units','norm')
            pos = get(src, 'CurrentPoint');
            if pos(2) <= 0.03
                obj.click = 1;
                obj.handleClick([],[]);
            end
        end
        
        function handleButtonUp(obj,~,~)
            obj.click = 0;
        end
        
        function handleClick(obj,~,~)
            if obj.click == 0
                return;
            end
            
            set(obj.figureHandle, 'Units', 'normalized');
            position = get(obj.figureHandle, 'CurrentPoint');
            set(obj.figureHandle, 'Units', 'pixels');
            x = position(1);
            
            newFrame = floor(1 + x * obj.numFrames);
            
            if newFrame > 1 && newFrame <= obj.numFrames && newFrame ~= obj.currentFrame
                obj.scroll(newFrame);
            end
        end
        
        function play(obj,interval)
            if strcmp(get(obj.playTimer,'Running'), 'off')
                set(obj.playTimer, 'Period', interval);
                start(obj.playTimer);
            else
                stop(obj.playTimer);
            end
        end
        
        function playTimerCallback(obj, ~, ~)
            if obj.currentFrame < obj.numFrames
                obj.scroll(obj.currentFrame + 1);
            elseif strcmp(get(obj.playTimer,'Running'), 'on')
                obj.stop(obj.playTimer);
            end
        end
        
        function scroll(obj,newFrame)
            if newFrame >= 1 && newFrame <= obj.numFrames
                
                obj.currentFrame = newFrame;
                
                scrollX = (double(obj.currentFrame) - 1) / obj.numFrames;
                
                set(obj.scrollBarHandles(2), 'XData', double(scrollX) + [0 1 1 0] * obj.scrollBarWidth);
                
                obj.handleFrameChanged(obj.currentFrame);
                
                pause(0.001);
            end
        end
    end
end
