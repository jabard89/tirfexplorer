function [pindex]=indexPeaks(image_size,peaks,rinnercircle,routercircle,...
    nImagesProcess,nImagesAvg)
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
nPeaks=size(peaks,1);
nFrames=size(peaks,3);
pindex=cell(nPeaks,2,nFrames);

nA=nImagesAvg;
nRemainder=mod(nImagesProcess-1,nImagesAvg);
for cIm=1:nA:nImagesProcess-nRemainder
    %First fill in previous frames
    if cIm>1
        pindex(:,:,cIm-nA+1:cIm-1)=repmat(pindex(:,:,cIm-nA),1,1,nA-1);
    end
    %Then recalculate peak index for each peak
    for i=1:nPeaks
        [pindex{i,1,cIm} pindex{i,2,cIm}]=...
            MakeCircle(image_size,peaks(i,1:2,cIm),...
            rinnercircle,routercircle);
    end
end
%Fill out indices with last few frames
if nRemainder>0
    cIm=cIm+nRemainder;
    pindex(:,:,cIm-nRemainder+1:cIm)=...
        repmat(pindex(:,:,cIm-nRemainder),1,1,nRemainder);
end