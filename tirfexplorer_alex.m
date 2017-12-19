function varargout = tirfexplorer_alex(varargin)
% TIRFEXPLORER_ALEX MATLAB code for tirfexplorer_alex.fig
%      TIRFEXPLORER_ALEX, by itself, creates a new TIRFEXPLORER_ALEX or raises the existing
%      singleton*.
%
%      H = TIRFEXPLORER_ALEX returns the handle to a new TIRFEXPLORER_ALEX or the handle to
%      the existing singleton*.
%
%      TIRFEXPLORER_ALEX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIRFEXPLORER_ALEX.M with the given input arguments.
%
%      TIRFEXPLORER_ALEX('Property','Value',...) creates a new TIRFEXPLORER_ALEX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tirfexplorer_alex_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tirfexplorer_alex_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's toolsbutton menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tirfexplorer_alex

% Last Modified by GUIDE v2.5 14-Nov-2017 23:24:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tirfexplorer_alex_OpeningFcn, ...
                   'gui_OutputFcn',  @tirfexplorer_alex_OutputFcn, ...
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

% --- Executes just before tirfexplorer_alex is made visible.
function tirfexplorer_alex_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tirfexplorer_alex (see VARARGIN)

% Choose default command line output for tirfexplorer_alex
handles.output = hObject;

%Set initial parameters
handles.rinnercircle=3; %circle around peak for data collection
handles.routercircle=6; %donut around peak for background information
handles.left_dim=[23 249 19 512]; %based on alignment of tetraspeck
handles.right_dim=[269 495 11 504];
handles.nImagesAvg=5; %how many averages to average for images
handles.nImagesProcess=0; %frames to analyze (0=all)
handles.alexToggle=0; %use a seperate channel for acceptor
handles.driftToggle=0; %track a peak to calculate drift
handles.maxPeaks=1000; %maximum number of peaks to analyze
handles.leftThresholdToggle=0; %0 uses a gui for thresholding.
handles.rightThresholdToggle=0; %0 uses a gui for thresholding.
handles.peaksFromFileToggle=0; %0 loads peaks from the movie


% Update handles structure
guidata(hObject, handles);



% This sets up the initial plot - only do when we are invisible
% so window can get raised using tirfexplorer_alex.


% UIWAIT makes tirfexplorer_alex wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tirfexplorer_alex_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in loadImageButton.
function loadImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Load the image for visualization and clear all of the plots
%Reload variables from the handles
donorFile=handles.donorFile;
left_dim=handles.left_dim;
right_dim=handles.right_dim;

handles=initializeImages(handles);
exp=handles.exp;
nImagesProcess=handles.nImagesProcess;

if ~handles.peaksFromFileToggle
    %Load the peaks from the image
    handles = loadPeaks(handles);
else
    if handles.driftToggle
        warning('Drift correction not enabled when peaks are loaded from file')
    end
    try
        leftPeaks=handles.leftPeaks;
        rightPeaks=handles.rightPeaks;
    catch
        errordlg('Please load a valid left and right peak file')
        return
    end
    %Need to repmat peaks across entire movie
    exp.lfilt=repmat(leftPeaks,[1 1 nImagesProcess]);
    exp.rfilt=repmat(rightPeaks,[1 1 nImagesProcess]);
    handles.exp=exp;
end

%Reload variables from the handles
exp=handles.exp;

%find matching pairs between the two channels
[exp.linknames exp.linki exp.linked_lpeaks exp.linked_rpeaks]=...
    linkPeaks(handles.tform,exp.lfilt,exp.rfilt,4);

%Update the list of peaks
set(handles.listbox2,'String',exp.linknames)

%make movies of channels
if handles.alexToggle
    acceptorFile=handles.acceptorFile;
end
handles.donorMovie=makeMovie(donorFile,nImagesProcess,left_dim);
handles.fretMovie=makeMovie(donorFile,nImagesProcess,right_dim);
if handles.alexToggle
    handles.acceptorMovie=makeMovie(acceptorFile,nImagesProcess,right_dim);
end
handles.exp=exp;

%Load figures and plot peaks
handles=loadFigureWindows(handles);

if handles.driftToggle
    switch handles.refChannel
    case 'left'
        set(plots.donorRef,'XData',handles.refPeak(1,1),...
            'YData',handles.refPeak(1,2));
    case 'right'
        if handles.alexToggle
            set(plots.acceptorRef,'XData',handles.refPeak(1,1),...
                'YData',handles.refPeak(1,2));
        else
            set(plots.fretRef,'XData',handles.refPeak(1,1),...
                'YData',handles.refPeak(1,2));
        end
    end
end

guidata(hObject,handles);
finished='yes'

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on button press in openDonorChannelButton.
function openDonorChannelButton_Callback(hObject, eventdata, handles)
% hObject    handle to openDonorChannelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename='';
pathname='';
[filename, pathname]=uigetfile('*.tif','Open Tirf','E:\Martin\Data\TIRF!');
if ~filename
    return
end
handles.donorFile=[pathname filename];
set(handles.text1,'String',filename);
guidata(hObject,handles);

% --- Executes on button press in pickLeftButton.
function pickLeftButton_Callback(hObject, eventdata, handles)
% hObject    handle to pickLeftButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[point(1) point(2)]=ginputc(1,'Color','r');
[peakPicked peakIndex]=pickPoint(handles.donorImageAxes,handles.left_dim,...
    handles.exp.lfilt);
handles.peakl_i=peakIndex;
handles=plotPoint2(handles,'left',peakPicked);
guidata(hObject,handles);

% --- Executes on button press in pickRightButton.
function pickRightButton_Callback(hObject, eventdata, handles)
% hObject    handle to pickRightButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.alexToggle
    ax1=handles.acceptorImageAxes;
else
    ax1=handles.fretImageAxes;
end
[peakPicked peakIndex]=pickPoint(ax1,handles.right_dim,...
    handles.exp.rfilt);
handles.peakr_i=peakIndex;
handles=plotPoint2(handles,'right',peakPicked);
guidata(hObject,handles);

% --- Executes on button press in plotDonorAcceptorButton.
function plotDonorAcceptorButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotDonorAcceptorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Calculate Relative traces
if ~handles.alexToggle
    error('Please turn on Alex to use this setting')
    return
end
lTrace=squeeze(handles.ltrace{1});
rTrace=squeeze(handles.rAcceptortraces{1});
plotFret(handles,lTrace,rTrace,0);


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
peak_i=get(hObject,'Value');
handles.peakl_i=peak_i;
handles.peakr_i=peak_i;
peak1=handles.exp.linked_lpeaks(peak_i,:,:);
peak2=handles.exp.linked_rpeaks(peak_i,:,:);
handles.peak1=peak1;
handles.peak2=peak2;
handles=plotPoint2(handles,'both',peak1,peak2);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
linknames='No Peaks Detected';
set(hObject,'String',linknames);


% --------------------------------------------------------------------
function export_t_Callback(hObject, eventdata, handles)
% hObject    handle to export_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Exports the current left and right traces as objects to the workspace
if isfield(handles,'ltrace')
    ltrace=squeeze(handles.ltrace{1});
    peak_lname=inputdlg('Name the Left Trace');
    assignin('base',peak_lname{1},ltrace);
end
if isfield(handles,'rtrace')
    rtrace=squeeze(handles.rtrace{1});
    peak_rname=inputdlg('Name the Right Trace');
    assignin('base',peak_rname{1},rtrace);
end
if isfield(handles,'rAcceptorTraces')
    acceptorTrace=squeeze(handles.rAcceptorTraces{1});
    peak_acceptorname=inputdlg('Name the Acceptor Trace');
    assignin('base',peak_acceptorname{1},acceptorTrace);
end


% --------------------------------------------------------------------
function export_all_Callback(hObject, eventdata, handles)
% hObject    handle to export_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Export all traces listed as linked peaks
%Output trace is a cell where each cell contains traces for one channel
%traces are stored as an array [each_peak pScore_output frame]
%pScore_output follows this format:
%[Total_Peak_intensity (signal minus noise), avg_peak_intensity (average
%signal), avg_bkgd_intensity, peak_size, background_size]
linked_traces=tracemovie(handles.donorFile,handles.rinnercircle,...
    handles.routercircle,2,handles.exp.linked_lpeaks,handles.left_dim,...
    handles.exp.linked_rpeaks,handles.right_dim);
exp=handles.exp;
exp.linked_ltraces=linked_traces{1};
exp.linked_rtraces=linked_traces{2};
exp_name=inputdlg('Name the Donor Exp File');
assignin('base',exp_name{1},exp);

if handles.alexToggle
    allAcceptorTraces=tracemovie(handles.acceptorFile,handles.rinnercircle,...
        handles.routercircle,1,handles.exp.linked_rpeaks,handles.right_dim);
    handles.expAcceptor.allAcceptorTraces=allAcceptorTraces;
    expNameAcceptor=inputdlg('Name the Acceptor Exp File');
    assignin('base',expNameAcceptor{1},exp);
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)%

%--------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function change_radii_Callback(hObject, eventdata, handles)
% hObject    handle to change_radii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rinnercircle_msg=sprintf('%s%d%s\n%s','Current rinnercircle (peak size) is '...
    ,handles.rinnercircle,'.','Change to:');
answer=inputdlg(rinnercircle_msg);
if isempty(answer) || isempty(answer{1})
    ;
else
    handles.rinnercircle=str2num(answer{1});
end

routercircle_msg=sprintf('%s%d%s\n%s',...
    'Current routercircle (bkgd doughnut size) is '...
    ,handles.routercircle,'.','Change to:');
answer=inputdlg(routercircle_msg);
if isempty(answer) || isempty(answer{1})
    ;
else
    handles.routercircle=str2num(answer{1});
end
guidata(hObject,handles);


% --------------------------------------------------------------------
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_map_Callback(hObject, eventdata, handles)
% hObject    handle to load_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
map_name='';
map_path='';
[map_name, map_path]=uigetfile('.mat','Open Map','E:\Martin\Data\TIRF!');
if ~map_name
    return
end
handles.map_file=[map_path map_name];
map=load(handles.map_file);
map_var=fieldnames(map);
map=map.(map_var{1});
tform=fitgeotrans(map(:,1:2),map(:,3:4),'nonreflectivesimilarity');
handles.tform=tform;
guidata(hObject,handles)


% --------------------------------------------------------------------
function change_left_dim_Callback(hObject, eventdata, handles)
% hObject    handle to change_left_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
left_dim_msg=sprintf('%s%s%s\n%s','Current Left Dimensions (X_min X_max Y_min Y_max): ['...
    ,num2str(handles.left_dim),']','Change to:');
left_string=inputdlg(left_dim_msg);
if isempty(left_string) || isempty(left_string{1})
    return
end
handles.left_dim=str2num(left_string{1});
guidata(hObject,handles);
% --------------------------------------------------------------------
function change_right_dim_Callback(hObject, eventdata, handles)
% hObject    handle to change_right_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
right_dim_msg=sprintf('%s%s%s\n%s','Current Right Dimensions (X_min X_max Y_min Y_max): ['...
    ,num2str(handles.right_dim),']','Change to:');
right_string=inputdlg(right_dim_msg);
if isempty(right_string) || isempty(right_string{1})
    return
end
handles.right_dim=str2num(right_string{1});
guidata(hObject,handles);
% --------------------------------------------------------------------
function nImagesAvgButton_Callback(hObject, eventdata, handles)
% hObject    handle to nImagesAvgButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n_images_msg=sprintf('%s%s%s\n%s','Current # of images to average is: '...
    ,num2str(handles.nImagesAvg),'.','Change to:');
n_images_string=inputdlg(n_images_msg);
if isempty(n_images_string) || isempty(n_images_string{1})
    return
end
handles.nImagesAvg=str2num(n_images_string{1});
guidata(hObject,handles);


% --------------------------------------------------------------------
function show_properties_Callback(hObject, eventdata, handles)
% hObject    handle to show_properties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
left_dim_msg=sprintf('%s%s%s','Current Left Dimensions (X_min X_max Y_min Y_max): ['...
    ,num2str(handles.left_dim),']');
right_dim_msg=sprintf('%s%s%s','Current Right Dimensions (X_min X_max Y_min Y_max): ['...
    ,num2str(handles.right_dim),']');
nImagesAvg_msg=sprintf('%s%s%s','Current # of images to average is: '...
    ,num2str(handles.nImagesAvg),'.');
nImagesProcess_msg=sprintf('%s%s%s',['Current # of images to process is'...
    ' (0 defaults to entire movie): '],num2str(handles.nImagesProcess),'.');
rinnercircle_msg=sprintf('%s%d%s','Current rinnercircle (peak size) is: '...
    ,handles.rinnercircle,'.');
routercircle_msg=sprintf('%s%d%s',...
    'Current routercircle (bkgd doughnut size) is: '...
    ,handles.routercircle,'.');
alexToggleMsg=sprintf('%s%d','Currently the Alex Toggle (0 is off, 1 is on) is set to: ',...
    handles.alexToggle);
driftToggleMsg=sprintf('%s%d','Currently the Drift Correction Toggle (0 is off, 1 is on) is set to: ',...
   handles.driftToggle);
maxPeaksMsg=sprintf('%s%d','Currently the maximum # of peaks is set to: ',...
    handles.maxPeaks);
leftThresholdMsg=sprintf('%s%d','Currently the Left Threshold is set to: ',...
    handles.leftThresholdToggle);
rightThresholdMsg=sprintf('%s%d','Currently the Right Threshold is set to: ',...
    handles.rightThresholdToggle);
peaksFromFileMsg=sprintf('%s%d','Currently the Peaks From File Toggle (0 is off, 1 is on) is set to: ',...
    handles.peaksFromFileToggle);
msgbox({left_dim_msg,right_dim_msg,'',nImagesAvg_msg,nImagesProcess_msg,'',...
    rinnercircle_msg,routercircle_msg,'',alexToggleMsg,driftToggleMsg,maxPeaksMsg,...
    leftThresholdMsg,rightThresholdMsg,peaksFromFileMsg});


% --- Executes on button press in openAcceptorChannelButton.
function openAcceptorChannelButton_Callback(hObject, eventdata, handles)
% hObject    handle to openAcceptorChannelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename='';
pathname='';
[filename, pathname]=uigetfile('*.tif','Open Tirf','E:\Martin\Data\TIRF!');
if ~filename
    return
end
handles.acceptorFile=[pathname filename];
set(handles.text8,'String',filename);
guidata(hObject,handles);

% --------------------------------------------------------------------
function alex_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to alex_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
alexToggleMsg=sprintf('%s%s%s\n%s',['Toggle ALEX On (1) or Off (0).'...
    'Current state is: '],num2str(handles.alexToggle),'.','Change to:');
alexToggleString=inputdlg(alexToggleMsg);
if isempty(alexToggleString) || isempty(alexToggleString{1})
    return;
end
handles.alexToggle=str2num(alexToggleString{1});
guidata(hObject,handles);


% --------------------------------------------------------------------
function driftToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to driftToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
driftToggleMsg=sprintf('%s%s%s\n%s',['Toggle Drift Correction On (1) or Off (0).'...
    'Current state is: '],num2str(handles.driftToggle),'.','Change to:');
driftToggleString=inputdlg(driftToggleMsg);
if isempty(driftToggleString) || isempty(driftToggleString{1})
    return
end
handles.driftToggle=str2num(driftToggleString{1});
guidata(hObject,handles);


% --------------------------------------------------------------------
function nImagesProcessButton_Callback(hObject, eventdata, handles)
% hObject    handle to nImagesProcessButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n_images_msg=sprintf('%s%s%s\n%s',['Current # of images to process is'...
    ' (0 defaults to entire movie): '],num2str(handles.nImagesProcess),...
    '.','Change to:');
n_images_string=inputdlg(n_images_msg);
if isempty(n_images_string) || isempty(n_images_string{1})
    return;
end
handles.nImagesProcess=str2num(n_images_string{1});
guidata(hObject,handles);


% --------------------------------------------------------------------
function refPeakButton_Callback(hObject, eventdata, handles)
% hObject    handle to refPeakButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refPeak_msg=sprintf('%s\n%s',...
    'Current Reference Peak is highlight in red.',...
    'Which channel would you like to select from? (left or right)');
refChannel=inputdlg(refPeak_msg);
if isempty(refChannel) || isempty(refChannel{1})
    return
end
refChannel=refChannel{1};
handles.refChannel=refChannel;
switch refChannel
    case 'left'
        ax=handles.donorImageAxes;
        channelDim=handles.left_dim;
        peakList=handles.exp.lfilt(:,:,1);
        [refPeak i]=pickPoint(ax,channelDim,peakList);
        handles.refPeak=refPeak;
        set(handles.plots.donorRef,'XData',refPeak(1,1),...
            'YData',refPeak(1,2));
    case 'right'
        channelDim=handles.right_dim;
        peakList=handles.exp.rfilt(:,:,1);
        if handles.alexToggle
            ax=handles.acceptorImageAxes;
            [refPeak i]=pickPoint(ax,channelDim,peakList);
            handles.refPeak=refPeak;
            set(handles.plots.acceptorRef,'XData',refPeak(1,1),...
                'YData',refPeak(1,2));
        else
            ax=handles.fretImageAxes;
            [refPeak i]=pickPoint(ax,channelDim,peakList);
            handles.refPeak=refPeak;
            set(handles.plots.fretRef,'XData',refPeak(1,1),...
                'YData',refPeak(1,2));
        end
    otherwise
        errordlg('Please pick either left or right')
        return
end
guidata(hObject,handles);


% --- Executes on button press in plotDonorFretButton.
function plotDonorFretButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotDonorFretButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lTrace=squeeze(handles.ltrace{1});
rTrace=squeeze(handles.rtrace{1});
plotFret(handles,lTrace,rTrace,0);

% --------------------------------------------------------------------
function setLeftThresholdButton_Callback(hObject, eventdata, handles)
% hObject    handle to setLeftThresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
leftThresholdToggleMsg=sprintf('%s%s%s\n%s',['Set left threshold by entering a value >0. '...
    'A value of 0 uses a gui to set threshold. '...
    'Current left threshold is: '],num2str(handles.leftThresholdToggle),'.','Change to:');
leftThresholdToggleString=inputdlg(leftThresholdToggleMsg);
if isempty(leftThresholdToggleString) || ...
        isempty(leftThresholdToggleString{1})
    return
end
handles.leftThresholdToggle=str2num(leftThresholdToggleString{1});
guidata(hObject,handles);


% --------------------------------------------------------------------
function setRightThresholdButton_Callback(hObject, eventdata, handles)
% hObject    handle to setRightThresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rightThresholdToggleMsg=sprintf('%s%s%s\n%s',['Set right threshold by entering a value >0. '...
    'A value of 0 uses a gui to set threshold. '...
    'Current right threshold is: '],num2str(handles.rightThresholdToggle),'.','Change to:');
rightThresholdToggleString=inputdlg(rightThresholdToggleMsg);
if isempty(rightThresholdToggleString) ||...
        isempty(rightThresholdToggleString{1})
    return
end
handles.rightThresholdToggle=str2num(rightThresholdToggleString{1});
guidata(hObject,handles);


% --------------------------------------------------------------------
function toolsButton_Callback(hObject, eventdata, handles)
% hObject    handle to toolsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function plotIndicesButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotIndicesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
'Plotting Indices'
leftXStart=handles.left_dim(1);
leftXEnd=handles.left_dim(2);
leftYStart=handles.left_dim(3);
leftYEnd=handles.left_dim(4);
rightXStart=handles.right_dim(1);
rightXEnd=handles.right_dim(2);
rightYStart=handles.right_dim(3);
rightYEnd=handles.right_dim(4);
if ~isfield(handles,'peakl_i') || ~isfield(handles,'peakr_i')
    errordlg('Please select a left and right peak')
    return
end
exp=handles.exp;
if handles.peakl_i
    leftPeakIndex=handles.peakl_i;
else
    leftPeakIndex=1;
end
if handles.peakr_i
    rightPeakIndex=handles.peakr_i;
else
    rightPeakIndex=1;
end
leftPeakIndices=indexPeaks([(leftYEnd-leftYStart+1) (leftXEnd-leftXStart+1)]...
    ,exp.linked_lpeaks(leftPeakIndex,:),handles.rinnercircle,handles.routercircle);
axes(handles.donorImageAxes);
hold on
for i=1:size(leftPeakIndices,1)
    i
    ind=leftPeakIndices{i,1,1};
    [y x]=ind2sub(size(exp.avgl),ind);
    p=scatter(x,y,'r.');
    p.MarkerEdgeAlpha=0.4;
end

for i=1:size(leftPeakIndices,1)
    i
    ind=leftPeakIndices{i,2,1};
    [y x]=ind2sub(size(exp.avgl),ind);
    p=scatter(x,y,'g.');
    p.MarkerEdgeAlpha=0.4;
end
hold off

rightPeakIndices=indexPeaks([(rightYEnd-rightYStart+1) (rightXEnd-rightXStart+1)]...
    ,exp.linked_rpeaks(rightPeakIndex,:),handles.rinnercircle,handles.routercircle);
axes(handles.fretImageAxes);
hold on
for i=1:size(rightPeakIndices,1)
    ind=rightPeakIndices{i,1,1};
    [y x]=ind2sub(size(exp.avgr),ind);
    p=scatter(x,y,'r.');
    p.MarkerEdgeAlpha=0.4;
end

for i=1:size(rightPeakIndices,1)
    ind=rightPeakIndices{i,2,1};
    [y x]=ind2sub(size(exp.avgr),ind);
    p=scatter(x,y,'g.');
    p.MarkerEdgeAlpha=0.4;
end
drawnow
hold off
setAxesProperties(handles);
'Done Plotting'


% --------------------------------------------------------------------
function playMoviesButton_Callback(hObject, eventdata, handles)
% hObject    handle to playMoviesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%first clear previous movies
if isfield(handles,'donorMovieHandle')
    if isvalid(handles.donorMovieHandle)
        close(handles.donorMovieHandle);
    end
    if isvalid(handles.fretMovieHandle);
        close(handles.fretMovieHandle);
    end
    if handles.alexToggle
        if isfield(handles,'acceptorMovieHandle')
            if isvalid(handles.acceptorMovieHandle)
                close(handles.acceptorMovieHandle);
            end
        end
    end
end
exp=handles.exp;
fps=4;

%Load Current Highlighted Peaks
leftPeak=0;
rightPeak=0;
if isfield(handles,'peakl_i')
    leftPeak=handles.exp.linked_lpeaks(handles.peakl_i,:,:);
end

if isfield(handles,'peakr_i')
    rightPeak=handles.exp.linked_rpeaks(handles.peakr_i,:,:);
end

%Open a separate figure for each channel and overlay the peaks
donorMovieHandle=implay(handles.donorMovie,fps);
donorMovieHandle.Parent.Name='Donor Channel';
%Plot Peaks
axes(donorMovieHandle.Parent.CurrentAxes)
hold on
plot(exp.lfilt(:,1),exp.lfilt(:,2),'yo')
plot(exp.linked_lpeaks(:,1),exp.linked_lpeaks(:,2),'ro')
if leftPeak
    plot(leftPeak(1),leftPeak(2),'go')
end
hold off

fretMovieHandle=implay(handles.fretMovie,fps);
fretMovieHandle.Parent.Name='FRET Channel';
%Plot Peaks
axes(fretMovieHandle.Parent.CurrentAxes)
hold on
plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
if rightPeak
    plot(rightPeak(1),rightPeak(2),'go')
end
hold off

if handles.alexToggle
    acceptorMovieHandle=implay(handles.acceptorMovie,fps);
    acceptorMovieHandle.Parent.Name='Acceptor Channel';
    %Plot Peaks
    axes(acceptorMovieHandle.Parent.CurrentAxes)
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    if rightPeak
        plot(rightPeak(1),rightPeak(2),'go')
    end
    hold off
end
handles.donorMovieHandle=donorMovieHandle;
handles.fretMovieHandle=fretMovieHandle;
if handles.alexToggle
    handles.acceptorMovieHandle=acceptorMovieHandle;
end
guidata(hObject,handles)


% --------------------------------------------------------------------
function updateMovieButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateMovieButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This button replots the peaks onto the movies without closing and
%reopening the windows
%Load Current Highlighted Peaks
if ~isvalid(handles.donorMovieHandle) || ~isvalid(handles.fretMovieHandle)
    errordlg('Please reopen all movies using the Play Movies menu button')
    return
end
if handles.alexToggle
    if ~isvalid(handles.acceptorMovieHandle)
    errordlg('Please reopen all movies using the Play Movies menu button')
    return
    end
end
exp=handles.exp;
leftPeak=0;
rightPeak=0;
if isfield(handles,'peakl_i')
    leftPeak=handles.exp.linked_lpeaks(handles.peakl_i,:,:);
end

if isfield(handles,'peakr_i')
    rightPeak=handles.exp.linked_rpeaks(handles.peakr_i,:,:);
end

%Open a separate figure for each channel and overlay the peaks
donorMovieHandle=handles.donorMovieHandle;
donorMovieHandle.Parent.Name='Donor Channel';
%Plot Peaks
axes(donorMovieHandle.Parent.CurrentAxes);
hold on
plot(exp.lfilt(:,1),exp.lfilt(:,2),'yo')
plot(exp.linked_lpeaks(:,1),exp.linked_lpeaks(:,2),'ro')
if leftPeak
    plot(leftPeak(1),leftPeak(2),'go')
end
hold off

fretMovieHandle=handles.fretMovieHandle;
fretMovieHandle.Parent.Name='FRET Channel';
%Plot Peaks
axes(fretMovieHandle.Parent.CurrentAxes);
hold on
plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
if rightPeak
    plot(rightPeak(1),rightPeak(2),'go')
end
hold off

if handles.alexToggle
    acceptorMovieHandle=handles.acceptorMovieHandle;
    acceptorMovieHandle.Parent.Name='Acceptor Channel';
    %Plot Peaks
    axes(acceptorMovieHandle.Parent.CurrentAxes);
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    if rightPeak
        plot(rightPeak(1),rightPeak(2),'go')
    end
    hold off
end


% --------------------------------------------------------------------
function exportCPButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportCPButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exportPeaks(handles.exp,1,0)

% --------------------------------------------------------------------
function exportLinkedPeaksButton_Callback(hObject, eventdata,    handles)
% hObject    handle to exportLinkedPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exportPeaks(handles.exp,0,1)


% --------------------------------------------------------------------
function exportAllPeaksButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportAllPeaksButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exportPeaks(handles.exp,0,0)


% --------------------------------------------------------------------
function loadPeakFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadPeakFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Replaces peaks with user uploaded peaks in a csv (x_pos,y_pos)
%First load the file into an array
leftPeaks=[];
rightPeaks=[];
try
    [leftPeakFile, leftPeakPath] = uigetfile('*.csv','Open Left Peaks');
    if ~leftPeakFile
        return
    end
    leftFileName=[leftPeakPath leftPeakFile];
    leftPeaks=csvread(leftFileName);
    %include 0s for other parameters generated by peak finding algorithm
    nLeftPeaks=size(leftPeaks,1);
    handles.leftPeaks=zeros(nLeftPeaks,4);
    handles.leftPeaks(:,1:2)=leftPeaks;
    [rightPeakFile, rightPeakPath] = uigetfile('*.csv','Open Right Peaks');
    
    if ~rightPeakFile
        return
    end
    
    rightFileName=[rightPeakPath rightPeakFile];
    rightPeaks=csvread(rightFileName);
    %include 0s for other parameters generated by peak finding algorithm
    nRightPeaks=size(rightPeaks,1);
    handles.rightPeaks=zeros(nRightPeaks,4);
    handles.rightPeaks(:,1:2)=rightPeaks;
catch
    errordlg('Please load a valid left and right peak file [x y]')
    return
end
guidata(hObject,handles);


% --------------------------------------------------------------------
function usePeaksFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to usePeaksFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
peaksFromFileMsg=sprintf('%s%s%s\n%s',['Toggle using peaks from a loaded file '...
    'On (1) or Off (0).'...
    'Current state is: '],num2str(handles.peaksFromFileToggle),'.','Change to:');
answer=inputdlg(peaksFromFileMsg);
if isempty(answer) || isempty(answer{1})
    return
else
    peaksFromFileString=answer;
    handles.peaksFromFileToggle=str2num(peaksFromFileString{1});
    guidata(hObject,handles);
end


% --------------------------------------------------------------------
function reopenWindowsButton_Callback(hObject, eventdata, handles)
% hObject    handle to reopenWindowsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=loadFigureWindows(handles);
guidata(hObject,handles);
