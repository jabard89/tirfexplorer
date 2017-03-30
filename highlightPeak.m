function f1=highlightPeak(handles,channel,p,marker)
%function to highlight a peak on either the right or left
switch channel
    case 'left'
        axes(handles.donorImageAxes);
        hold on
        plot(p(1),p(2),marker);
        hold off
    case 'right'
        if handles.alexToggle
            axes(handles.fretImageAxes);
            hold on
            plot(p(1),p(2),marker);
            hold off
            axes(handles.acceptorImageAxes);
            hold on
            plot(p(1),p(2),marker);
            hold off
        else
            axes(handles.fretImageAxes);
            hold on
            plot(p(1),p(2),marker);
            hold off
        end
end
end