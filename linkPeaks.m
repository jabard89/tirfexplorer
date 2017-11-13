%link channels
%transform peaks from one hcanel into the other, run through the channels
%and find peaks that are lined
function [peak_names peak_index, lpeaks1, lpeaks2]=linkPeaks(tform,peaks1,...
    peaks2,distance)
%%link peaks of two channels
%Jared Bard
%August 22, 2016
n1=size(peaks1,1);
n2=size(peaks2,1);
nImageProcess=size(peaks1,3);
p1=peaks1(:,1:2);
p2=peaks2(:,1:2);
p2_tform=tforminv(tform,p2);
peak_index=zeros(n1,2);
lpeaks1=zeros(n1,4,nImageProcess);
lpeaks2=zeros(n1,4,nImageProcess);
for i=1:n1
    linkedPeak=findNearPoints(p1(i,:),p2_tform,distance);
    if linkedPeak
        p2Index=find(p2_tform(:,1)==linkedPeak(1));
        peak_index(i,:)=[i p2Index];
        lpeaks1(i,:,:)=peaks1(i,:,:);
        lpeaks2(i,:,:)=peaks2(p2Index,:,:);
    end
end
%clean up empty rows
peak_index=peak_index(any(peak_index,2),:);
lpeaks1=lpeaks1(any(lpeaks1(:,:,1),2),:,:);
lpeaks2=lpeaks2(any(lpeaks2(:,:,1),2),:,:);
n_peaks=size(peak_index,1);
peak_names=cell(n_peaks,1);
for k=1:n_peaks
    peak_names{k}=strcat('P',num2str(k));
end