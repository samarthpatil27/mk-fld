function varargout = fld(varargin)
% FLD MATLAB code for fld.fig
%      FLD, by itself, creates a new FLD or raises the existing
%      singleton*.
%
%      H = FLD returns the handle to a new FLD or the handle to
%      the existing singleton*.
%
%      FLD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLD.M with the given input arguments.
%
%      FLD('Property','Value',...) creates a new FLD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fld_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fld_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fld

% Last Modified by GUIDE v2.5 25-Jul-2016 09:20:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @fld_OpeningFcn, ...
    'gui_OutputFcn',  @fld_OutputFcn, ...
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


% --- Executes just before fld is made visible.
function fld_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fld (see VARARGIN)

% Choose default command line output for fld
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fld wait for user response (see UIRESUME)
% uiwait(handles.figure1);
m_init(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = fld_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_start_Callback(hObject, eventdata, handles)
% hObject    handle to menu_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_start_solver_Callback(hObject, eventdata, handles)
% hObject    handle to menu_start_solver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Start UI for solver, not the real solver
fld_solver


% --------------------------------------------------------------------
function menu_start_post_process_Callback(hObject, eventdata, handles)
% hObject    handle to menu_start_post_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp(' [INFO] Clean up timers');
timer_update_time_used = getappdata(handles.figure1,'timer_update_time_used');
stop(timer_update_time_used);
delete(timer_update_time_used);

% --- Executes during object creation, after setting all properties.
function list_log_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function m_init(hObject, handles)
clc;
% Init the log listbox
set(handles.list_log,'String',{' [INFO] mk-fld GUI initialized'});
m_init_timer(handles);
m_get_materials(handles);
handles.selected_material = 'dummy';
guidata(hObject, handles);

function m_log(msg, handles)
% First log to console
disp(msg);
str = get(handles.list_log,'String');
str{end + 1} = msg;
set(handles.list_log,'String',str);

function m_log_info(msg, handles)
% NOTE: using strcat('[INFO] ', msg) will loose the trailing space
m_log(strcat([' [INFO] ',msg]), handles)

function m_log_error(msg, handles)
m_log(strcat([' [ERROR] ',msg]), handles)

function m_init_timer(handles)
start_time = tic;
handles.start_time = start_time;

% timer to update GUI time
timer_update_time_used = timer('StartDelay', 1, 'Period', 1, ...
    'ExecutionMode', 'fixedDelay');
timer_update_time_used.TimerFcn = {@m_update_timer, handles};

setappdata(handles.figure1,'timer_update_time_used',timer_update_time_used);
start(timer_update_time_used);
m_log_info('timer started',handles);


function m_update_timer(obj, event, handles)
% disp(toc);
% TODO: should properly format time
set(handles.text_time_used, 'String', round(toc(handles.start_time)));

function m_get_materials(handles)
try
    m_log_info('Fetching materials', handles);
    url = 'http://localhost:8000/materials';
    materials = urlread(url);
    % TODO: put materials on list box
    materials = loadjson(materials);
    m_log_info('Got materials', handles);
    % disp(materials);
    set(handles.list_materials, 'String', materials);
catch ex
    m_log_error(ex.message, handles);
    % disp(ex.message);
end

function m_get_material_detail(material, handles)
m_log_info(material, handles);
try
    m_log_info('Fetching material detail', handles);
    url = strcat('http://localhost:8000/materials/', material);
    materialData = urlread(url);
    materialData = loadjson(materialData);
    set(handles.label_material, 'String', materialData.name);
    disp(materialData);
    % Show material data in table
    disp(materialData.r);
    % NOTE: jsonlab can not parse numeric key value
    data = {'name', materialData.name;
        'r0', materialData.r.zero;
        'r45', materialData.r.forty;
        'r90', materialData.r.nighty};
    set(handles.table_material, 'Data', data);
    % NOTE: in order to fix the following, value must be set to 1
    % Warning: 'popupmenu' control requires that 'Value' be an integer within String range
    % Control will not be rendered until all of its parameter values are valid
    set(handles.select_hardening, 'Value', 1);
    set(handles.select_hardening, 'String', materialData.hardening);
    set(handles.select_yield, 'Value', 1);
    set(handles.select_yield, 'String', materialData.yield);
    setappdata(handles.figure1,'current_material', materialData);
catch ex
    m_log_error(ex.message, handles);
end

% --- Executes on selection change in list_materials.
function list_materials_Callback(hObject, eventdata, handles)
% hObject    handle to list_materials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list_materials contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_materials

index_selected = get(hObject,'Value');
list = get(hObject,'String');
material = list{index_selected};
if strcmp(handles.selected_material, material)
    m_log_info('Already selected, ignore', handles);
    return;
end
handles.selected_material = material;
guidata(hObject, handles);
m_get_material_detail(material, handles);


% --- Executes during object creation, after setting all properties.
function list_materials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_materials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_materials_refresh.
function btn_materials_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to btn_materials_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

m_get_materials(handles)


% --- Executes on selection change in select_hardening.
function select_hardening_Callback(hObject, eventdata, handles)
% hObject    handle to select_hardening (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_hardening contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_hardening
currentMaterial = getappdata(handles.figure1,'current_material');
index_selected = get(hObject,'Value');
list = get(hObject,'String');
selectedHardening = list{index_selected};
% disp(currentMaterial);
% disp('selected hardening law is');
% disp(selectedHardening);
% disp(currentMaterial.(selectedHardening));
% show map as kv in table
% disp(class(currentMaterial.(selectedHardening)));
hardeningData = currentMaterial.(selectedHardening);
transformed = u_struct2cell(hardeningData);
set(handles.table_hardening, 'Data', transformed);
setappdata(handles.figure1,'current_hardening', selectedHardening);

% --- Executes during object creation, after setting all properties.
function select_hardening_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_hardening (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in select_yield.
function select_yield_Callback(hObject, eventdata, handles)
% hObject    handle to select_yield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_yield contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_yield
currentMaterial = getappdata(handles.figure1,'current_material');
index_selected = get(hObject,'Value');
list = get(hObject,'String');
selectedYield = list{index_selected};
yieldData = currentMaterial.(selectedYield);
transformed = u_struct2cell(yieldData);
set(handles.table_yield, 'Data', transformed);
setappdata(handles.figure1,'current_yield', selectedYield);

% --- Executes during object creation, after setting all properties.
function select_yield_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_yield (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function transformed = u_struct2cell(s)
names = fieldnames(s);
transformed = cell([length(names) 2]);
transformed(:,1) = names;
transformed(:,2) = struct2cell(s);


% --------------------------------------------------------------------
function menu_file_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Generate name base on timestamp
name = strcat(datestr(clock,'yyyy-mm-dd-HH-MM'),'-',datestr(clock,'ss'),'.fldin');
[file,path] = uiputfile(name,'Save to');
% Get the current material, hardening, yield
% TODO: handle error for no data or no selection
currentMaterial = getappdata(handles.figure1,'current_material');
currentHardening = getappdata(handles.figure1,'current_hardening');
currentYield = getappdata(handles.figure1,'current_yield');
currentMaterial.selected_hardening = currentHardening;
currentMaterial.selected_yield = currentYield;
% Get the description
% NOTE: get return array of strings, strjoin is used
% TODO: how to set multiline edit (when reopen old fldin file)
description = get(handles.edit_description,'String');
currentMaterial.description = strjoin(description,'\n');
% Get prestrain
prestrain = str2double(get(handles.edit_prestrain,'String'));
currentMaterial.prestrain = prestrain;
disp(savejson('',currentMaterial));
fid = fopen(strcat([path file]),'w');
% %s is used to avoid json content has special characters as formspec
fprintf(fid,'%s', savejson('',currentMaterial));
fclose(fid);
m_log_info('Save file to :',handles);
m_log_info(strcat([path file]),handles);

% --------------------------------------------------------------------
function menu_file_open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TODO: open the real file
[file,path] = uigetfile('*.fldin','Select the mk-fld input file');
m_log_info('Opening file :',handles);
m_log_info(strcat([path file]),handles);
inputData = loadjson(strcat([path file]));
m_log_info(inputData.name, handles);
% TODO:
% - add to current list and show chose result
% - * diff with server side data



function edit_description_Callback(hObject, eventdata, handles)
% hObject    handle to edit_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_description as text
%        str2double(get(hObject,'String')) returns contents of edit_description as a double


% --- Executes during object creation, after setting all properties.
function edit_description_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_description (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_prestrain_Callback(hObject, eventdata, handles)
% hObject    handle to slider_prestrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% disp(get(hObject, 'Value'));
prestrain = get(hObject, 'Value');
% disp(sprintf('%0.5f', prestrain));
set(handles.edit_prestrain, 'String', sprintf('%0.5f', prestrain));

% --- Executes during object creation, after setting all properties.
function slider_prestrain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_prestrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_prestrain_Callback(hObject, eventdata, handles)
% hObject    handle to edit_prestrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_prestrain as text
%        str2double(get(hObject,'String')) returns contents of edit_prestrain as a double

% Update the slider
prestrain = str2double(get(hObject, 'String'));
set(handles.slider_prestrain, 'Value', prestrain);

% --- Executes during object creation, after setting all properties.
function edit_prestrain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_prestrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
