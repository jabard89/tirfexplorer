%Given a peak index highlight the proper peaks
%Jared Bard
%March 2, 2017
function [handles] = plotpoint(handles,which_channel,peak1,peak2)
exp=handles.exp;
%start by redrawing both channels
axes(handles.axes2);
hold off
imshow(exp.avgl,[])
hold on
plot(exp.lfilt(:,1),exp.lfilt(:,2),'yo')
plot(exp.linked_lpeaks(:,1),exp.linked_lpeaks(:,2),'ro')
hold off
axes(handles.axes3);
hold off
imshow(exp.avgr,[])
hold on
plot(exp.rfilt(:,1),exp.rfilt(:,2),'yo')
plot(exp.linked_rpeaks(:,1),exp.linked_rpeaks(:,2),'ro')
hold off
%highlight peak and related peak
    function f1=highlight_peaks(left_peaks,right_peaks)
    end
if strcmp(which_channel,'left')
    axes(handles.axes2)
    hold on
    plot(peak1(1),peak1(2),'go');
    hold off
    p_tform=tforminv(handles.tform,peak1(1:2));
    axes(handles.axes3)
    hold on
    plot(p_tform(1),p_tform(2),'bo');
    hold off
    %run trace
    trace1=tracemovie_tif_dim(handles.file,handles.rinnercircle,...
        handles.routercircle,1,peak1,handles.left_dim);
    trace1=squeeze(trace1{1});
    len=length(trace1);
    handles.ltrace=trace1;
    %plot trace
    axes(handles.axes1);
    % plot(1:len,smooth(trace1(2,:)))
    % hold on
    % plot(1:len,smooth(trace1(3,:)))
    % legend({'Peak','Background'})
    % hold off
    peak_int=trace1(2,:)-trace1(3,:);
    plot(1:len,peak_int)
elseif strcmp(which_channel,'right')
    %highlight point and related point
    axes(handles.axes3)
    hold on
    plot(peak1(1),peak1(2),'go');
    hold off
    p_tform=tforminv(handles.tform,peak1(1:2));
    axes(handles.axes2)
    hold on
    plot(p_tform(1),p_tform(2),'bo')
    hold off
    %run trace
    trace1=tracemovie_tif_dim(handles.file,handles.rinnercircle,...
        handles.routercircle,1,peak1,handles.right_dim);
    trace1=squeeze(trace1{1});
    len=length(trace1);
    handles.rtrace=trace1;
    %plot trace
    axes(handles.axes4);
    % plot(1:len,smooth(trace1(2,:)))
    % hold on
    % plot(1:len,smooth(trace1(3,:)))
    % legend({'Peak','Background'})
    % hold off
    peak_int=trace1(2,:)-trace1(3,:);
    plot(1:len,peak_int)
elseif strcmp(which_channel,'both')
    axes(handles.axes2)
    hold on
    plot(peak1(1),peak1(2),'go');
    hold off
    axes(handles.axes3)
    hold on
    plot(peak2(1),peak2(2),'go');
    hold off
    %run left trace
    ltrace=tracemovie_tif_dim(handles.file,handles.rinnercircle,...
        handles.routercircle,1,peak1,handles.left_dim);
    ltrace=squeeze(ltrace{1});
    len=length(ltrace);
    handles.ltrace=ltrace;
    %plot trace
    axes(handles.axes1);
    % plot(1:len,smooth(trace1(2,:)))
    % hold on
    % plot(1:len,smooth(trace1(3,:)))
    % legend({'Peak','Background'})
    % hold off
    peak_int=ltrace(2,:)-ltrace(3,:);
    plot(1:len,peak_int)
     %run right trace
    rtrace=tracemovie_tif_dim(handles.file,handles.rinnercircle,...
        handles.routercircle,1,peak1,handles.right_dim);
    rtrace=squeeze(rtrace{1});
    len=length(rtrace);
    handles.rtrace=rtrace;
    %plot trace
    axes(handles.axes4);
    % plot(1:len,smooth(trace1(2,:)))
    % hold on
    % plot(1:len,smooth(trace1(3,:)))
    % legend({'Peak','Background'})
    % hold off
    peak_int=rtrace(2,:)-rtrace(3,:);
    plot(1:len,peak_int)
    
    %plot FRET
    lt=smooth(ltrace(2,:)-ltrace(3,:));
    rt=smooth(rtrace(2,:)-rtrace(3,:));
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