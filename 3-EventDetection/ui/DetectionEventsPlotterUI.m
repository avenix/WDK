function varargout = DetectionEventsPlotterUI(varargin)
% DETECTIONEVENTSPLOTTERUI MATLAB code for DetectionEventsPlotterUI.fig
%      DETECTIONEVENTSPLOTTERUI, by itself, creates a new DETECTIONEVENTSPLOTTERUI or raises the existing
%      singleton*.
%
%      H = DETECTIONEVENTSPLOTTERUI returns the handle to a new DETECTIONEVENTSPLOTTERUI or the handle to
%      the existing singleton*.
%
%      DETECTIONEVENTSPLOTTERUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETECTIONEVENTSPLOTTERUI.M with the given input arguments.
%
%      DETECTIONEVENTSPLOTTERUI('Property','Value',...) creates a new DETECTIONEVENTSPLOTTERUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DetectionEventsPlotterUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DetectionEventsPlotterUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DetectionEventsPlotterUI

% Last Modified by GUIDE v2.5 25-Apr-2019 20:29:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DetectionEventsPlotterUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DetectionEventsPlotterUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DetectionEventsPlotterUI is made visible.
function DetectionEventsPlotterUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DetectionEventsPlotterUI (see VARARGIN)

% Choose default command line output for DetectionEventsPlotterUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DetectionEventsPlotterUI wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = DetectionEventsPlotterUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in filesList.
function filesList_Callback(hObject, eventdata, handles)
% hObject    handle to filesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filesList


% --- Executes during object creation, after setting all properties.
function filesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in visualizeButton.
function visualizeButton_Callback(hObject, eventdata, handles)
% hObject    handle to visualizeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in showDetectedCheckBox.
function showDetectedCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to showDetectedCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showDetectedCheckBox


% --- Executes on button press in showMissedCheckBox.
function showMissedCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to showMissedCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showMissedCheckBox


% --- Executes on button press in showFalsePositivesCheckBox.
function showFalsePositivesCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to showFalsePositivesCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showFalsePositivesCheckBox
