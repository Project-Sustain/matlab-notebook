function ProNEVA_GUI_MAIN(varargin)
% PRONEVA_GUI_MAIN MATLAB code for ProNEVA_GUI_MAIN.fig
%      PRONEVA_GUI_MAIN, by itself, creates a new PRONEVA_GUI_MAIN or raises the existing
%      singleton*.
%
%      H = PRONEVA_GUI_MAIN returns the handle to a new PRONEVA_GUI_MAIN or the handle to
%      the existing singleton*.
%
%      PRONEVA_GUI_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRONEVA_GUI_MAIN.M with the given input arguments.
%
%      PRONEVA_GUI_MAIN('Property','Value',...) creates a new PRONEVA_GUI_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProNEVA_GUI_MAIN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProNEVA_GUI_MAIN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProNEVA_GUI_MAIN

% Last Modified by GUIDE v2.5 13-May-2018 16:46:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProNEVA_GUI_MAIN_OpeningFcn, ...
                   'gui_OutputFcn',  @ProNEVA_GUI_MAIN_OutputFcn, ...
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


% --- Executes just before ProNEVA_GUI_MAIN is made visible.
function ProNEVA_GUI_MAIN_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;       % Choose default command line output for ProNEVA_GUI_MAIN
guidata(hObject, handles);      % Update handles structure                  

% UIWAIT makes ProNEVA_GUI_MAIN wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProNEVA_GUI_MAIN_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1} = handles.output;  % Get default command line output from handles structure

% ---------------------- BOTTOM SELECT DATA  ----------------------
function pushBROWSE_Callback(hObject, eventdata, handles)

% Get the file path
[FileName,FilePath] = uigetfile('*.txt','Select the text file to process','Multiselect','off'); 
% save it
ExPath = fullfile(FilePath, FileName);
% Write to a text editor for user
set(handles.dataPATH,'string',ExPath);              
% SAVE OBSERVATIONS
handles.OBS = load(ExPath);

% A few checks: this package works for two variables only
if size(handles.OBS,2) ~= 1
msgbox({'........................................',...
    '........................................',...
    'Select single vector',...
    '........................................',...
    '........................................'});
end

% Update handles structure
guidata(hObject, handles);

% ---------------------- DISPLAY DATA PATH ----------------------
function dataPATH_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ---------------------- TOGGLE GEV DISTRIBUTION ----------------------
function checkGEV_Callback(hObject, eventdata, handles)

if get(hObject,'Value')  %returns toggle state of GEV check box
    handles.RUNspec.DISTR.Type = 'GEV';
    % Unable selection of the other variable
    set(handles.checkGP,'enable','off');
    set(handles.checkLP3,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkGP,'enable','on');
    set(handles.checkLP3,'enable','on');
end
% Update handles structure
guidata(hObject, handles);      

% ---------------------- TOGGLE GP DISTRIBUTION ----------------------
function checkGP_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of GP check box
    handles.RUNspec.DISTR.Type = 'GP';
    % Unable selection of the other variable
    set(handles.checkGEV,'enable','off');
    set(handles.checkLP3,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkGEV,'enable','on');
    set(handles.checkLP3,'enable','on');
end
% Update handles structure
guidata(hObject, handles);      

% % ---------------------- TOGGLE LP3 DISTRIBUTION ----------------------
function checkLP3_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of LP3 check box
    handles.RUNspec.DISTR.Type = 'P3';
    % Unable selection of the other variable
    set(handles.checkGP,'enable','off');
    set(handles.checkGEV,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkGP,'enable','on');
    set(handles.checkGEV,'enable','on');
end
% Update handles structure
guidata(hObject, handles);      

% ---------------------- TOGGLE STATIONARY MODEL ----------------------
function checkSTAT_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Stat check box
    handles.RUNspec.DISTR.Model = 'Stat';
    % Unable selection of the other variable
    set(handles.checkNONSTAT,'enable','off');
    set( findall(handles.panelCOVARIATE, '-property', 'Enable'), 'Enable', 'off');
elseif ~get(hObject,'Value')
    set(handles.checkNONSTAT,'enable','on');
    set( findall(handles.panelCOVARIATE, '-property', 'Enable'), 'Enable', 'on');
end
% Update handles structure
guidata(hObject, handles);      

% ---------------------- TOGGLE NON-STATIONARY MODEL ----------------------
function checkNONSTAT_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Nonstat check box
    handles.RUNspec.DISTR.Model = 'NonStat';
    % Unable selection of the other variable
    set(handles.checkSTAT,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSTAT,'enable','on');
end
% Update handles structure
guidata(hObject, handles);      

% ---------------------- SELECT TIME AS COVARIATE -------------------------
function checkCOVtime_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.RUNspec.COV.Type = 'Time';
    % Unable selection of the other variable
    set(handles.checkCOVuser,'enable','off');
    set( findall(handles.PanelBROWSE, '-property', 'Enable'), 'Enable', 'off');
elseif ~get(hObject,'Value')
    set(handles.checkCOVuser,'enable','on');
    set( findall(handles.PanelBROWSE, '-property', 'Enable'), 'Enable', 'on');
end
% Update handles structure
guidata(hObject, handles);

% ---------------------- SELECT USER DEFINED COVARIATE -------------------------
function checkCOVuser_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.RUNspec.COV.Type = 'User';
    % Unable selection of the other variable
    set(handles.checkCOVtime,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkCOVtime,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% ---------------------- WRITE PATH  COVARIATE --------------------------
function textCOV_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% ---------------------- SELECT DATA FOR COVARIATE --------------------------
function pushCOV_Callback(hObject, eventdata, handles)

% Get the file path
[FileName,FilePath] = uigetfile('*.txt','Select the text file to process','Multiselect','off');  
% save path
ExPathCOV = fullfile(FilePath, FileName);
% Write to a text editor for user
set(handles.textCOV,'string',ExPathCOV);              

% SAVE COVARIATE
handles.RUNspec.COV.X = load(ExPathCOV);

% A few checks: this package works for two variables only
if size(handles.RUNspec.COV.X,2) ~= 1 && (length(handles.RUNspec.COV.X) == length(handles.OBS))
msgbox({'........................................',...
    '........................................',...
    'Invalide Covariate',...
    '........................................',...
    '........................................'});
end

% Update handles structure
guidata(hObject, handles);

% ---------------------- BOTTOM TO CONTINUE  -------------------------
function pushCONT01_Callback(hObject, eventdata, handles)

% CHECK OBS
if isempty(handles.OBS)
    msgbox({'NO DATA SELECTED'});
end

% CHECK Model
if isempty(handles.RUNspec.DISTR.Model)
    msgbox({'MODEL TYPE NOT SELECTED'});
end

% CHECK Model
if isempty(handles.RUNspec.DISTR.Type)
    msgbox({'DISTRIBUTION TYPE NOT SELECTED'});
end

% CHECK COVARIATE
if strcmp(handles.RUNspec.DISTR.Model, 'NonStat')
    if strcmp(handles.RUNspec.COV.Type, 'User')
        if isempty(handles.RUNspec.COV.X)
            msgbox({'NO COVARIATE SELECTED'});
            return
        end
    end
end

if isempty(handles.OBS) ||...
        isempty(handles.RUNspec.DISTR.Model) ||...
        isempty(handles.RUNspec.DISTR.Type)
    return
else
    OBS = handles.OBS;
    RUNspec = handles.RUNspec;
    save('USER_INPUT.mat', 'OBS', 'RUNspec');
    close('ProNEVA_GUI_MAIN')
    % BASE ON PREVIOUS SELECTION GOES TO THE NEXT GUI
    switch RUNspec.DISTR.Type
        case 'GEV'
            ProNEVA_GUI_GEV;
        case 'P3'
            ProNEVA_GUI_LP3;
        case 'GP'
            ProNEVA_GUI_GP;
    end
end
