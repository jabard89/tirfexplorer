function alignMovie4()
welcomeMsg=sprintf('%s','Aligning Movie');
disp(welcomeMsg);
path='';
file='';
[file path]=uigetfile('.tif')
times=extractTimeStamps([path file]);
alexToggle=0; % Not interlaced

%180702
dY0 = 1; %donor Y0
dYend = 512;
dX0 = 9;
dXend = 252;
xLength = dXend - dX0;
yLength = dYend - dY0;
aY0 = 1; %acceptor Y0
aYend = aY0 + yLength;
aX0 = 265;
aXend = aX0 + xLength;

%180123
% dY0 = 2; %donor Y0
% dYend = 512;
% dX0 = 21;
% dXend = 252;
% xLength = dXend - dX0;
% yLength = dYend - dY0;
% aY0 = 1; %acceptor Y0
% aYend = aY0 + yLength;
% aX0 = 272;
% aXend = aX0 + xLength;

fileInfo=imfinfo([path file]);
%Which Frames should be extracted?
start = 10;
stop = length(fileInfo);

nImages=stop-start+1;
times=times(start:stop);

warning('off')
temp = importTiff2([path file],start,stop);

if alexToggle
    temp=temp(:,:,2:2:nImages);
    sizeTrimmed = [yLength+1 xLength+1 ceil(nImages./2)];
else
    sizeTrimmed = [yLength+1 xLength+1 nImages];
end
% 
tempAligned=zeros(sizeTrimmed,'uint16');
tempAligned(1:1+yLength,1:1+xLength,:)= ...
   temp(dY0:dYend,dX0:dXend,:);
tempAligned(1:1+yLength,xLength+2:xLength+2+xLength,:)= ...
   temp(aY0:aYend,aX0:aXend,:);

%Just the first frame
% tempAligned=zeros(sizeTrimmed,'uint16');
% tempAligned(1:1+yLength,1:1+xLength)= ...
%    temp(dY0:dYend,dX0:dXend);
% tempAligned(1:1+yLength,xLength+2:xLength+2+xLength)= ...
%    temp(aY0:aYend,aX0:aXend);

%Switched Donor and acceptor
% tempAligned(1:1+yLength,1:1+xLength,:)= ...
%    temp(aY0:aYend,aX0:aXend,:);
% tempAligned(1:1+yLength,xLength+2:xLength+2+xLength,:)= ...
%    temp(dY0:dYend,dX0:dXend,:);

[saveFile savePath]=uiputfile('.tif')
options.overwrite=true;
t=saveastifftime(tempAligned,times,[savePath saveFile],options);
warning('on')
farewellMsg=sprintf('%s\n','Finished!');
display(farewellMsg);
end
%Add this to Movie_TIFF in gettraces at line 113
%                 elseif isfield (info,'ImageDescription')
%                     for j=1:numel(info)
%                         timeTemp(j)=str2num(info(j).ImageDescription);
%                     end
%                     times{i} = timeTemp;