%Given a peak index highlight the proper peaks
%Edit to be more flexible on 3/17/2017
%Jared Bard
%March 2, 2017
%Edited on July 27, 2018 to change plot layout and plot FRET and Total
%Currently a bit of a hack, needs restructuring
%For instance, the Ymin and YMax determination is out of whack
function [handles] = plotPoint2(handles,whichChannel,peaks1,peaks2)
    function h=plotTrace(ax,plotObject,trace,overwriteYLim)
        if nargin < 4
            overwriteYLim = 1;
        end
        
        trace=squeeze(trace);
        len=length(trace);
        peakInt=trace(2,:).*trace(4,:)-trace(3,:).*trace(4,:);
        
        set(plotObject,'XData',1:len,'YData',peakInt);
        
        %Set the axis limits
        %First check the overwrite toggle
        if overwriteYLim
            if min(peakInt)<0
                yMin = min(peakInt);
            else
                yMin = 0;
            end
            set(ax,'Ylim',[yMin 1.2.*max(peakInt)]);
        else
            %check current axes
            yLimits = get(ax,'YLim');
            yMin = yLimits(1);
            yMax = yLimits(2);
            if min(peakInt) < yMin
                yMin = min(peakInt);
            end
            
            if max(peakInt) > yMax
                yMax = 1.2.*max(peakInt);
            end
            set(ax,'YLim',[yMin yMax]);
        end
    end

    function h=plotBkgd(ax,plotObject1,plotObject2,trace,overwriteYLim)
        if nargin < 5
            overwriteYLim = 1;
        end
        
        trace=squeeze(trace);
        len=length(trace);
        peakInt=trace(2,:).*trace(4,:);
        bkgdInt=trace(3,:).*trace(4,:);
        set(plotObject1,'XData',1:len,'YData',peakInt);
        set(plotObject2,'XData',1:len,'YData',bkgdInt);
        
        %Set the axis limits
        %First check the overwrite toggle
        if overwriteYLim
            if min(bkgdInt) < 0
                yMin = min(bkgdInt);
            else
                yMin = 0;
            end
            set(ax,'Ylim',[yMin 1.2.*max(peakInt)]);
        else
            %check current axes
            yLimits = get(ax,'YLim');
            yMin = yLimits(1);
            yMax = yLimits(2);
            if min(bkgdInt) < yMin
                yMin = min(bkgdInt);
            end
            
            if max(peakInt) > yMax
                yMax = 1.2.*max(peakInt);
            end
            set(ax,'YLim',[yMin yMax]);
        end
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
        plotTrace(handles.overlayTraceAxes,plots.donorOverlayTrace,...
            handles.donorTrace,1);
        if handles.figureLayoutToggle
            plotBkgd(handles.donorTraceAxes,plots.donorTrace,...
                plots.donorBkgdTrace,handles.donorTrace,1);
        end
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
        plotTrace(handles.overlayTraceAxes,plots.fretOverlayTrace,...
            handles.fretTrace,0);
        if handles.figureLayoutToggle
            plotBkgd(handles.fretTraceAxes,plots.fretTrace,...
                plots.fretBkgdTrace,handles.fretTrace,1);
        end
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
        plotFret(handles,lTrace,rTrace);
end
end
