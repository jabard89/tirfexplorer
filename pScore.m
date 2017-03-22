function [intensities]=pScore(image,pindex)%%Intensity Finder
%Jared Bard August 13, 2014
%Based on twoTone, with some inspiration from Ha lab scrips
    % Twotone TIRF-FRET image analysis software.
    % Version 3.1.0 Alpha, released 101115
    % Authors: Seamus J Holden, Stephan Uphoff
    % Email: s.holden1@physics.ox.ac.uk
    % Copyright (C) 2010, Isis Innovation Limited.
    % All rights reserved.
%Given an image with an index of pixels to evaluate (from indexPeaks),
%calculates the intensity of each peak (total signal minus background
%signal)
%also calculates the background level by calculating the intensity of a
%ring around the inner circle, with a total radius of routerCircle. the
%mean intensity of that ring is then used to calculate the total background
%of the inner circle
%Output also has paramaters below for each intensity
%[circleAvg; ringAvg; totalCirclePixels; totalRingPixels]

%%load image paramaters and initialize structure
x_lim=size(image,2);
y_lim=size(image,1);
npeaks=size(pindex,1);
image=double(image);

%%Calculate intensities
circleTotal=0;
ringTotal=0;
circleAvg=0;
ringAvg=0;
circleSize=0;
ringSize=0;
intensities=zeros(npeaks,1);
param=zeros(npeaks,4);
for i = 1:npeaks
    ringSize=numel(pindex{i,1});
    circleSize=numel(pindex{i,2});
    circleTotal=sum(image(pindex{i,2}));
    ringTotal=sum(image(pindex{i,1}));
    ringAvg=ringTotal/ringSize;
    circleAvg=circleTotal/circleSize;
    peakIntensity=circleTotal-ringAvg.*circleSize;
    intensities(i,1)=peakIntensity;
    intensities(i,2:5)=[circleAvg ringAvg circleSize ringSize];
end
end