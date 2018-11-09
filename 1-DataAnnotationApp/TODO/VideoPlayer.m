close all;
close;

[hFig, hAxes] = createFigureAndAxes();

%videoReader = VideoReader('lukasTest.mov');

videoReader = VideoReader('lukasTest.mov', 'ImageColorSpace', 'Intensity');

[hFig, hAxes] = createFigureAndAxes();

insertButtons(hFig, hAxes, videoSrc);

frame = getAndProcessFrame(videoSrc, 0);
showFrameOnAxis(hAxes.axis1, frame);
showFrameOnAxis(hAxes.axis2, zeros(size(frame)+60,'uint8'));

function [hFig, hAxes] = createFigureAndAxes()

% Close figure opened by last run
figTag = 'CVST_VideoOnAxis_9804532';
close(findobj('tag',figTag));

% Create new figure
hFig = figure('numbertitle', 'off', ...
    'name', 'Video In Custom GUI', ...
    'menubar','none', ...
    'toolbar','none', ...
    'resize', 'on', ...
    'tag',figTag, ...
    'renderer','painters', ...
    'position',[680 678 480 240],...
    'HandleVisibility','callback'); % hide the handle to prevent unintended modifications of our custom UI

% Create axes and titles
hAxes.axis1 = createPanelAxisTitle(hFig,[0.1 0.2 0.36 0.6],'Original Video'); % [X Y W H]
hAxes.axis2 = createPanelAxisTitle(hFig,[0.5 0.2 0.36 0.6],'Rotated Video');

end

function hAxis = createPanelAxisTitle(hFig, pos, axisTitle)

% Create panel
hPanel = uipanel('parent',hFig,'Position',pos,'Units','Normalized');

% Create axis
hAxis = axes('position',[0 0 1 1],'Parent',hPanel);
hAxis.XTick = [];
hAxis.YTick = [];
hAxis.XColor = [1 1 1];
hAxis.YColor = [1 1 1];
% Set video title using uicontrol. uicontrol is used so that text
% can be positioned in the context of the figure, not the axis.
titlePos = [pos(1)+0.02 pos(2)+pos(3)+0.3 0.3 0.07];
uicontrol('style','text',...
    'String', axisTitle,...
    'Units','Normalized',...
    'Parent',hFig,'Position', titlePos,...
    'BackgroundColor',hFig.Color);
end


function insertButtons(hFig,hAxes,videoSrc)

% Play button with text Start/Pause/Continue
uicontrol(hFig,'unit','pixel','style','pushbutton','string','Start',...
    'position',[10 10 75 25], 'tag','PBButton123','callback',...
    {@playCallback,videoSrc,hAxes});

% Exit button with text Exit
uicontrol(hFig,'unit','pixel','style','pushbutton','string','Exit',...
    'position',[100 10 50 25],'callback', ...
    {@exitCallback,videoSrc,hFig});
end

function playCallback(hObject,~,videoSrc,hAxes)
try
    % Check the status of play button
    isTextStart = strcmp(hObject.String,'Start');
    isTextCont  = strcmp(hObject.String,'Continue');
    if isTextStart
        % Two cases: (1) starting first time, or (2) restarting
        % Start from first frame
        if isDone(videoSrc)
            reset(videoSrc);
        end
    end
    if (isTextStart || isTextCont)
        hObject.String = 'Pause';
    else
        hObject.String = 'Continue';
    end
    
    % Rotate input video frame and display original and rotated
    % frames on figure
    angle = 0;
    while strcmp(hObject.String, 'Pause') && ~isDone(videoSrc)
        % Get input video frame and rotated frame
        [frame,rotatedImg,angle] = getAndProcessFrame(videoSrc,angle);
        % Display input video frame on axis
        showFrameOnAxis(hAxes.axis1, frame);
        % Display rotated video frame on axis
        showFrameOnAxis(hAxes.axis2, rotatedImg);
    end
    
    % When video reaches the end of file, display "Start" on the
    % play button.
    if isDone(videoSrc)
        hObject.String = 'Start';
    end
catch ME
    % Re-throw error message if it is not related to invalid handle
    if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
        rethrow(ME);
    end
end
end

function exitCallback(~,~,videoSrc,hFig)

% Close the video file
release(videoSrc);
% Close the figure window
close(hFig);
end

function [frame,rotatedImg,angle] = getAndProcessFrame(videoSrc,angle)

% Read input video frame
frame = step(videoSrc);

% Pad and rotate input video frame
paddedFrame = padarray(frame, [30 30], 0, 'both');
rotatedImg  = imrotate(paddedFrame, angle, 'bilinear', 'crop');
angle       = angle + 1;
end