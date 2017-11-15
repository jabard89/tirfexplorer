%%Peak List Export
%Jared Bard
%November 13, 2017
%Exports all peaks or all linked peaks as [x y]
function exportPeaks(exp,cpToggle,linkedToggle)
if nargin < 2
    linkedToggle = 0;
    cpToggle = 0;
elseif nargin < 3
    linkedToggle = 0;
end

if cpToggle
    %For control points, want [moving fixed], so right peaks first
    cpPeaks=[exp.linked_rpeaks(:,1:2,1) exp.linked_lpeaks(:,1:2,1)];
    cpPeaksName=inputdlg('Name the Control Points');
    assignin('base',cpPeaksName{1},cpPeaks);
    return
end

if linkedToggle
    leftPeaks=exp.linked_lpeaks(:,1:2,1);
    rightPeaks=exp.linked_rpeaks(:,1:2,1);
    leftPeakName=inputdlg('Name the Left Peak File');
    assignin('base',leftPeakName{1},leftPeaks);
    rightPeakName=inputdlg('Name the Right Peak File');
    assignin('base',rightPeakName{1},rightPeaks);
else
    leftPeaks=exp.lfilt(:,1:2,1);
    rightPeaks=exp.rfilt(:,1:2,1);
    leftPeakName=inputdlg('Name the Left Peak File');
    assignin('base',leftPeakName{1},leftPeaks);
    rightPeakName=inputdlg('Name the Right Peak File');
    assignin('base',rightPeakName{1},rightPeaks);
end