function [shift] = calcDrift(ref,image)
%Given an array of peaks(nPeaks,peakpos), calculates how far a 
%reference peak has shifted from its original position
[a b c pos e]=freeGaussFitEllipse(image,ref(1:2),4,2,[0 50],[0],...
    'autoDetect', {'useMatlabFit'});
shift=pos-ref(1:2);
if any(shift>1)
    shift=[NaN];
end