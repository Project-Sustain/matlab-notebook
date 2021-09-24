function varargout = ProNEVA_GUI_RUN(varargin)
% PRONEVA_GUI_RUN MATLAB code for ProNEVA_GUI_RUN.fig
%      PRONEVA_GUI_RUN, by itself, creates a new PRONEVA_GUI_RUN or raises the existing
%      singleton*.
%
%      H = PRONEVA_GUI_RUN returns the handle to a new PRONEVA_GUI_RUN or the handle to
%      the existing singleton*.
%
%      PRONEVA_GUI_RUN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRONEVA_GUI_RUN.M with the given input arguments.
%
%      PRONEVA_GUI_RUN('Property','Value',...) creates a new PRONEVA_GUI_RUN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProNEVA_GUI_RUN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProNEVA_GUI_RUN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProNEVA_GUI_RUN

% Last Modified by GUIDE v2.5 24-May-2018 22:40:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProNEVA_GUI_RUN_OpeningFcn, ...
                   'gui_OutputFcn',  @ProNEVA_GUI_RUN_OutputFcn, ...
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


% --- Executes just before ProNEVA_GUI_RUN is made visible.
function ProNEVA_GUI_RUN_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProNEVA_GUI_RUN (see VARARGIN)

% Choose default command line output for ProNEVA_GUI_RUN
handles.output = hObject;

% SET DEFALT VALUES

handles.textITERATIONS.String = '10000';                                % Set Number of Iterations
handles.RUNspec.maxIT  = str2double(handles.textITERATIONS.String);

handles.textBURN.String = '9000';                                       % Set Number of Burn-In
handles.RUNspec.brn = str2double(handles.textBURN.String');

handles.textCHAINS.String = '3';                                        % Set Number of Chains
handles.RUNspec.Nchain = str2double(handles.textCHAINS.String);

handles.textRP.String = '100';                                          % Set Return Period
handles.RUNspec.RP = str2double(handles.textRP.String);

guidata(hObject, handles);

% UIWAIT makes ProNEVA_GUI_RUN wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProNEVA_GUI_RUN_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% ------------------ (1) SET NUMBER OF ITERATION --------------------------
function textITERATIONS_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function textITERATIONS_Callback(hObject, eventdata, handles)

handles.RUNspec.maxIT = str2double(get(hObject,'String'));  % Read
guidata(hObject, handles);                                  % Update handles structure

% ------------------ (2) SET NUMBER OF CHAINS ------------------
function textCHAINS_Callback(hObject, eventdata, handles)

handles.RUNspec.Nchain = str2double(get(hObject,'String')); % read
guidata(hObject, handles);                                  % Update handles structure

function CHAINS_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------ (3) SET NUMBER BURN-IN ------------------

function textBURN_Callback(hObject, eventdata, handles)

handles.RUNspec.brn = str2double(get(hObject,'String'));    % read
guidata(hObject, handles);                                  % Update handles structure

function textBURN_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------- (4) SET RETURN PERIOD --------------------
function textRP_Callback(hObject, eventdata, handles)
handles.RUNspec.RP = str2double(get(hObject,'String'));     % read
guidata(hObject, handles);                                  % Update handles structure

function textRP_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------ BOTTOM SAVE (YES/NO) ------------------

function SaveYES_Callback(hObject, eventdata, handles)

if get(hObject,'Value') % return state of the toggle
    handles.EXTRAS.saveRES = 'Y';
    % Unable selection of the other variable
    set(handles.SaveNO,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.SaveNO,'enable','on');
end

guidata(hObject, handles);                      % Update handles structure

function SaveNO_Callback(hObject, eventdata, handles)

if get(hObject,'Value') %returns toggle state of Nonstat check box
    handles.EXTRAS.saveRES = 'N';
    % Unable selection of the other variable
    set(handles.SaveYES,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.SaveYES,'enable','on');
end

guidata(hObject, handles);                      % Update handles structure

% ------------------ BOTTOM PLOT (YES/NO) ------------------
function PlotYES_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.EXTRAS.PlotRL = 'Y';
    % Unable selection of the other variable
    set(handles.PlotNO,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.PlotNO,'enable','on');
end

guidata(hObject, handles);                      % Update handles structure

function PlotNO_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.EXTRAS.PlotRL = 'N';
    % Unable selection of the other variable
    set(handles.PlotYES,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.PlotYES,'enable','on');
end

guidata(hObject, handles);                      % Update handles structure

% ------------------ BOTTOM TESTS (YES/NO) ------------------
function TestsYES_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.EXTRAS.RunTests = 'Y';
    % Unable selection of the other variable
    set(handles.TestsNO,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.TestsNO,'enable','on');
end

guidata(hObject, handles);                      % Update handles structure

% --- Executes on button press in TestsNO.
function TestsNO_Callback(hObject, eventdata, handles)

if get(hObject,'Value') 
    handles.EXTRAS.RunTests = 'N';
    % Unable selection of the other variable
    set(handles.TestsYES,'enable','off');
elseif ~get(hObject,'Value')
    set(handles.TestsYES,'enable','on');
end

guidata(hObject, handles);                      % Update handles structure


% ------------------------- BOTTOM RUN -------------------------------
function pushRUN_Callback(hObject, eventdata, handles)

load('USER_INPUT.mat');                                 % Parameters selected in previous sets

if exist('handles.EXTRAS.saveRES')
    EXTRAS.saveRES  = handles.EXTRAS.saveRES;
else 
    EXTRAS.saveRES = 'Y';
end

if exist('handles.EXTRAS.RunTests')
    EXTRAS.RunTests = handles.EXTRAS.RunTests;
else 
    EXTRAS.RunTests = 'Y';
end

if exist('handles.EXTRAS.PlotRL')
    EXTRAS.PlotRL = handles.EXTRAS.PlotRL;
else 
    EXTRAS.PlotRL = 'Y';
end


RUNspec.RP      = handles.RUNspec.RP;
RUNspec.brn     = handles.RUNspec.brn;
RUNspec.maxIT   = handles.RUNspec.maxIT;
RUNspec.Nchain  = handles.RUNspec.Nchain;

save('USER_INPUT.mat', 'OBS','RUNspec', 'EXTRAS');      % Save all parameters
close('ProNEVA_GUI_RUN')                                % Close current GUI

load( 'currentDIR.mat')                                 % Change directory
cd(currentDIR)
cd('ProNEVApackage')                                    % Open Folder w/ ProNEVA                    
save( 'currentDIR.mat','currentDIR' )                   % Store main director to be able to go back

% --------------------- RUN ProNEVA -----------------------------------
ProNEVA(OBS, RUNspec, EXTRAS)                             
