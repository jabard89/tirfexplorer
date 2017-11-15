function [image] = importTiff(file,l)
%Jared Bard
%November 4 2013
%Uses Matlab Tiff library to import a stack of Tiff files into an array

%Determine paramters of image file
tic
file_info=imfinfo(file);
file_x=file_info(1).Width;
file_y=file_info(1).Height;
file_length=l;
image=zeros(file_x,file_y,file_length,'int16');

%Initialize Tiff library and import images
file_Tiff=Tiff(file,'r');
for i=1:file_length
    file_Tiff.setDirectory(i);
    image(:,:,i)=file_Tiff.read();
    image(:,:,i)=int16(image(:,:,i));
end
toc
