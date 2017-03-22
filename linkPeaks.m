%link channels
%transform peaks from one hcanel into the other, run through the channels
%and find peaks that are lined
function [peak_names peak_index, lpeaks1, lpeaks2]=linkPeaks(tform,peaks1,...
    peaks2,distance)
%%link peaks of two channels
%Jared Bard
%August 22, 2016
n1=length(peaks1);
n2=length(peaks2);
p1=peaks1(:,1:2);
p2=peaks2(:,1:2);
p2_tform=tforminv(tform,p2);
peak_index=[];
lpeaks1=[];
lpeaks2=[];
for i=1:n1
    for j=1:n2
        if pdist([p1(i,:);p2_tform(j,:)]) < distance
            peak_index=[peak_index;i j];
            lpeaks1=[lpeaks1;peaks1(i,:)];
            lpeaks2=[lpeaks2;peaks2(j,:)];
        end
    end
end
n_peaks=size(peak_index,1);
peak_names=cell(n_peaks,1);
for k=1:n_peaks
    peak_names{k}=strcat('P',num2str(k));
end