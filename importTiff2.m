function [image] = importTiff2(file,start,stop)
%Jared Bard
%November 4 2013
%Uses Matlab Tiff library to import a stack of Tiff files into an array
%July 18, 2018 edited to add start and stop -JB
%Determine paramters of image file
file_info=imfinfo(file);
file_x=file_info(1).Width;
file_y=file_info(1).Height;
file_length=stop-start+1;
image=zeros(file_x,file_y,file_length,'int16');

%Initialize Tiff library and import images
file_Tiff=Tiff(file,'r');
count = 1;
for i=start:stop
    file_Tiff.setDirectory(i);
    image(:,:,count)=int16(file_Tiff.read());
    count = count + 1;
end
