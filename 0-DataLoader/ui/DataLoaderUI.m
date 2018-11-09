function varargout = DataLoaderUI(varargin)
% DATALOADERUI MATLAB code for DataLoaderUI.fig
%      DATALOADERUI, by itself, creates a new DATALOADERUI or raises the existing
%      singleton*.
%
%      H = DATALOADERUI returns the handle to a new DATALOADERUI or the handle to
%      the existing singleton*.
%
%      DATALOADERUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATALOADERUI.M with the given input arguments.
%
%      DATALOADERUI('Property','Value',...) creates a new DATALOADERUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataLoaderUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataLoaderUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataLoaderUI

% Last Modified by GUIDE v2.5 03-Nov-2018 10:15:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataLoaderUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DataLoaderUI_OutputFcn, ...
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


% --- Executes just before DataLoaderUI is made visible.
function DataLoaderUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataLoaderUI (see VARARGIN)

% Choose default command line output for DataLoaderUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataLoaderUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DataLoaderUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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


% --- Executes on button press in loadDataButton.
function loadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadBinaryDataButton.
function loadBinaryDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadBinaryDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadTextDataButton.
function loadTextDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadTextDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveDataButton.
function saveDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveDataTextButton.
function saveDataTextButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveDataTextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkDataLossButton.
function checkDataLossButton_Callback(hObject, eventdata, handles)
% hObject    handle to checkDataLossButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function startText_Callback(hObject, eventdata, handles)
% hObject    handle to startText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startText as text
%        str2double(get(hObject,'String')) returns contents of startText as a double


% --- Executes during object creation, after setting all properties.
function startText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cutDataButton.
function cutDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to cutDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function endText_Callback(hObject, eventdata, handles)
% hObject    handle to endText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endText as text
%        str2double(get(hObject,'String')) returns contents of endText as a double


% --- Executes during object creation, after setting all properties.
function endText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in printStatisticsButton.
function printStatisticsButton_Callback(hObject, eventdata, handles)
% hObject    handle to printStatisticsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in variablesList.
function variablesList_Callback(hObject, eventdata, handles)
% hObject    handle to variablesList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns variablesList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variablesList


% --- Executes during object creation, after setting all properties.
function variablesList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variablesList (see GCBO)
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



function tsIntervalText_Callback(hObject, eventdata, handles)
% hObject    handle to tsIntervalText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tsIntervalText as text
%        str2double(get(hObject,'String')) returns contents of tsIntervalText as a double


% --- Executes during object creation, after setting all properties.
function tsIntervalText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tsIntervalText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
