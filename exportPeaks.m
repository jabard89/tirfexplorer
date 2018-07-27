%%Peak List Export
%Jared Bard
%November 13, 2017
%Exports all peaks or all linked peaks as [x y]
function exportPeaks(exp,cpToggle,linkedToggle,whichPeaks)
if nargin < 2
    linkedToggle = 0;
    cpToggle = 0;
    whichPeaks = 'both';
elseif nargin < 3
    linkedToggle = 0;
    whichPeaks = 'both';
elseif nargin < 4
    whichPeaks = 'both';
end

switch whichPeaks
    case 'left'
    [leftPeakName leftPeakPath]=...
    uiputfile('.csv','Name the Left Peak File');
    leftPeaks=exp.lfilt(:,1:2,1);
    if leftPeakName
        csvwrite([leftPeakPath,leftPeakName],leftPeaks);
    end

    case 'right'
    [rightPeakName rightPeakPath] = ...
        uiputfile('.csv','Name the Right Peak File');
    rightPeaks=exp.rfilt(:,1:2,1);
    if rightPeakName
        csvwrite([rightPeakPath,rightPeakName],rightPeaks);
    end
    
    otherwise
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
end
end