function [ltrace rtrace]=subtractbkgd(trace)
%%Calculates the background substracted traces and fret values of traces
%Jared Bard August 20, 2014
%the input trace is a cell containing two traces, where each trace contains
%an array with 5 columns for each time and peak with the following values
%[total_intensity circle_avg ring_avg circle_size ring_size]
%from each trace, the ring_avg*the circle_size is used as background and
%FRET is calculated as Ia/(Id+Ia)
ltrace=squeeze(trace{1}(:,1,:)-trace{1}(:,3,:).*trace{1}(:,4,:));
rtrace=squeeze(trace{2}(:,1,:)-trace{2}(:,3,:).*trace{2}(:,4,:));