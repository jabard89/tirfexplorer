function varargout = tirfexplorer(varargin)
% TIRFEXPLORER MATLAB code for tirfexplorer.fig
%      TIRFEXPLORER, by itself, creates a new TIRFEXPLORER or raises the existing
%      singleton*.
%
%      H = TIRFEXPLORER returns the handle to a new TIRFEXPLORER or the handle to
%      the existing singleton*.
%
%      TIRFEXPLORER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIRFEXPLORER.M with the given input arguments.
%
%      TIRFEXPLORER('Property','Value',...) creates a new TIRFEXPLORER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tirfexplorer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tirfexplorer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tirfexplorer

% Last Modified by GUIDE v2.5 03-Mar-2017 14:59:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tirfexplorer_OpeningFcn, ...
                   'gui_OutputFcn',  @tirfexplorer_OutputFcn, ...
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

% --- Executes just before tirfexplorer is made visible.
function tirfexplorer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tirfexplorer (see VARARGIN)

% Choose default command line output for tirfexplorer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using tirfexplorer.


% UIWAIT makes tirfexplorer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tirfexplorer_OutputFcn(hObject, eventdata, handles)
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
axes(handles.axes1);
cla;
guidata(hObject,handles)
file=handles.file;
n_images=handles.n_images;
% left_dim=[25 235 10 500];
% right_dim=[269 479 9 499];
% handles.left_dim=left_dim;
% handles.right_dim=right_dim;
left_dim=handles.left_dim;
right_dim=handles.right_dim;
exp=loadAverage(file,1,n_images);
exp.avgl=exp.avg(left_dim(3):left_dim(4),left_dim(1):left_dim(2));
exp.avgr=exp.avg(right_dim(3):right_dim(4),right_dim(1):right_dim(2));
counter=-4;
exp.lfilt=[];
exp.rfilt=[];
%dimensions=[x_start x_end y_start y_end]

for i=1:floor(n_images/5)
    counter=counter+5
    %first load a moving average of the image
    temp=loadAverage(file,i,5);
    temp.l=temp.avg(left_dim(3):left_dim(4),left_dim(1):left_dim(2));
    temp.r=temp.avg(right_dim(3):right_dim(4),right_dim(1):right_dim(2));
    %then find all the peaks in the image and filter them for crowding and
    %shape of the peak
    temp.lp=findPeaks(temp.l);
    temp.rp=findPeaks(temp.r);
    temp.lfilt=filterPeaks(temp.l,temp.lp,10,2);
    temp.rfilt=filterPeaks(temp.r,temp.rp,10,2);
    n_lfilt=size(exp.lfilt,1);
    n_rfilt=size(exp.rfilt,1);
    %filter out new peaks from the temporary images by comparing against
    %the previous list
    for j=1:size(temp.lfilt,1)
        flag=1;
        for k=1:n_lfilt
            if pdist([temp.lfilt(j,1:2);exp.lfilt(k,1:2)]) < 5
                flag=0;
                break
            end
        end
        %if it passes, add to the list of peaks
        if flag==1
            exp.lfilt=[exp.lfilt;temp.lfilt(j,:)];
        end
    end
    for j=1:size(temp.rfilt,1)
        flag=1;
        for k=1:n_rfilt
            if pdist([temp.rfilt(j,1:2);exp.rfilt(k,1:2)]) < 5
                flag=0;
                break
            end
        end
        if flag==1
            exp.rfilt=[exp.rfilt;temp.rfilt(j,:)];
        end
    end
    %report progress
    temp
    size(exp.lfilt)
    size(exp.rfilt)
end
%find matching pairs between the two channels
[exp.linknames exp.linki exp.lpeaksl exp.lpeaksr]=linkPeaks(handles.tform,exp.lfilt,exp.rfilt,4);
handles.exp=exp;
%Update the list of peaks
set(handles.listbox2,'String',handles.exp.linknames)
guidata(hObject,handles);

%Plot peaks on images
axes(handles.axes2);
imshow(exp.avgl,[])
hold on
plot(exp.lfilt(:,1),exp.lfilt(:,2),'yo')
plot(exp.lpeaksl(:,1),exp.lpeaksl(:,2),'ro')
hold off
axes(handles.axes3);
imshow(exp.avgr,[])
hold on
plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
plot(exp.lpeaksr(:,1),exp.lpeaksr(:,2),'ro')
hold off
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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename='';
pathname='';
[filename, pathname]=uigetfile('*.tif','Open Tirf','E:\Martin\Data\TIRF!');
handles.file=[pathname filename];
set(handles.text1,'String',filename);
guidata(hObject,handles);


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
try
%[point(1) point(2)]=ginputc(1,'Color','r');
[x_p y_p]=getpts(handles.axes2);
channel_dim=handles.left_dim;
win_dim=[channel_dim(2)-channel_dim(1) channel_dim(4)-channel_dim(3)];
%make sure correct point is selected
if size(x_p,1) > 1
    msgbox('Pick Only One Point')
    return
elseif x_p > win_dim(1) || y_p > win_dim(2)
    msgbox('Pick a Point in the Correct Channel')
    return
end

p_box=[x_p-3 y_p-3;x_p+3 y_p+3];
%load peak list
list=handles.exp.lfilt;
%Find nearest peak using sequential search
near=list(find(list(:,1)>p_box(1,1)),:);
near=near(find(near(:,1)<p_box(2,1)),:);
near=near(find(near(:,2)>p_box(1,2)),:);
near=near(find(near(:,2)<p_box(2,2)),:);
if size(near,1) > 1
    msgbox('Too many points')
    return
elseif size(near,1) < 1
    msgbox('No point selected')
    return
end
%Export peak name to handles
[found peakl_i]=ismember(near,list,'rows');
handles.peakl_i=peakl_i;
handles=plotpoint(handles,'left',near);
guidata(hObject,handles)
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
[x_p y_p]=getpts(handles.axes3);
channel_dim=handles.right_dim;
win_dim=[channel_dim(2)-channel_dim(1) channel_dim(4)-channel_dim(3)];
%make sure correct point is selected
if size(x_p,1) > 1
    msgbox('Pick Only One Point')
    return
elseif x_p > win_dim(1) || y_p > win_dim(2)
    msgbox('Pick a Point in the Correct Channel')
    return
end

p_box=[x_p-3 y_p-3;x_p+3 y_p+3];
%load peak list
list=handles.exp.rfilt;
%Find nearest peak using sequential search
near=list(find(list(:,1)>p_box(1,1)),:);
near=near(find(near(:,1)<p_box(2,1)),:);
near=near(find(near(:,2)>p_box(1,2)),:);
near=near(find(near(:,2)<p_box(2,2)),:);
if size(near,1) > 1
    error('Too many points')
elseif size(near,1) < 1
    error('No point selected')
end
[found peakr_i]=ismember(near,list,'rows');
handles.peakr_i=peakr_i;
handles=plotpoint(handles,'right',near);
guidata(hObject,handles)
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Calculate Relative traces
ltrace=handles.ltrace;
rtrace=handles.rtrace;
lt=smooth(ltrace(2,:)-ltrace(3,:));
rt=smooth(rtrace(2,:)-rtrace(3,:));
%scale lt and rt to min and max
lt_s=lt./max(lt);
rt_s=rt./max(rt);
axes(handles.axes5);
len=length(ltrace);
hold off
plot(1:len,lt_s)
axis([0 len 0 1]);
hold on
plot(1:len,rt_s)
legend({'Cy3','Cy5'})



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Edit box for controlling how many images get averaged
n_images=str2num(get(hObject,'String'));
handles.n_images=n_images;
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
n_images=10;
handles.n_images=n_images;
guidata(hObject,handles);

% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
a='apple';
peak_i=get(hObject,'Value');
handles.peakl_i=peak_i;
handles.peakr_i=peak_i;
peak1=handles.exp.lpeaksl(peak_i,1:2);
peak2=handles.exp.lpeaksr(peak_i,1:2);
handles.peak1=peak1;
handles.peak2=peak2;
handles=plotpoint(handles,'both',peak1,peak2);
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

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
left_string=strsplit(get(hObject,'String'));
left_dim=[25 235 10 500];
for i=1:4
    left_dim(i)=str2num(left_string{i});
end
handles.left_dim=left_dim;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
left_dim=[25 235 10 500];
handles.left_dim=left_dim;
guidata(hObject,handles);

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
right_string=strsplit(get(hObject,'String'));
right_dim=[269 479 9 499];
for i=1:4
    right_dim(i)=str2num(right_string{i});
end
handles.right_dim=right_dim;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
right_dim=[269 479 9 499];
handles.right_dim=right_dim;
guidata(hObject,handles);


% --------------------------------------------------------------------
function export_t_Callback(hObject, eventdata, handles)
% hObject    handle to export_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Exports the current left and right traces as objects to the workspace
if isfield(handles,'ltrace')
    ltrace=handles.ltrace;
    peak_lname=inputdlg('Name the Left Peak');
    assignin('base',peak_lname{1},ltrace);
end
if isfield(handles,'rtrace')
    rtrace=handles.rtrace;
    peak_rname=inputdlg('Name the Right Peak');
    assignin('base',peak_rname{1},rtrace);
end