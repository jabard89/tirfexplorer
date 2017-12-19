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
    [cpName cpPath]=uiputfile('.csv','Save the Control Points');
    if  cpName
        csvwrite([cpPath, cpName],cpPeaks);
    end
    return
end

if linkedToggle
    leftPeaks=exp.linked_lpeaks(:,1:2,1);
    rightPeaks=exp.linked_rpeaks(:,1:2,1);
else
    leftPeaks=exp.lfilt(:,1:2,1);
    rightPeaks=exp.rfilt(:,1:2,1);
end

[leftPeakName leftPeakPath]=...
    uiputfile('.csv','Name the Left Peak File');
if leftPeakName
    csvwrite([leftPeakPath,leftPeakName],leftPeaks);
end
[rightPeakName rightPeakPath]=...
    uiputfile('.csv','Name the Right Peak File');
if rightPeakName
    csvwrite([rightPeakPath,rightPeakName],rightPeaks);
end