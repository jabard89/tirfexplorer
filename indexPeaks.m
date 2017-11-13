function [pindex]=indexPeaks(image_size,peaks,rinnercircle,routercircle)
%%Creates index of pixels to score
%Jared Bard August 19, 2014
%MakeCircle is based on the twoTone image suite
    % Twotone TIRF-FRET image analysis software.
    % Version 3.1.0 Alpha, released 101115
    % Authors: Seamus J Holden, Stephan Uphoff
    % Email: s.holden1@physics.ox.ac.uk
    % Copyright (C) 2010, Isis Innovation Limited.
    % All rights reserved.
%Given an image with an array of peaks (x1 y1;x2 y2;etc), outputs a list of
%pixels to score for intensity by pscore
%%Load Parameters
npeaks=size(peaks,1);
nFrames=size(peaks,3);
pindex=cell(npeaks,2,nFrames);
for i=1:npeaks
    for j=1:nFrames
        [pindex{i,1,j} pindex{i,2,j}]=MakeCircle(image_size,peaks(i,1:2,j),...
            rinnercircle,routercircle);
    end
end
end