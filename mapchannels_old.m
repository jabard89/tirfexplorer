function [cp, tform,image2t,fusion] = mapchannels(image1,image2)
%%Calculates transformation between two channels 
%Jared Bard August 08, 2014
%Ues matlab tools cpselect, imwarp and and fitgeotrans to calculate the
%transformation that maps ch2 onto ch1 using the Projective algorithm
%takes as input an image structure containing at least image.ch1 and
%image.ch2 of same size
%outputs a false-colored overlay of the two images made with imfuse
%%Opens up cpselect and saves the output
%ch2 is the moving channel, ch1 is the fixed channel
temp_1=uint16(double(image1).*(2^16./double(max(image1(:)))));
temp_2=uint16(double(image2).*(2^16./double(max(image2(:)))));
[moving fixed]=cpselect(temp_2,temp_1,'Wait',true);
cp=[moving fixed];
%%Calculate Transformation
%store both the transformation matrix and the transformed Ch2
tform=cp2tform(moving,fixed,'piecewise linear');
%use 
image2t=imtransform(image2,tform);
%%Calculates the overlay between the two
fusion=imfuse(image2t,image1);
end

%%can then use tforminv to convert points from image1 into image2
%[x_t y_t]=tforminv(tform,x,y)