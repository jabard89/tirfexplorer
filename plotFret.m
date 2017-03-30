function h=plotFret(ax,lTrace,rTrace,method)
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
    lt_s=lt./max(lt);
    rt_s=rt./max(rt);
    axes(ax);
    len=length(lTrace);
    hold off
    plot(1:len,lt_s)
    axis([0 len 0 1]);
    hold on
    plot(1:len,rt_s)
    legend({'Cy3','Cy5'})
end