function [peakFound peakIndex]=pickPoint(ax1,channelDim,peakList)
%Uses a mouse input to pick a peak from a plot
peakFound=zeros(1,4,1);
peakIndex=0;
tolerance=3;
[x_p y_p]=getpts(ax1);
win_dim=[channelDim(2)-channelDim(1) channelDim(4)-channelDim(3)];
%make sure correct point is selected
if size(x_p,1) > 1
    error('Pick Only One Point')
    return
elseif x_p > win_dim(1) || y_p > win_dim(2)
    error('Pick a Point in the Correct Channel')
    return
end
peakFound=findNearPoints([x_p y_p],peakList,tolerance);
if size(peakFound,1) > 1
    error('Too many points')
    return
elseif size(peakFound,1) < 1
    error('No point selected')
    return
end
[found peakIndex]=ismember(peakFound(:,:,1),peakList(:,:,1),'rows');
