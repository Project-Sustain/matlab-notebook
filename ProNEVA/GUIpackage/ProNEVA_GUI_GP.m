function varargout = ProNEVA_GUI_GP(varargin)
% PRONEVA_GUI_GP MATLAB code for ProNEVA_GUI_GP.fig
%      PRONEVA_GUI_GP, by itself, creates a new PRONEVA_GUI_GP or raises the existing
%      singleton*.
%
%      H = PRONEVA_GUI_GP returns the handle to a new PRONEVA_GUI_GP or the handle to
%      the existing singleton*.
%
%      PRONEVA_GUI_GP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRONEVA_GUI_GP.M with the given input arguments.
%
%      PRONEVA_GUI_GP('Property','Value',...) creates a new PRONEVA_GUI_GP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProNEVA_GUI_GP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProNEVA_GUI_GP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProNEVA_GUI_GP

% Last Modified by GUIDE v2.5 13-May-2018 18:53:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProNEVA_GUI_GP_OpeningFcn, ...
                   'gui_OutputFcn',  @ProNEVA_GUI_GP_OutputFcn, ...
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


% --- Executes just before ProNEVA_GUI_GP is made visible.
function ProNEVA_GUI_GP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProNEVA_GUI_GP (see VARARGIN)

% Choose default command line output for ProNEVA_GUI_GP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%---------------------- LOAD INPUT and DISABLE PANELS --------------------

load('USER_INPUT.mat')
if strcmp(RUNspec.DISTR.Model, 'Stat')
    set( findall(handles.panelTRENDscale, '-property', 'Enable'), 'Enable', 'off');
    set( findall(handles.panelTRENDshape, '-property', 'Enable'), 'Enable', 'off');

end
%------------------------------- DEFAULT PRIOR ---------------------------
% Default Threshold Value and Type
handles.TH.String = '0.98';
set(handles.ThresholdCONST,'Value', 1);
set(handles.ThresholdLIN,'enable','off'); 
handles.THtype = 'Const';
 
% Default SCALE
handles.scalePAR1.String = '0'; handles.scalePAR2.String = '10';
set(handles.checkSCALEnorm, 'Value', 1);
set(handles.checkSCALEunif,'enable','off'); set(handles.checkSCALEgam,'enable','off'); 

handles.SCALEdistr = 'Normal';
handles.SCALEparm1 = str2double(handles.scalePAR1.String);
handles.SCALEparm2 = str2double(handles.scalePAR2.String);

% Default SHAPE
handles.shapePAR1.String = '0'; handles.shapePAR2.String = '0.2';
set(handles.checkSHAPEnorm, 'Value', 1);
set(handles.checkSHAPEunif,'enable','off'); set(handles.checkSHAPEgam,'enable','off');

handles.SHAPEdistr = 'Normal';
handles.SHAPEparm1 = str2double(handles.shapePAR1.String);
handles.SHAPEparm2 = str2double(handles.shapePAR2.String);

guidata(hObject, handles);

% UIWAIT makes ProNEVA_GUI_GP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProNEVA_GUI_GP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%------------------------- OBSERVATION ONE YEAR --------------------------
function LocPAR2_Callback(hObject, eventdata, handles)

handles.LOCparm2 = str2double(get(hObject,'String'));
guidata(hObject, handles);      % Update handles structure

function LocPAR2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function OBSinYEAR_Callback(hObject, eventdata, handles)

handles.N_OBSyear = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function OBSinYEAR_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%---------------------------- THRESHOLD ----------------------------------
function TH_Callback(hObject, eventdata, handles)

handles.TH = str2double(get(hObject,'String'));
guidata(hObject, handles);      % Update handles structure

function TH_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------- TYPE OF THRESHOLD -----------------------------

% Constant Threshold
function ThresholdCONST_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Nonstat check box
    handles.THtype = 'Const';
    % Unable selection of the other variable
    set(handles.ThresholdLIN,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.ThresholdLIN,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% Linear Threshold
function ThresholdLIN_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Nonstat check box
    handles.THtype = 'QR';
    % Unable selection of the other variable
    set(handles.ThresholdCONST,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.ThresholdCONST,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

%--------------------------- SCALE PARAMETER -----------------------------
% PAR 1
function scalePAR1_Callback(hObject, eventdata, handles)

handles.SCALEparm1 = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

function scalePAR1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% PAR 2
function scalePAR2_Callback(hObject, eventdata, handles)

handles.SCALEparm2 = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

function scalePAR2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% TOGGLE UNIFORM DISTRIBUTION
function checkSCALEunif_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.SCALEdistr = 'Uniform';
    % Unable selection of the other variable
    set(handles.checkSCALEnorm,'enable','off');
    set(handles.checkSCALEgam,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSCALEnorm,'enable','on');
    set(handles.checkSCALEgam,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% TOGGLE NORMAL DISTRIBUTION
function checkSCALEnorm_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Nonstat check box
    handles.SCALEdistr = 'Normal';
    % Unable selection of the other variable
    set(handles.checkSCALEunif,'enable','off');
    set(handles.checkSCALEgam,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSCALEunif,'enable','on');
    set(handles.checkSCALEgam,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% TOGGLE GAMMA DISTRIBUTION
function checkSCALEgam_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Nonstat check box
    handles.SCALEdistr = 'Gamma';
    % Unable selection of the other variable
    set(handles.checkSCALEnorm,'enable','off');
    set(handles.checkSCALEunif,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSCALEnorm,'enable','on');
    set(handles.checkSCALEunif,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

%--------------------------- SHAPE PARAMETER ----------------------------
% PAR 1
function shapePAR1_Callback(hObject, eventdata, handles)

handles.SHAPEparm1 = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

function shapePAR1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% PAR 2
function shapePAR2_Callback(hObject, eventdata, handles)

handles.SHAPEparm2 = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);

function shapePAR2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% TOGGLE UNIFORM DISTRIBUTION
function checkSHAPEunif_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.SHAPEdistr = 'Uniform';
    % Unable selection of the other variable
    set(handles.checkSHAPEnorm,'enable','off');
    set(handles.checkSHAPEgam,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSHAPEnorm,'enable','on');
    set(handles.checkSHAPEgam,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% TOGGLE NORMAL DISTRIBUTION.
function checkSHAPEnorm_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Nonstat check box
    handles.SHAPEdistr = 'Normal';
    % Unable selection of the other variable
    set(handles.checkSHAPEunif,'enable','off');
    set(handles.checkSHAPEgam,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSHAPEunif,'enable','on');
    set(handles.checkSHAPEgam,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% TOGGLE GAMMA DISTRIBUTION
function checkSHAPEgam_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Nonstat check box
    handles.SHAPEdistr = 'Gamma';
    % Unable selection of the other variable
    set(handles.checkSHAPEunif,'enable','off');
    set(handles.checkSHAPEnorm,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSHAPEunif,'enable','on');
    set(handles.checkSHAPEnorm,'enable','on');
end
% Update handles structure
guidata(hObject, handles);


% ------------------ GETS TREND IN CASE OF NONSTAT ------------------
%                             SCALE

% NO TREND
function checkSCnone_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.SCALEtrend = 'none';
    % Unable selection of the other variable
    set(handles.checkSCquad,'enable','off');
    set(handles.checkSClin,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSCquad,'enable','on');
    set(handles.checkSClin,'enable','on');
end
% Update handles structure
guidata(hObject, handles);


% QUANDRATIC TREND
function checkSCquad_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.SCALEtrend = 'Quadratic';
    % Unable selection of the other variable
    set(handles.checkSCnone,'enable','off');
    set(handles.checkSClin,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSCnone,'enable','on');
    set(handles.checkSClin,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% LINEAR TREND
function checkSClin_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.SCALEtrend = 'Linear';
    % Unable selection of the other variable
    set(handles.checkSCnone,'enable','off');
    set(handles.checkSCquad,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSCnone,'enable','on');
    set(handles.checkSCquad,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% ------------------ GETS TREND IN CASE OF NONSTAT ------------------
%                             SHAPE
% LINEAR TREND
function checkSHlin_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.SHAPEtrend = 'Linear';
    % Unable selection of the other variable
    set(handles.checkSHnone,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSHnone,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% NO TREND
function checkSHnone_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.SHAPEtrend = 'none';
    % Unable selection of the other variable
    set(handles.checkSHlin,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.checkSHlin,'enable','on');
end
% Update handles structure
guidata(hObject, handles);

% --------------------- BOTTOM TO CONTINUE ------------------------------
function pushCONT_Callback(hObject, eventdata, handles)
% hObject    handle to pushCONT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('USER_INPUT.mat');

% In the case of Stationary Analysis - Trends 'none' by default
if strcmp(RUNspec.DISTR.Model, 'Stat')
    
    RUNspec.NS.SI = 'none';
    RUNspec.NS.XI = 'none';
else

    RUNspec.NS.SI = handles.SCALEtrend;
    RUNspec.NS.XI = handles.SHAPEtrend;

end

RUNspec.THtype = handles.THtype;
RUNspec.THp    = str2double(handles.TH.String);
RUNspec.NobsY  = handles.N_OBSyear;

RUNspec.PRIOR.SIdistr = handles.SCALEdistr;  
RUNspec.PRIOR.SIparm1 = handles.SCALEparm1;
RUNspec.PRIOR.SIparm2 = handles.SCALEparm2;

RUNspec.PRIOR.XIdistr = handles.SHAPEdistr; 
RUNspec.PRIOR.XIparm1 = handles.SHAPEparm1; 
RUNspec.PRIOR.XIparm2 = handles.SHAPEparm2; 

save('USER_INPUT.mat', 'OBS','RUNspec');    % Save updated INPUT
close('ProNEVA_GUI_GP')                     % Close current GUI
ProNEVA_GUI_RUN                             % open next gui - final step


