function varargout = PerformanceAssessmentDetailUI(varargin)
% PERFORMANCEASSESSMENTDETAILUI MATLAB code for PerformanceAssessmentDetailUI.fig
%      PERFORMANCEASSESSMENTDETAILUI, by itself, creates a new PERFORMANCEASSESSMENTDETAILUI or raises the existing
%      singleton*.
%
%      H = PERFORMANCEASSESSMENTDETAILUI returns the handle to a new PERFORMANCEASSESSMENTDETAILUI or the handle to
%      the existing singleton*.
%
%      PERFORMANCEASSESSMENTDETAILUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PERFORMANCEASSESSMENTDETAILUI.M with the given input arguments.
%
%      PERFORMANCEASSESSMENTDETAILUI('Property','Value',...) creates a new PERFORMANCEASSESSMENTDETAILUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PerformanceAssessmentDetailUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PerformanceAssessmentDetailUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PerformanceAssessmentDetailUI

% Last Modified by GUIDE v2.5 26-Apr-2019 14:14:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PerformanceAssessmentDetailUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PerformanceAssessmentDetailUI_OutputFcn, ...
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


% --- Executes just before PerformanceAssessmentDetailUI is made visible.
function PerformanceAssessmentDetailUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PerformanceAssessmentDetailUI (see VARARGIN)

% Choose default command line output for PerformanceAssessmentDetailUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PerformanceAssessmentDetailUI wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = PerformanceAssessmentDetailUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in signalsList.
function signalsList_Callback(hObject, eventdata, handles)
% hObject    handle to signalsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns signalsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from signalsList


% --- Executes during object creation, after setting all properties.
function signalsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to signalsList (see GCBO)
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


% --- Executes on selection change in signalComputerList.
function signalComputerList_Callback(hObject, eventdata, handles)
% hObject    handle to signalComputerList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns signalComputerList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from signalComputerList


% --- Executes during object creation, after setting all properties.
function signalComputerList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to signalComputerList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
