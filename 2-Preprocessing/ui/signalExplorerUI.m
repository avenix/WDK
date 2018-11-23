function varargout = signalExplorerUI(varargin)
% SIGNALEXPLORERUI MATLAB code for signalExplorerUI.fig
%      SIGNALEXPLORERUI, by itself, creates a new SIGNALEXPLORERUI or raises the existing
%      singleton*.
%
%      H = SIGNALEXPLORERUI returns the handle to a new SIGNALEXPLORERUI or the handle to
%      the existing singleton*.
%
%      SIGNALEXPLORERUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIGNALEXPLORERUI.M with the given input arguments.
%
%      SIGNALEXPLORERUI('Property','Value',...) creates a new SIGNALEXPLORERUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before signalExplorerUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to signalExplorerUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help signalExplorerUI

% Last Modified by GUIDE v2.5 23-Nov-2018 14:48:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @signalExplorerUI_OpeningFcn, ...
                   'gui_OutputFcn',  @signalExplorerUI_OutputFcn, ...
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


% --- Executes just before signalExplorerUI is made visible.
function signalExplorerUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to signalExplorerUI (see VARARGIN)

% Choose default command line output for signalExplorerUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes signalExplorerUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = signalExplorerUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in manualSegmentationRadio.
function manualSegmentationRadio_Callback(hObject, eventdata, handles)
% hObject    handle to manualSegmentationRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manualSegmentationRadio


% --- Executes on button press in simpleSegmentationRadio.
function simpleSegmentationRadio_Callback(hObject, eventdata, handles)
% hObject    handle to simpleSegmentationRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of simpleSegmentationRadio



function leftTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to leftTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of leftTextBox as text
%        str2double(get(hObject,'String')) returns contents of leftTextBox as a double


% --- Executes during object creation, after setting all properties.
function leftTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rightTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to rightTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rightTextBox as text
%        str2double(get(hObject,'String')) returns contents of rightTextBox as a double


% --- Executes during object creation, after setting all properties.
function rightTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rightTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in visualizeButton.
function visualizeButton_Callback(hObject, eventdata, handles)
% hObject    handle to visualizeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in createButton.
function createButton_Callback(hObject, eventdata, handles)
% hObject    handle to createButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in groupButton.
function groupButton_Callback(hObject, eventdata, handles)
% hObject    handle to groupButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on selection change in signalsListVisualization.
function signalsListVisualization_Callback(hObject, eventdata, handles)
% hObject    handle to signalsListVisualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns signalsListVisualization contents as cell array
%        contents{get(hObject,'Value')} returns selected item from signalsListVisualization


% --- Executes during object creation, after setting all properties.
function signalsListVisualization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to signalsListVisualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in applyFilterButton.
function applyFilterButton_Callback(hObject, eventdata, handles)
% hObject    handle to applyFilterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function lowPassCutoffTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to lowPassCutoffTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowPassCutoffTextBox as text
%        str2double(get(hObject,'String')) returns contents of lowPassCutoffTextBox as a double


% --- Executes during object creation, after setting all properties.
function lowPassCutoffTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowPassCutoffTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lowPassOrderTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to lowPassOrderTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowPassOrderTextBox as text
%        str2double(get(hObject,'String')) returns contents of lowPassOrderTextBox as a double


% --- Executes during object creation, after setting all properties.
function lowPassOrderTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowPassOrderTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function highPassCutoffTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to highPassCutoffTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highPassCutoffTextBox as text
%        str2double(get(hObject,'String')) returns contents of highPassCutoffTextBox as a double


% --- Executes during object creation, after setting all properties.
function highPassCutoffTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highPassCutoffTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function highPassOrderTextBox_Callback(hObject, eventdata, handles)
% hObject    handle to highPassOrderTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of highPassOrderTextBox as text
%        str2double(get(hObject,'String')) returns contents of highPassOrderTextBox as a double


% --- Executes during object creation, after setting all properties.
function highPassOrderTextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highPassOrderTextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sameScaleCheckBox.
function sameScaleCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to sameScaleCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sameScaleCheckBox


% --- Executes on button press in detectButton.
function detectButton_Callback(hObject, eventdata, handles)
% hObject    handle to detectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in detectionFiltersList.
function detectionFiltersList_Callback(hObject, eventdata, handles)
% hObject    handle to detectionFiltersList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns detectionFiltersList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from detectionFiltersList


% --- Executes during object creation, after setting all properties.
function detectionFiltersList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detectionFiltersList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in detectionSignalsList.
function detectionSignalsList_Callback(hObject, eventdata, handles)
% hObject    handle to detectionSignalsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns detectionSignalsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from detectionSignalsList


% --- Executes during object creation, after setting all properties.
function detectionSignalsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detectionSignalsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function peakDetectionResultsTextbox_Callback(hObject, eventdata, handles)
% hObject    handle to peakDetectionResultsTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peakDetectionResultsTextbox as text
%        str2double(get(hObject,'String')) returns contents of peakDetectionResultsTextbox as a double


% --- Executes during object creation, after setting all properties.
function peakDetectionResultsTextbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakDetectionResultsTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in eventDetectorList.
function eventDetectorList_Callback(hObject, eventdata, handles)
% hObject    handle to eventDetectorList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eventDetectorList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventDetectorList


% --- Executes during object creation, after setting all properties.
function eventDetectorList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventDetectorList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in manualSegmentationCheckBox.
function manualSegmentationCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to manualSegmentationCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manualSegmentationCheckBox


% --- Executes on button press in automaticSegmentationCheckBox.
function automaticSegmentationCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to automaticSegmentationCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of automaticSegmentationCheckBox


% --- Executes on selection change in signalComputersListVisualization.
function signalComputersListVisualization_Callback(hObject, eventdata, handles)
% hObject    handle to signalComputersListVisualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns signalComputersListVisualization contents as cell array
%        contents{get(hObject,'Value')} returns selected item from signalComputersListVisualization


% --- Executes during object creation, after setting all properties.
function signalComputersListVisualization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to signalComputersListVisualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filterVariablesList.
function filterVariablesList_Callback(hObject, eventdata, handles)
% hObject    handle to filterVariablesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filterVariablesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filterVariablesList


% --- Executes during object creation, after setting all properties.
function filterVariablesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterVariablesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in labelingStrategiesList.
function labelingStrategiesList_Callback(hObject, eventdata, handles)
% hObject    handle to labelingStrategiesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns labelingStrategiesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from labelingStrategiesList


% --- Executes during object creation, after setting all properties.
function labelingStrategiesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelingStrategiesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in preprocessingSignalsList.
function preprocessingSignalsList_Callback(hObject, eventdata, handles)
% hObject    handle to preprocessingSignalsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns preprocessingSignalsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from preprocessingSignalsList


% --- Executes during object creation, after setting all properties.
function preprocessingSignalsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preprocessingSignalsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in preprocessingSignalComputerList.
function preprocessingSignalComputerList_Callback(hObject, eventdata, handles)
% hObject    handle to preprocessingSignalComputerList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns preprocessingSignalComputerList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from preprocessingSignalComputerList


% --- Executes during object creation, after setting all properties.
function preprocessingSignalComputerList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preprocessingSignalComputerList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
