%%Loads the figure windows
%Jared Bard
%November 14, 2017

function h = loadFigureWindows(handles)
%Checks if figure windows are open or still valid before reopening them
if isfield(handles,'imageFigure') && isvalid(handles.imageFigure)
    axes(handles.donorImageAxes);
    cla;
    axes(handles.fretImageAxes);
    cla;
    axes(handles.acceptorImageAxes);
    cla;
else
    handles.imageFigure=figure();
    handles.donorImageAxes=subplot(1,3,1);
    title('Donor')
    handles.fretImageAxes=subplot(1,3,2);
    title('FRET')
    handles.acceptorImageAxes=subplot(1,3,3);
    title('Acceptor')
end

if isfield(handles,'traceFigure') && isvalid(handles.traceFigure)
    axes(handles.donorTraceAxes);
    cla;
    axes(handles.fretTraceAxes);
    cla;
    axes(handles.fretCalcAxes);
    cla;
    axes(handles.acceptorTraceAxes);
    cla;
else
    handles.traceFigure=figure();
    handles.donorTraceAxes=subplot(4,1,1);
    title('Donor Ch')
    handles.fretTraceAxes=subplot(4,1,2);
    title('FRET Ch')
    handles.acceptorTraceAxes=subplot(4,1,3);
    title('Acceptor Ch')
    handles.fretCalcAxes=subplot(4,1,4);
    title('Calc') 
end

h=handles;
