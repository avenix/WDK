function varargout = AnnotationUI(varargin)
% DATAANNOTATIONUI MATLAB code for AnnotationUI.fig
%      DATAANNOTATIONUI, by itself, creates a new DATAANNOTATIONUI or raises the existing
%      singleton*.
%
%      H = DATAANNOTATIONUI returns the handle to a new DATAANNOTATIONUI or the handle to
%      the existing singleton*.
%
%      DATAANNOTATIONUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAANNOTATIONUI.M with the given input arguments.
%
%      DATAANNOTATIONUI('Property','Value',...) creates a new DATAANNOTATIONUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnnotationUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnnotationUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnnotationUI

% Last Modified by GUIDE v2.5 11-Dec-2019 10:16:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnnotationUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AnnotationUI_OutputFcn, ...
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


% --- Executes just before AnnotationUI is made visible.
function AnnotationUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnnotationUI (see VARARGIN)

% Choose default command line output for AnnotationUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnnotationUI wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = AnnotationUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in classesList.
function classesList_Callback(hObject, eventdata, handles)
% hObject    handle to classesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns classesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from classesList


% --- Executes during object creation, after setting all properties.
function classesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to classesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fileNamesList.
function fileNamesList_Callback(hObject, eventdata, handles)
% hObject    handle to fileNamesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileNamesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileNamesList


% --- Executes during object creation, after setting all properties.
function fileNamesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNamesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showMarkersCheckBox.
function showMarkersCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to showMarkersCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showMarkersCheckBox


% --- Executes on button press in laxCheckBox.
function laxCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to laxCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of laxCheckBox


% --- Executes on button press in layCheckBox.
function layCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to layCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of layCheckBox


% --- Executes on button press in lazCheckBox.
function lazCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to lazCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lazCheckBox


% --- Executes on button press in energyCheckBox.
function energyCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to energyCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of energyCheckBox


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in findPeaksButton.
function findPeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to findPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on button press in addRangeAnnotationButton.
function addRangeAnnotationButton_Callback(hObject, eventdata, handles)
% hObject    handle to addRangeAnnotationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in peaksCheckBox.
function peaksCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to peaksCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of peaksCheckBox


% --- Executes on button press in myCheckbox.
function myCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to myCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of myCheckbox


% --- Executes on key press with focus on mainFigure or any of its controls.
function mainFigure_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to mainFigure (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in showRangesCheckBox.
function showRangesCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to showRangesCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showRangesCheckBox


% --- Executes on button press in showEventsCheckBox.
function showEventsCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to showEventsCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showEventsCheckBox


% --- Executes on button press in visualizeButton.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to visualizeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in addSignalButton.
function addSignalButton_Callback(hObject, eventdata, handles)
% hObject    handle to addSignalButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in selectAllCheckBox.
function selectAllCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to selectAllCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectAllCheckBox


% --- Executes on button press in loadVideoCheckBox.
function loadVideoCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to loadVideoCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadVideoCheckBox


% --- Executes on button press in videoSynchronizationButton.
function videoSynchronizationButton_Callback(hObject, eventdata, handles)
% hObject    handle to videoSynchronizationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in synchronizeVideoCheckBox.
function synchronizeVideoCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to synchronizeVideoCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of synchronizeVideoCheckBox



function currentSampleText_Callback(hObject, eventdata, handles)
% hObject    handle to currentSampleText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentSampleText as text
%        str2double(get(hObject,'String')) returns contents of currentSampleText as a double


% --- Executes during object creation, after setting all properties.
function currentSampleText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentSampleText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in suggestAnnotationsCheckBox.
function suggestAnnotationsCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to suggestAnnotationsCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of suggestAnnotationsCheckBox
