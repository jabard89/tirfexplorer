function [trace]=tracemovie_dim(file,rinnercircle,...
    routercircle,nch,peaks1,dim1,peaks2,dim2,peaks3,dim3)
%%Extract peak intensities from an image stack
%Jared Bard August 18, 2014
%Each channel will have a column in the peak_cell: 1=# of peaks,
%2=dimensions of channel, 3=list of peaks in that channel 4=indexes for
%each peak
%%First extract file information from the tif file
file_info=imfinfo(file);
file_x=file_info(1).Width;
file_y=file_info(1).Height;
file_length=length(file_info);
peak_cell=cell(nch,4);
if nch>=1
    peak_cell{1,1}=size(peaks1,1);
    peak_cell{1,3}=peaks1;
end
if nch>=2
    peak_cell{2,1}=size(peaks2,1);
    peak_cell{2,2}=dim2;
    peak_cell{2,3}=peaks2;
    
end
if nch==3
    peak_cell{3,1}=size(peaks3,1);
    peak_cell{3,2}=dim3;
    peak_cell{3,3}=peaks3;
end
%get dimensions of each channel;
trace=cell(nch,1);
if nch == 1
    x_start=dim1(1);
    x_end=dim1(2);
    y_start=dim1(3);
    y_end=dim1(4);
    peak_cell{1,2}=[x_start x_end y_start y_end];
    %calculate indexes of peaks based on size of peak (innercircle) and
    %size of background (routercircle)
    peak_cell{1,4}=indexPeaks([(y_end-y_start+1) (x_end-x_start+1)],...
            peak_cell{1,3},rinnercircle,routercircle);
else
%     x_start=0;
%     x_end=0;
%     y_start=0;
%     y_start=0;
    for i =1:nch
        x_start=peak_cell{i,2}(1);
        x_end=peak_cell{i,2}(2);
        y_start=peak_cell{i,2}(3);
        y_end=peak_cell{i,2}(4);
        %Generate peakIndex for each channel
        peak_cell{i,4}=indexPeaks([(y_end-y_start+1) (x_end-x_start+1)],...
            peak_cell{i,3},rinnercircle,routercircle);
        %initialize array to store traces
        trace{i,1}=zeros(peak_cell{i,1},5,file_length,'int16');
    end
end

%%Extract intensities
file_Tiff=Tiff(file,'r');
warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
for j=1:file_length
    file_Tiff.setDirectory(j);
    image=file_Tiff.read();
    for i=1:nch
        x_start=peak_cell{i,2}(1);
        x_end=peak_cell{i,2}(2);
        y_start=peak_cell{i,2}(3);
        y_end=peak_cell{i,2}(4);
        temp_i=image(y_start:y_end,x_start:x_end);
        peaks=peak_cell{i,3};
        trace{i,1}(:,:,j)=pScore(temp_i,peak_cell{i,4});
    end
    if mod(j,25)==0
        fprintf(['\n' num2str(j) '\n']);
    end
end
end