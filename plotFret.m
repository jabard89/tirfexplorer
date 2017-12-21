function h=plotFret(handles,lTrace,rTrace,method)
%Function for plotting FRET from two traces
%method=0, plots channels relative to their maximum
%method=1, plots actual fret calculation
if nargin==3
    method=0; %default
end

if method==0
    lt=lTrace(2,:)-lTrace(3,:);
    rt=rTrace(2,:)-rTrace(3,:);
    %scale lt and rt to min and max
    lt_s=lt./max(lt_s);
    rt_s=rt./max(rt_s);
    len=length(lTrace);
    set(handles.plots.rFretCalcTrace,'XData',1:len,'YData',lt_s);
    set(handles.fretCalcAxes,'XLim',[1 len]);
    set(handles.fretCalcAxes,'YLim',[0 1]);
    set(handles.plots.bFretCalcTrace,'XData',1:len,'YData',rt_s);
end