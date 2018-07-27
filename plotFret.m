function h=plotFret(handles,lTrace,rTrace)
    %Calculate total signal for donor and acceptor
    lt = lTrace(2,:).*lTrace(4,:)-lTrace(3,:).*lTrace(4,:);
    rt = rTrace(2,:).*rTrace(4,:)-rTrace(3,:).*rTrace(4,:);
    
    total = lt + rt;
    
    if min(total) < 0
        totalMin = min(total);
    else
        totalMin = 0;
    end
    
    fret = rt./(lt+rt);
    
    len=length(lTrace);
    
    set(handles.plots.fretCalcTrace,'XData',1:len,'YData',fret);
    set(handles.fretCalcAxes,'XLim',[1 len],'YLim',[0 1]);
    
    set(handles.plots.totalTrace,'XData',1:len,'YData',total);
    set(handles.totalTraceAxes,'XLim',[1 len],'YLim',[totalMin 1.2.*max(total)]);
end