%Given a peak index highlight the proper peaks
%Edit to be more flexible on 3/17/2017
%Jared Bard
%March 2, 2017
function [handles] = plotPoint2(handles,whichChannel,peaks1,peaks2)
    function h=plotTrace(ax,plotObject,trace)
        trace=squeeze(trace);
        len=length(trace);
        peak_int=trace(2,:)-trace(3,:);
        set(plotObject,'XData',1:len,'YData',peak_int);
        set(ax,'Ylim',[0 max(peak_int)]);
    end

    function h=plotLeft(handles,leftPeaks)
        plots=handles.plots;
        nLeftPeaks=size(leftPeaks,1);
        for i=1:nLeftPeaks
            set(plots.gDonorImage,'XData',leftPeaks(i,1),...
                'YData',leftPeaks(i,2));
            pTform=transformPointsForward(handles.tform,leftPeaks(i,1:2));
            set(plots.bFretImage,'XData',pTform(:,1),'YData',pTform(:,2));
            if handles.alexToggle
                set(plots.bAcceptorImage,'XData',pTform(:,1),...
                    'YData',pTform(:,2));
        end
        %run trace(s) unless already calculated
        if ~handles.allTracesCalculated
            leftTraces=tracemovie(handles.donorFile,handles.rinnercircle,...
                handles.routercircle,handles.nImagesAvg,...
                1,leftPeaks,handles.left_dim);
            handles.donorTrace=leftTraces{1};
        else
            handles.donorTrace=handles.allDonorTraces(handles.peakl_i,:,:);
        end
        %plot the first trace
        plotTrace(handles.donorTraceAxes,plots.donorTrace,...
            handles.donorTrace);
        end
        h=handles;
    end

    function h=plotRight(handles,rightPeaks)
        plots=handles.plots;
        nRightPeaks=size(rightPeaks,1);
        
        for i=1:nRightPeaks
            set(plots.gFretImage,'XData',rightPeaks(i,1),...
                'YData',rightPeaks(i,2));
            if handles.alexToggle
                set(plots.gAcceptorImage,'XData',rightPeaks(i,1),...
                    'YData',rightPeaks(i,2));
            end
            
            pTform=transformPointsInverse(handles.tform,rightPeaks(i,1:2));
            set(plots.bDonorImage,'XData',pTform(:,1),'YData',pTform(:,2));
        end
        
        %run trace(s)
        try
        if handles.alexToggle
            if ~handles.allTracesCalculated
                acceptorTraces=tracemovie(handles.acceptorFile,...
                    handles.rinnercircle,handles.routercircle,...
                    handles.nImagesAvg,1,rightPeaks,...
                    handles.right_dim);
                handles.acceptorTrace=acceptorTraces{1};
            else
               handles.acceptorTrace=handles.allAcceptorTraces...
                   (handles.peakr_i,:,:);
            end
            plotTrace(handles.acceptorTraceAxes,plots.acceptorTrace,....
                handles.acceptorTrace);
        end
        
        if ~handles.allTracesCalculated
            fretTraces=tracemovie(handles.donorFile,...
                handles.rinnercircle,handles.routercircle,...
                handles.nImagesAvg,1,rightPeaks,...
                handles.right_dim);
            handles.fretTrace=fretTraces{1};
        else
            handles.fretTrace=handles.allFretTraces...
                (handles.peakr_i,:,:);
        end
        plotTrace(handles.fretTraceAxes,plots.fretTrace,...
            handles.fretTrace);
        h=handles;
        catch ME
            errordlg('Please Reload the Movie or turn off ALEX')
            rethrow(ME)
        end
    end

switch whichChannel
    case 'left'
        handles=plotLeft(handles,peaks1);
    case 'right'
        handles=plotRight(handles,peaks1);
    case 'both'
        handles=plotLeft(handles,peaks1);
        handles=plotRight(handles,peaks2);
        %plot FRET
        lTrace=squeeze(handles.donorTrace);
        rTrace=squeeze(handles.fretTrace);
        plotFret(handles,lTrace,rTrace,0);
end
end
