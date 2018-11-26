function varargout = classifierAppUI(varargin)
% CLASSIFIERAPPUI MATLAB code for classifierAppUI.fig
%      CLASSIFIERAPPUI, by itself, creates a new CLASSIFIERAPPUI or raises the existing
%      singleton*.
%
%      H = CLASSIFIERAPPUI returns the handle to a new CLASSIFIERAPPUI or the handle to
%      the existing singleton*.
%
%      CLASSIFIERAPPUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLASSIFIERAPPUI.M with the given input arguments.
%
%      CLASSIFIERAPPUI('Property','Value',...) creates a new CLASSIFIERAPPUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before classifierAppUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to classifierAppUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help classifierAppUI

% Last Modified by GUIDE v2.5 24-Nov-2018 09:54:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @classifierAppUI_OpeningFcn, ...
                   'gui_OutputFcn',  @classifierAppUI_OutputFcn, ...
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


% --- Executes just before classifierAppUI is made visible.
function classifierAppUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to classifierAppUI (see VARARGIN)

% Choose default command line output for classifierAppUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes classifierAppUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = classifierAppUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in trainList.
function trainList_Callback(hObject, eventdata, handles)
% hObject    handle to trainList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns trainList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trainList


% --- Executes during object creation, after setting all properties.
function trainList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trainList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in testList.
function testList_Callback(hObject, eventdata, handles)
% hObject    handle to testList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns testList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from testList


% --- Executes during object creation, after setting all properties.
function testList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in moveFileRightButton.
function moveFileRightButton_Callback(hObject, eventdata, handles)
% hObject    handle to moveFileRightButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in moveFileLeftButton.
function moveFileLeftButton_Callback(hObject, eventdata, handles)
% hObject    handle to moveFileLeftButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in createTableButton.
function createTableButton_Callback(hObject, eventdata, handles)
% hObject    handle to createTableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in printTrainTableButton.
function printTrainTableButton_Callback(hObject, eventdata, handles)
% hObject    handle to printTrainTableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in printTestTableButton.
function printTestTableButton_Callback(hObject, eventdata, handles)
% hObject    handle to printTestTableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in groupButton.
function groupButton_Callback(hObject, eventdata, handles)
% hObject    handle to groupButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in classifyButton.
function classifyButton_Callback(hObject, eventdata, handles)
% hObject    handle to classifyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function nFeaturesText_Callback(hObject, eventdata, handles)
% hObject    handle to nFeaturesText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nFeaturesText as text
%        str2double(get(hObject,'String')) returns contents of nFeaturesText as a double


% --- Executes during object creation, after setting all properties.
function nFeaturesText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nFeaturesText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in findFeaturesButton.
function findFeaturesButton_Callback(hObject, eventdata, handles)
% hObject    handle to findFeaturesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function featuresText_Callback(hObject, eventdata, handles)
% hObject    handle to featuresText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of featuresText as text
%        str2double(get(hObject,'String')) returns contents of featuresText as a double


% --- Executes during object creation, after setting all properties.
function featuresText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to featuresText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectFeaturesButton.
function selectFeaturesButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectFeaturesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exportButton.
function exportButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exportNormalTableRadio.
function exportNormalTableRadio_Callback(hObject, eventdata, handles)
% hObject    handle to exportNormalTableRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of exportNormalTableRadio


% --- Executes on button press in exportGroupedTableRadio.
function exportGroupedTableRadio_Callback(hObject, eventdata, handles)
% hObject    handle to exportGroupedTableRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of exportGroupedTableRadio


% --- Executes on button press in shouldNormalizeFeaturesCheck.
function shouldNormalizeFeaturesCheck_Callback(hObject, eventdata, handles)
% hObject    handle to shouldNormalizeFeaturesCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shouldNormalizeFeaturesCheck


% --- Executes on button press in printGroupedTrainTableButton.
function printGroupedTrainTableButton_Callback(hObject, eventdata, handles)
% hObject    handle to printGroupedTrainTableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in printGroupedTestTableButton.
function printGroupedTestTableButton_Callback(hObject, eventdata, handles)
% hObject    handle to printGroupedTestTableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in normalizeButton.
function normalizeButton_Callback(hObject, eventdata, handles)
% hObject    handle to normalizeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in printFeatures.
function printFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to printFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function leftSegmentSizeText_Callback(hObject, eventdata, handles)
% hObject    handle to leftSegmentSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of leftSegmentSizeText as text
%        str2double(get(hObject,'String')) returns contents of leftSegmentSizeText as a double


% --- Executes during object creation, after setting all properties.
function leftSegmentSizeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftSegmentSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rightSegmentSizeText_Callback(hObject, eventdata, handles)
% hObject    handle to rightSegmentSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rightSegmentSizeText as text
%        str2double(get(hObject,'String')) returns contents of rightSegmentSizeText as a double


% --- Executes during object creation, after setting all properties.
function rightSegmentSizeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rightSegmentSizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in regroupButton.
function regroupButton_Callback(hObject, eventdata, handles)
% hObject    handle to regroupButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on selection change in regroupingLabelingStrategyList.
function regroupingLabelingStrategyList_Callback(hObject, eventdata, handles)
% hObject    handle to regroupingLabelingStrategyList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns regroupingLabelingStrategyList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regroupingLabelingStrategyList


% --- Executes during object creation, after setting all properties.
function regroupingLabelingStrategyList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regroupingLabelingStrategyList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
