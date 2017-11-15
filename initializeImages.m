%%Initalizes a new image for tirfexplorer
%Jared Bard
%November 14, 2017
function h = initializeImages(handles)
%clear listbox
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
    handles.expAcceptor=expAcceptor;
end
handles.exp=exp;
h=handles;