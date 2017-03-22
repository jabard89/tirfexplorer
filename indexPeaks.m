function [pindex]=indexPeaks(image_size,peaks,rinnerCircle,routerCircle)
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
pindex=cell(npeaks,2);
for i =1:npeaks
    [pindex{i,1} pindex{i,2}]=MakeCircle(image_size,peaks(i,1:2),...
        rinnerCircle,routerCircle);
end
end