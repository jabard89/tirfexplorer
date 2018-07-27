%%Loads the figure windows
%Jared Bard
%November 14, 2017
%Edited on July 27, 2018 to change figure layout. Still needs to be fixed
%for ALEX
function h = loadFigureWindows(handles)
%Checks if figure windows are open or still valid before reopening them
%For each axes, make line objects for the different color spectrums (green,
%red, blue and yellow)
if isfield(handles,'imageFigure') && isvalid(handles.imageFigure)
    clf(handles.imageFigure,'reset');
else
    handles.imageFigure=figure();
end
set(0,'CurrentFigure',handles.imageFigure);

if handles.alexToggle
    handles.donorImageAxes=subplot(1,3,1);
    handles.fretImageAxes=subplot(1,3,2);
    handles.acceptorImageAxes=subplot(1,3,3);
else
    handles.donorImageAxes=subplot(1,2,1);
    handles.fretImageAxes=subplot(1,2,2);
end

axes(handles.donorImageAxes);
try
    plots.donorImage=imshow(handles.exp.avgl,[]);
catch ME
    errordlg('Please Reload the Image');
    rethrow(ME);
end
hold on;
plots.yDonorImage=plot(0,0,'yo');
set(plots.yDonorImage,'XData',[],'YData',[]);
plots.rDonorImage=plot(0,0,'ro');
set(plots.rDonorImage,'XData',[],'YData',[]);
plots.bDonorImage=plot(0,0,'bo');
set(plots.bDonorImage,'XData',[],'YData',[]);
plots.gDonorImage=plot(0,0,'go');
set(plots.gDonorImage,'XData',[],'YData',[]);
plots.donorRef=plot(0,0,'g+');
set(plots.donorRef,'XData',[],'YData',[]);
title('Donor')
hold off;
    
axes(handles.fretImageAxes);
try
    plots.fretImage=imshow(handles.exp.avgr,[]);
catch ME
    errordlg('Please Reload the Image');
    rethrow(ME);
end
hold on;
plots.yFretImage=plot(0,0,'yo');
set(plots.yFretImage,'XData',[],'YData',[]);
plots.rFretImage=plot(0,0,'ro');
set(plots.rFretImage,'XData',[],'YData',[]);
plots.bFretImage=plot(0,0,'bo');
set(plots.bFretImage,'XData',[],'YData',[]);
plots.gFretImage=plot(0,0,'go');
set(plots.gFretImage,'XData',[],'YData',[]);
plots.fretRef=plot(0,0,'g+');
set(plots.fretRef,'XData',[],'YData',[]);
title('FRET')
hold off;

if handles.alexToggle
    axes(handles.acceptorImageAxes);
    try
        plots.acceptorImage=imshow(handles.expAcceptor.avgr,[]);
    catch ME
        errordlg('Please Reload the Image');
        rethrow(ME);
    end
    hold on;
    plots.yAcceptorImage=plot(0,0,'yo');
    set(plots.yAcceptorImage,'XData',[],'YData',[]);
    plots.rAcceptorImage=plot(0,0,'ro');
    set(plots.rAcceptorImage,'XData',[],'YData',[]);
    plots.bAcceptorImage=plot(0,0,'bo');
    set(plots.bAcceptorImage,'XData',[],'YData',[]);
    plots.gAcceptorImage=plot(0,0,'go');
    set(plots.gAcceptorImage,'XData',[],'YData',[]);
    plots.acceptorRef=plot(0,0,'g+');
    set(plots.acceptorRef,'XData',[],'YData',[]);
    title('Acceptor')
    hold off;
end
    
if isfield(handles,'traceFigure') && isvalid(handles.traceFigure)
    clf(handles.traceFigure,'reset');
else
    handles.traceFigure=figure();
end
set(0,'CurrentFigure',handles.traceFigure);

if handles.alexToggle
    handles.donorTraceAxes=subplot(4,1,1);
    handles.fretTraceAxes=subplot(4,1,2);
    handles.acceptorTraceAxes=subplot(4,1,3);
    handles.fretCalcAxes=subplot(4,1,4);
else
    if handles.figureLayoutToggle
        handles.donorTraceAxes=subplot(5,1,1);
        handles.fretTraceAxes=subplot(5,1,2);
        handles.overlayTraceAxes=subplot(5,1,3);
        handles.totalTraceAxes=subplot(5,1,4);
        handles.fretCalcAxes=subplot(5,1,5);
    else
        handles.overlayTraceAxes=subplot(3,1,1);
        handles.totalTraceAxes=subplot(3,1,2);
        handles.fretCalcAxes=subplot(3,1,3);
    end
end

if handles.figureLayoutToggle
    axes(handles.donorTraceAxes);
    hold on;
    title('Donor');
    plots.donorTrace=plot(0,0,'r-');
    plots.donorBkgdTrace=plot(0,0,'k-');
    set(plots.donorTrace,'XData',[],'YData',[]);
    set(plots.donorBkgdTrace,'XData',[],'YData',[]);
    hold off;

    axes(handles.fretTraceAxes);
    hold on;
    title('Acceptor');
    plots.fretTrace=plot(0,0,'b-');
    plots.fretBkgdTrace=plot(0,0,'k-');
    set(plots.fretTrace,'XData',[],'YData',[]);
    set(plots.fretBkgdTrace,'XData',[],'YData',[]);
    hold off;
end

axes(handles.overlayTraceAxes);
hold on;
title('Overlay');
plots.donorOverlayTrace = plot(0,0,'r-');
plots.fretOverlayTrace = plot(0,0,'b-');
set(plots.donorOverlayTrace,'XData',[],'YData',[]);
set(plots.fretOverlayTrace,'XData',[],'YData',[]);
% legend('Donor','Acceptor','Location','northeast','Orientation','horizontal');
% legend('boxoff');
hold off;

axes(handles.totalTraceAxes);
hold on;
title('Total');
plots.totalTrace=plot(0,0,'k-');
set(plots.totalTrace,'XData',[],'YData',[]);
hold off;

axes(handles.fretCalcAxes);
hold on;
title('FRET Calc');
plots.fretCalcTrace=plot(0,0,'k-');
set(plots.fretCalcTrace,'XData',[],'YData',[]);
hold off;

if handles.alexToggle
    axes(handles.acceptorTraceAxes);
    hold on;
    title('Acceptor');
    plots.acceptorTrace=plot(0,0,'b-');
    set(plots.acceptorTrace,'XData',[],'YData',[]);
    hold off;
end

%%Finally, load the image and reference peaks
try
    exp=handles.exp;
    if handles.alexToggle
        expAcceptor=handles.expAcceptor;
    end

    %Draw Donor Peaks
    set(plots.yDonorImage,'XData',exp.lfilt(:,1),'YData',exp.lfilt(:,2));
    set(plots.rDonorImage,'XData',exp.linked_lpeaks(:,1),...
        'YData',exp.linked_lpeaks(:,2));

    %Draw FRET Peaks
    set(plots.yFretImage,'XData',exp.rfilt(:,1),'YData',exp.rfilt(:,2));
    set(plots.rFretImage,'XData',exp.linked_rpeaks(:,1),...
        'YData',exp.linked_rpeaks(:,2));

    %Draw Acceptor Peaks
    if handles.alexToggle
        set(plots.yAcceptorImage,'XData',exp.rfilt(:,1),'YData',exp.rfilt(:,2));
        set(plots.rAcceptorImage,'XData',exp.linked_rpeaks(:,1),...
            'YData',exp.linked_rpeaks(:,2));
    end
catch ME
    errordlg('Please reload the movie')
    rethrow(ME)
end

handles.plots=plots;
h=handles;
