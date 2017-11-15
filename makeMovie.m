function [movie]=makeMovie(file,nImagesProcess,dim)
%%Convert file into a stack of uint8 images
%Jared Bard November 9, 2017
%%First extract file information from the tif file
file_info=imfinfo(file);
file_x=file_info(1).Width;
file_y=file_info(1).Height;
x_start=dim(1);
x_end=dim(2);
y_start=dim(3);
y_end=dim(4);
%initialize movie stack
movie=zeros(y_end-y_start+1,x_end-x_start+1,nImagesProcess,'uint8');
%%Extract frames
file_Tiff=Tiff(file,'r');
warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
for j=1:nImagesProcess
    file_Tiff.setDirectory(j);
    image=file_Tiff.read();
    temp=double(image(y_start:y_end,x_start:x_end));
    temp_min=min(min(temp));
    temp_max=max(max(temp));
    temp_scaled=(temp-temp_min)./temp_max;
    temp_gray=im2uint8(temp_scaled);
    movie(:,:,j)=temp_gray;
end