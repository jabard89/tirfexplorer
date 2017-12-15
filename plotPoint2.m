%Given a peak index highlight the proper peaks
%Edit to be more flexible on 3/17/2017
%Jared Bard
%March 2, 2017
function [handles] = plotPoint2(handles,whichChannel,peaks1,peaks2)
exp=handles.exp;
if handles.alexToggle
    expAcceptor=handles.expAcceptor;
end
%Start by redrawing both channels
%Redraw left channel
axes(handles.donorImageAxes);
hold off
imshow(exp.avgl,[])
hold on
plot(exp.lfilt(:,1),exp.lfilt(:,2),'yo')
plot(exp.linked_lpeaks(:,1),exp.linked_lpeaks(:,2),'ro')
hold off
%Redraw Right Channel
if handles.alexToggle
    axes(handles.fretImageAxes);
    hold off;
    imshow(exp.avgr,[])
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    hold off
    axes(handles.acceptorImageAxes);
    hold off;
    imshow(expAcceptor.avgr,[])
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    hold off
else
    axes(handles.fretImageAxes);
    hold off
    imshow(exp.avgr,[])
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    hold off
end
    function h=plotTrace(ax,trace)
        trace=squeeze(trace);
        len=length(trace);
        axes(ax);
        hold off;
        % plot(1:len,smooth(trace1(2,:)))
        % hold on
        % plot(1:len,smooth(trace1(3,:)))
        % legend({'Peak','Background'})
        % hold off
        peak_int=trace(2,:)-trace(3,:);
        plot(1:len,peak_int)
        ylim([0 max(peak_int)])
    end

%Now highlight appropriate peaks and calculate their traces
switch whichChannel
    case 'left'
        leftPeaks=peaks1;
        nleftPeaks=size(peaks1,1);
        
        for i=1:nleftPeaks
            highlightPeak(handles,'left',leftPeaks(1,:),'go');
            p_tform=transformPointsInverse(handles.tform,leftPeaks(1,1:2));
            highlightPeak(handles,'right',p_tform,'bo');
        end
        %run trace(s)
        leftTraces=tracemovie(handles.donorFile,handles.rinnercircle,...
            handles.routercircle,1,leftPeaks,handles.left_dim);
        handles.ltrace=leftTraces;
        %plot the first trace
        plotTrace(handles.donorTraceAxes,leftTraces{1});
        %finally plot any right points currently selected
        if isfield(handles,'peakr_i')
            p=exp.rfilt(handles.peakr_i,:);
            highlightPeak(handles,'right',p,'go')
        end
        
    case 'right'
        rightPeaks=peaks1;
        nrightPeaks=size(peaks1,1);
        
        for i=1:nrightPeaks
            highlightPeak(handles,'right',rightPeaks(1,:),'go');
            p_tform=transformPointsForward(handles.tform,rightPeaks(1,1:2));
            highlightPeak(handles,'left',p_tform,'bo');
        end
        %run trace(s)
        if handles.alexToggle
            rightAcceptorTraces=tracemovie(handles.acceptorFile,...
                handles.rinnercircle,handles.routercircle,1,rightPeaks,...
                handles.right_dim);
            handles.rAcceptortraces=rightAcceptorTraces;
            plotTrace(handles.acceptorTraceAxes,rightAcceptorTraces{1});
        end
        rightTraces=tracemovie(handles.donorFile,...
            handles.rinnercircle,handles.routercircle,1,rightPeaks,...
            handles.right_dim);
        handles.rtrace=rightTraces;
        %plot the first trace
        plotTrace(handles.fretTraceAxes,rightTraces{1});
        
        %finally plot any left points currently selected
        if isfield(handles,'peakl_i')
            p=exp.lfilt(handles.peakl_i,:);
            highlightPeak(handles,'left',p,'go')
        end
        
    case 'both'
        leftPeaks=peaks1;
        nleftPeaks=size(leftPeaks,1);
        rightPeaks=peaks2;
        nrightPeaks=size(rightPeaks,1);
        
        for i=1:nleftPeaks
            highlightPeak(handles,'left',leftPeaks(1,:),'go');
        end
        %run trace(s)
        leftTraces=tracemovie(handles.donorFile,...
            handles.rinnercircle,handles.routercircle,1,leftPeaks,...
            handles.left_dim);
        handles.ltrace=leftTraces;
        %plot the first trace
        plotTrace(handles.donorTraceAxes,leftTraces{1});
        
        for i=1:nrightPeaks
            highlightPeak(handles,'right',rightPeaks(1,:),'go');
        end
        %run trace(s)
        if handles.alexToggle
            rightAcceptorTraces=tracemovie(handles.acceptorFile,...
                handles.rinnercircle,handles.routercircle,1,rightPeaks,...
                handles.right_dim);
            handles.rAcceptortraces=rightAcceptorTraces;
            plotTrace(handles.acceptorTraceAxes,rightAcceptorTraces{1});
        end
        rightTraces=tracemovie(handles.donorFile,...
            handles.rinnercircle,handles.routercircle,1,rightPeaks,...
            handles.right_dim);
        handles.rtrace=rightTraces;
        %plot the first trace
        plotTrace(handles.fretTraceAxes,rightTraces{1});
        
        %plot FRET
        lTrace=squeeze(leftTraces{1});
        rTrace=squeeze(rightTraces{1});
        plotFret(handles.fretCalcAxes,lTrace,rTrace,0);
end
if handles.driftToggle
    highlightPeak(handles,handles.refChannel,handles.refPeak,'g+');
end
setAxesProperties(handles);
end
