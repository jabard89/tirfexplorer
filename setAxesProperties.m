function h=setAxesProperties(handles)
%Function to add titles to all axes and change other desired properties
%after each replotting function
axes(handles.donorImageAxes)
title('Donor')
hold off
axes(handles.fretImageAxes)
title('FRET')
hold off
if handles.alexToggle
    axes(handles.acceptorImageAxes);
    title('Acceptor');
    hold off
end
    
axes(handles.donorTraceAxes)
title('Donor Ch')
hold off
axes(handles.fretTraceAxes)
title('FRET Ch')
hold off
if handles.alexToggle
    axes(handles.acceptorTraceAxes)
    title('Acceptor Ch')
    hold off
end

axes(handles.fretCalcAxes)
title('Calc')
hold off

%set focus back to GUI
figure(handles.figure1)
h = handles;