function [particles thresh] = findPeaks(im,thresh)
%%Peak Finding Algorithm
%Finds peaks in TIRF images, using functions from twoTones
    % Twotone TIRF-FRET image analysis software.
    % Version 3.1.0 Alpha, released 101115
    % Authors: Seamus J Holden, Stephan Uphoff
    % Email: s.holden1@physics.ox.ac.uk
    % Copyright (C) 2010, Isis Innovation Limited.
    % All rights reserved.
%also incorporates thresh_tool from Matlab central and bpass
    %copyright 1997, John C. Crocker and David G. Grier.
%imagestructs should contain an image imagestruct.avgi where is the channel
%to fit
%Each image will first be smoothed by passing through bpass, with an
%assumed spot size fewer than 5 pixels
%These filtered images are then thresholded with thresh_tool
%The thresholded images are then scanned, and all local maxima are recorded
%as initial peaks
%To identify sub-pixel locations of peaks, the twotones software is used to
%fit a gaussian point spread function to each peak and locate its center

%Data is returned as a X by 4 array, with the first two columns
%corresponding to the x and y positions of the peaks, and the remaining
%columns corresonding to each peaks brightness and eccentricity

%%Filter Image and find threshold
hp=1; %highpass spacial filter, leave at 1
lp=7; %number larger than expected radius of spots
im_filt=bpass(im,hp,lp);
if nargin<2
    thresh=thresh_tool(im_filt);
end

%%Use findpeaks3
bpdiameter=lp; 
windowsize=lp; %how far to let the gaussain fit algorithm search
out = findpeaks3(im_filt,im,thresh,bpdiameter,windowsize);
particles=out(:,1:4);
end