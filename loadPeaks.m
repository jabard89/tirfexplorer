%%Finds peaks for a stack of images, filters them, and loads them into an
%%array
%Jared Bard
%November 14, 2017
function h = loadPeaks(handles)
%Load variables from handles
nImagesProcess=handles.nImagesProcess;
donorFile=handles.donorFile;
left_dim=handles.left_dim;
right_dim=handles.right_dim;
exp=handles.exp;
if handles.alexToggle
    acceptorFile=handles.acceptorFile;
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
handles.exp=exp;
h=handles;