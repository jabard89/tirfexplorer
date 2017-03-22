function imstruct=loadAverage(file,start,stop)
%%Loads Average Image from x frames of a tif file
%Jared Bard August 20,2014
file_info=imfinfo(file);
file_x=file_info(1).Width;
file_y=file_info(1).Height;
image_avg=zeros(file_y,file_x);
%Initialize Tiff library and import images
file_Tiff=Tiff(file,'r');
warning off;
for i=start:stop
    file_Tiff.setDirectory(i);
    image_temp=double(file_Tiff.read());
    image_avg=image_avg+image_temp./(stop-start+1);
end
imstruct=struct('avg',uint16(image_avg));
end