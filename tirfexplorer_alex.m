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
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tirfexplorer_alex

<<<<<<< HEAD
% Last Modified by GUIDE v2.5 09-Nov-2017 15:44:59
=======
% Last Modified by GUIDE v2.5 29-Mar-2017 16:01:07
>>>>>>> parent of 6da2d62... Add a function to watch movies of the traces (under tools)

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
handles.left_dim=[25 235 10 500]; %based on alignment of tetraspeck
handles.right_dim=[269 479 9 499];
handles.nImagesAvg=5; %how many averages to average for images
handles.nImagesProcess=0; %frames to analyze (0=all)
handles.alexToggle=0; %use a seperate channel for acceptor
handles.driftToggle=0; %track a peak to calculate drift
handles.maxPeaks=500; %maximum number of peaks to analyze
handles.leftThresholdToggle=0; %0 uses a gui for thresholding.
handles.rightThresholdToggle=0; %0 uses a gui for thresholding.

%Load figure window
handles.imageFigure=figure();
handles.donorImageAxes=subplot(1,3,1);
title('Donor')
handles.fretImageAxes=subplot(1,3,2);
title('FRET')
handles.acceptorImageAxes=subplot(1,3,3);
title('Acceptor')
handles.traceFigure=figure();
handles.donorTraceAxes=subplot(4,1,1);
title('Donor Ch')
handles.fretTraceAxes=subplot(4,1,2);
title('FRET Ch')
handles.acceptorTraceAxes=subplot(4,1,3);
title('Acceptor Ch')
handles.fretCalcAxes=subplot(4,1,4);
title('Calc')

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

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%clear trace axes and listbox
axes(handles.donorTraceAxes);
cla;
axes(handles.acceptorTraceAxes);
cla;
axes(handles.fretTraceAxes);
cla;
axes(handles.fretCalcAxes);
cla;
axes(handles.donorImageAxes);
cla;
axes(handles.fretImageAxes);
cla;
axes(handles.acceptorImageAxes);
cla;
set(handles.listbox2,'String',{'No Points Detected'},'Value',1)

if ~isfield(handles,'donorFile')
    errordlg('Please select a donor tif movie file')
    return
end

if ~isfield(handles,'tform')
    errordlg('Please load a map (use menu)')
    return
end
donorFile=handles.donorFile;
if handles.alexToggle
    if ~isfield(handles,'acceptorFile')
        errrodlg('Please select an acceptor tif movie file')
        return
    end
    acceptorFile=handles.acceptorFile;
end

nImagesAvg=handles.nImagesAvg;
if handles.nImagesProcess==0
    handles.nImagesProcess=length(imfinfo(donorFile));
end
nImagesProcess=handles.nImagesProcess;

left_dim=handles.left_dim;
right_dim=handles.right_dim;
exp=loadAverage(donorFile,1,nImagesAvg);
exp.avgl=exp.avg(left_dim(3):left_dim(4),left_dim(1):left_dim(2));
exp.avgr=exp.avg(right_dim(3):right_dim(4),right_dim(1):right_dim(2));
%If alex is turned on, also load an additional average for the other
%channel
if handles.alexToggle
    expAcceptor=loadAverage(acceptorFile,1,nImagesAvg);
    expAcceptor.avgl=expAcceptor.avg(left_dim(3):left_dim(4),...
        left_dim(1):left_dim(2));
    expAcceptor.avgr=expAcceptor.avg(right_dim(3):right_dim(4),...
        right_dim(1):right_dim(2));
end
%load arrays to store peak positions for every frame
handles.maxPeaks=500;
leftFilt=zeros(handles.maxPeaks,4,nImagesProcess);
rightFilt=zeros(handles.maxPeaks,4,nImagesProcess);
if handles.leftThresholdToggle
    leftThreshold=handles.leftThresholdToggle;
else
    leftThreshold=0;
end
if handles.rightThresholdToggle
    rightThreshold=handles.rightThresholdToggle;
else
    rightThreshold=0;
end
%On the first loop, ask for threshhold, but use the same threshold for the
%remaining loops
nRemainder=mod(nImagesProcess,5);
if handles.driftToggle
    if handles.refPeak
        refPeak=handles.refPeak;
        totalShift=[0 0];
    else
        errordlg('Please select a reference peak for drift correction')
        return
    end
end
%make five frame averages
for cIm=1:5:nImagesProcess-nRemainder
    cIm %report the image # being processed
    
    %Copy peaks from previous frames
    if cIm>1
        leftFilt(:,:,cIm:cIm+4)=repmat(leftFilt(:,:,cIm-1),1,1,5);
        rightFilt(:,:,cIm:cIm+4)=repmat(rightFilt(:,:,cIm-1),1,1,5);
    end
    nLeftFilt=sum(leftFilt(:,1,cIm)~=0);
    nRightFilt=sum(rightFilt(:,1,cIm)~=0);
    %load a moving average of the image
    temp=loadAverage(donorFile,cIm,cIm+4);
    temp.l=temp.avg(left_dim(3):left_dim(4),left_dim(1):left_dim(2));
    temp.r=temp.avg(right_dim(3):right_dim(4),right_dim(1):right_dim(2));
    if handles.alexToggle
        tempAcceptor=loadAverage(acceptorFile,cIm,cIm+4);
        temp.r=tempAcceptor.avg(right_dim(3):right_dim(4),...
            right_dim(1):right_dim(2));
    end
    %If driftToggle is on, then shift all peaks according to a reference
    %peak
    if cIm>1 && handles.driftToggle
        switch handles.refChannel
            case 'left'
                refImage=temp.l;
            case 'right'
                refImage=temp.r;
            otherwise
                errordlg('Please choose a reference channel and peak')
                return
        end
        shift=calcDrift(refPeak,refImage)
        if isnan(shift)
            errordlg('Shift is too large')
            return
        end
        leftFilt(1:nLeftFilt,1:2,cIm:cIm+4)=...
            leftFilt(1:nLeftFilt,1:2,cIm:cIm+4)+repmat(shift,nLeftFilt,1,5);
        rightFilt(1:nRightFilt,1:2,cIm:cIm+4)=...
            rightFilt(1:nRightFilt,1:2,cIm:cIm+4)+repmat(shift,nRightFilt,1,5);
        refPeak=refPeak(1,1:2)+shift; %update the position of the ref
        totalShift=totalShift+shift
    end
    
    %then find all the peaks in the image and filter them for crowding and
    %shape of the peak
    if leftThreshold
        [temp.lp]=findPeaks(temp.l,leftThreshold);
    else
        [temp.lp leftThreshold]=findPeaks(temp.l);
        leftThreshold
    end
    if rightThreshold
        [temp.rp]=findPeaks(temp.r,rightThreshold);
    else
        [temp.rp rightThreshold]=findPeaks(temp.r);
        rightThreshold
    end
    temp.lfilt=filterPeaks(temp.l,temp.lp,10,2);
    temp.rfilt=filterPeaks(temp.r,temp.rp,10,2);
    %filter out new peaks from the temporary images by comparing against
    %the previous list
    newPeakCounter=0;
    for j=1:size(temp.lfilt,1)
        %Check if peak is near another peak
        nearPeaks=findNearPoints(temp.lfilt(j,1:2),...
            squeeze(leftFilt(:,:,cIm)),5);
        if isempty(nearPeaks)
            newPeakCounter=newPeakCounter+1;
            if nLeftFilt+newPeakCounter>handles.maxPeaks
                errordlg('Too many left peaks found')
                return
            end
            leftFilt(nLeftFilt+newPeakCounter,:,cIm:cIm+4)=...
                repmat(temp.lfilt(j,:),1,1,5);
        end
    end
    newPeakCounter=0;
    for j=1:size(temp.rfilt,1)
        nearPeaks=findNearPoints(temp.rfilt(j,1:2),...
            squeeze(rightFilt(:,:,cIm)),5);
        if isempty(nearPeaks)
            newPeakCounter=newPeakCounter+1;
            if nRightFilt+newPeakCounter>handles.maxPeaks
                errordlg('Too many right peaks found')
                return
            end
            rightFilt(nRightFilt+newPeakCounter,:,cIm:cIm+4)=...
                repmat(temp.rfilt(j,:),1,1,5);
        end
    end
    %report progress
    nLeftFilt=sum(leftFilt(:,1,cIm)~=0)
    nRightFilt=sum(rightFilt(:,1,cIm)~=0)
end
%Fill out peaks with last few frames if not divisible by 5
nRemainder=mod(nImagesProcess,5);
if nRemainder>0
    cIm=cIm+5;
    leftFilt(:,:,cIm:cIm+nRemainder-1)=...
        repmat(leftFilt(:,:,cIm-1),1,1,nRemainder);
    rightFilt(:,:,cIm:cIm+nRemainder-1)=...
        repmat(rightFilt(:,:,cIm-1),1,1,nRemainder);
end
%Squeeze the peak array down
%First remove all rows that don't have any peaks at any point
leftFilt(nLeftFilt+1:end,:,:)=[];
rightFilt(nRightFilt+1:end,:,:)=[];
%Now go through each row, find when that peak started, and carry it through
%to the beginning of the trace
for i=1:nLeftFilt
    firstFrame=find(leftFilt(i,1,:),1);
    leftFilt(i,:,1:firstFrame)=repmat(leftFilt(i,:,firstFrame),1,1,firstFrame);
end
for i=1:nRightFilt
    firstFrame=find(rightFilt(i,1,:),1);
    rightFilt(i,:,1:firstFrame)=repmat(rightFilt(i,:,firstFrame),1,1,firstFrame);
end
exp.lfilt=leftFilt;
exp.rfilt=rightFilt;
%find matching pairs between the two channels
[exp.linknames exp.linki exp.linked_lpeaks exp.linked_rpeaks]=...
    linkPeaks(handles.tform,exp.lfilt,exp.rfilt,4);
handles.exp=exp;
if handles.alexToggle
    handles.expAcceptor=expAcceptor;
end
%Update the list of peaks
set(handles.listbox2,'String',handles.exp.linknames)
<<<<<<< HEAD

%make movies of channels
handles.donorMovie=makeMovie(donorFile,nImagesProcess,left_dim);
handles.fretMovie=makeMovie(donorFile,nImagesProcess,right_dim);
if handles.alexToggle
    handles.acceptorMovie=makeMovie(acceptorFile,nImagesProcess,right_dim);
end
=======
guidata(hObject,handles);

>>>>>>> parent of 6da2d62... Add a function to watch movies of the traces (under tools)
%Plot peaks on images
axes(handles.donorImageAxes);
imshow(exp.avgl,[])
hold on
plot(exp.lfilt(:,1),exp.lfilt(:,2),'yo')
plot(exp.linked_lpeaks(:,1),exp.linked_lpeaks(:,2),'ro')
hold off
axes(handles.fretImageAxes);
imshow(exp.avgr,[])
hold on
plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
hold off
if handles.alexToggle
    axes(handles.acceptorImageAxes);
    imshow(expAcceptor.avgr,[])
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    hold off
end
if handles.driftToggle
    highlightPeak(handles,handles.refChannel,handles.refPeak,'g+');
end
setAxesProperties(handles)
<<<<<<< HEAD
guidata(hObject,handles);
=======
>>>>>>> parent of 6da2d62... Add a function to watch movies of the traces (under tools)
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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename='';
pathname='';
[filename, pathname]=uigetfile('*.tif','Open Tirf','E:\Martin\Data\TIRF!');
handles.donorFile=[pathname filename];
guidata(hObject,handles);
set(handles.text1,'String',filename);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
map_name='';
map_path='';
[map_name, map_path]=uigetfile('*','Open Map','E:\Martin\Data\TIRF!');
handles.map_file=[map_path map_name];
set(handles.text4,'String',map_name);
map=load(handles.map_file);
map_var=fieldnames(map);
map=map.(map_var{1});
tform=cp2tform(map(:,1:2),map(:,3:4),'projective');
handles.tform=tform;
guidata(hObject,handles)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[point(1) point(2)]=ginputc(1,'Color','r');
[peakPicked peakIndex]=pickPoint(handles.donorImageAxes,handles.left_dim,...
    handles.exp.lfilt);
handles.peakl_i=peakIndex;
handles=plotPoint2(handles,'left',peakPicked);
guidata(hObject,handles)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
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
guidata(hObject,handles)

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
plotFret(handles.fretCalcAxes,lTrace,rTrace,0);


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
guidata(hObject,handles)

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
    expAcceptor=handles.expAcceptor;
    expAcceptor.allAcceptorTraces=allAcceptorTraces;
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
rinnercircle=inputdlg(rinnercircle_msg);
routercircle_msg=sprintf('%s%d%s\n%s',...
    'Current routercircle (bkgd doughnut size) is '...
    ,handles.routercircle,'.','Change to:');
routercircle=inputdlg(routercircle_msg);
handles.rinnercircle=str2num(rinnercircle{1});
handles.routercircle=str2num(routercircle{1});
guidata(hObject,handles);


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_map_Callback(hObject, eventdata, handles)
% hObject    handle to load_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
map_name='';
map_path='';
[map_name, map_path]=uigetfile('*','Open Map','E:\Martin\Data\TIRF!');
handles.map_file=[map_path map_name];
map=load(handles.map_file);
map_var=fieldnames(map);
map=map.(map_var{1});
tform=cp2tform(map(:,1:2),map(:,3:4),'projective');
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
msgbox({left_dim_msg,right_dim_msg,'',nImagesAvg_msg,nImagesProcess_msg,'',...
    rinnercircle_msg,routercircle_msg,'',alexToggleMsg,driftToggleMsg,maxPeaksMsg,...
    leftThresholdMsg,rightThresholdMsg});


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename='';
pathname='';
[filename, pathname]=uigetfile('*.tif','Open Tirf','E:\Martin\Data\TIRF!');
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
refChannel=refChannel{1};
handles.refChannel=refChannel;
switch refChannel
    case 'left'
        ax=handles.donorImageAxes;
        channelDim=handles.left_dim;
        peakList=handles.exp.lfilt(:,:,1);
    case 'right'
        channelDim=handles.right_dim;
        peakList=handles.exp.rfilt(:,:,1);
        if handles.alexToggle
            ax=handles.acceptorImageAxes;
        else
            ax=handles.fretImageAxes;
        end
    otherwise
        errordlg('Please pick either left or right')
        return
end
[refPeak i]=pickPoint(ax,channelDim,peakList);
handles.refPeak=refPeak;
highlightPeak(handles,refChannel,refPeak,'g+');
guidata(hObject,handles);


% --- Executes on button press in plotDonorFretButton.
function plotDonorFretButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotDonorFretButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lTrace=squeeze(handles.ltrace{1});
rTrace=squeeze(handles.rtrace{1});
plotFret(handles.fretCalcAxes,lTrace,rTrace,0);

% --- Executes on button press in calcFretButton.
function calcFretButton_Callback(hObject, eventdata, handles)
% hObject    handle to calcFretButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function setLeftThresholdButton_Callback(hObject, eventdata, handles)
% hObject    handle to setLeftThresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
leftThresholdToggleMsg=sprintf('%s%s%s\n%s',['Set left threshold by entering a value >0. '...
    'A value of 0 uses a gui to set threshold. '...
    'Current left threshold is: '],num2str(handles.leftThresholdToggle),'.','Change to:');
leftThresholdToggleString=inputdlg(leftThresholdToggleMsg);
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
handles.rightThresholdToggle=str2num(rightThresholdToggleString{1});
guidata(hObject,handles);


% --------------------------------------------------------------------
<<<<<<< HEAD
function toolButton_Callback(hObject, eventdata, handles)
% hObject    handle to toolButton (see GCBO)
=======
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
>>>>>>> parent of 6da2d62... Add a function to watch movies of the traces (under tools)
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
<<<<<<< HEAD
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
        if isvalid(handles.acceptorMovieHandle)
            close(handles.acceptorMovieHandle);
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
=======
'Done Plotting'
>>>>>>> parent of 6da2d62... Add a function to watch movies of the traces (under tools)
