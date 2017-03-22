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
axes(handles.axes2);
hold off
imshow(exp.avgl,[])
hold on
plot(exp.lfilt(:,1),exp.lfilt(:,2),'yo')
plot(exp.linked_lpeaks(:,1),exp.linked_lpeaks(:,2),'ro')
hold off
%Redraw Right Channel
if handles.alexToggle
    axes(handles.axes3);
    hold off;
    imshow(exp.avgr,[])
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    hold off
    axes(handles.axes6);
    hold off;
    imshow(expAcceptor.avgr,[])
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    hold off
else
    axes(handles.axes3);
    hold off
    imshow(exp.avgr,[])
    hold on
    plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
    plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
    hold off
end

    function f1=highlightPeak(channel,p,marker)
        %function to highlight a peak on either the right or left
        switch channel
            case 'left'
                axes(handles.axes2);
                hold on
                plot(p(1),p(2),marker);
                hold off
            case 'right'
                if handles.alexToggle
                    axes(handles.axes6);
                    hold on
                    plot(p(1),p(2),marker);
                    hold off
                    axes(handles.axes3);
                    hold on
                    plot(p(1),p(2),marker);
                    hold off
                else
                    axes(handles.axes3);
                    hold on
                    plot(p(1),p(2),marker);
                    hold off
                end
        end
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
    end

%Now highlight appropriate peaks and calculate their traces
switch whichChannel
    case 'left'
        leftPeaks=peaks1;
        nleftPeaks=size(peaks1,1);
        
        for i=1:nleftPeaks
            highlightPeak('left',leftPeaks(1,:),'go');
            p_tform=tforminv(handles.tform,leftPeaks(1,1:2));
            highlightPeak('right',p_tform,'bo');
        end
        %run trace(s)
        leftTraces=tracemovie_tif_dim(handles.donorFile,handles.rinnercircle,...
            handles.routercircle,1,leftPeaks,handles.left_dim);
        handles.ltrace=leftTraces;
        %plot the first trace
        plotTrace(handles.axes1,leftTraces{1});
        %finally plot any right points currently selected
        if isfield(handles,'peakr_i')
            p=exp.rfilt(handles.peakr_i,:);
            highlightPeak('right',p,'go')
        end
        
    case 'right'
        rightPeaks=peaks1;
        nrightPeaks=size(peaks1,1);
        
        for i=1:nrightPeaks
            highlightPeak('right',rightPeaks(1,:),'go');
            p_tform=tforminv(handles.tform,rightPeaks(1,1:2));
            highlightPeak('left',p_tform,'bo');
        end
        %run trace(s)
        if handles.alexToggle
            rightAcceptorTraces=tracemovie_tif_dim(handles.acceptorFile,...
                handles.rinnercircle,handles.routercircle,1,rightPeaks,...
                handles.right_dim);
            handles.rAcceptortraces=rightAcceptorTraces;
            plotTrace(handles.axes7,rightAcceptorTraces{1});
        end
        rightTraces=tracemovie_tif_dim(handles.donorFile,...
            handles.rinnercircle,handles.routercircle,1,rightPeaks,...
            handles.right_dim);
        handles.rtrace=rightTraces;
        %plot the first trace
        plotTrace(handles.axes4,rightTraces{1});
        
        %finally plot any right points currently selected
        if isfield(handles,'peakl_i')
            p=exp.lfilt(handles.peakl_i,:);
            highlightPeak('left',p,'go')
        end
        
    case 'both'
        leftPeaks=peaks1;
        nleftPeaks=size(leftPeaks,1);
        rightPeaks=peaks2;
        nrightPeaks=size(rightPeaks,1);
        
        for i=1:nleftPeaks
            highlightPeak('left',leftPeaks(1,:),'go');
        end
        %run trace(s)
        leftTraces=tracemovie_tif_dim(handles.donorFile,...
            handles.rinnercircle,handles.routercircle,1,leftPeaks,...
            handles.left_dim);
        handles.ltrace=leftTraces;
        %plot the first trace
        plotTrace(handles.axes1,leftTraces{1});
        
        for i=1:nrightPeaks
            highlightPeak('right',rightPeaks(1,:),'go');
        end
        %run trace(s)
        if handles.alexToggle
            rightAcceptorTraces=tracemovie_tif_dim(handles.acceptorFile,...
                handles.rinnercircle,handles.routercircle,1,rightPeaks,...
                handles.right_dim);
            handles.rAcceptortraces=rightAcceptorTraces;
            plotTrace(handles.axes7,rightAcceptorTraces{1});
        end
        rightTraces=tracemovie_tif_dim(handles.donorFile,...
            handles.rinnercircle,handles.routercircle,1,rightPeaks,...
            handles.right_dim);
        handles.rtrace=rightTraces;
        %plot the first trace
        plotTrace(handles.axes4,rightTraces{1});
        
        %plot FRET
        ltrace=squeeze(leftTraces{1});
        rtrace=squeeze(rightAcceptorTraces{1});
        lt=ltrace(2,:)-ltrace(3,:);
        rt=rtrace(2,:)-rtrace(3,:);
        %scale lt and rt to min and max
        lt_s=lt./max(lt);
        rt_s=rt./max(rt);
        axes(handles.axes5);
        len=length(ltrace);
        hold off
        plot(1:len,lt_s)
        axis([0 len 0 1]);
        hold on
        plot(1:len,rt_s)
        legend({'Cy3','Cy5'})
end
end
