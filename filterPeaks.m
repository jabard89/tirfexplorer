function [peaksout]=filterPeaks(image,peaks,distance,e_thresh)
%%Filter Peaks by Distance
%Jared Bard August 13, 2014
%Goes through a list of peaks and removes any where there is another pixel
%of similar intensity within a given distance, or if the pixel is too close
%to the edge of the image
%%Initialize parameters
npeaks=size(peaks,1);
x_lim=size(image,2);
y_lim=size(image,1);
peaksout=peaks;
%%filter by eccentricity
%hold in a loop until an acceptable threshold is reached
e_thresh_good=0;
if nargin<4
    fig1=figure;
    fig2=figure;
    while ~e_thresh_good
        figure(fig1)
        hist(peaks(:,4),max(peaks(:,4))*10) %eccentricity hist
        e_thresh=input('Enter eccentricity threshold: ');

        %show which peaks would be removed
        figure(fig2)
        imshow(image,[min(image(:)) max(image(:))]);
        hold on;
        plot(peaks(:,1),peaks(:,2),'ro');
        filt_temp=peaks(peaks(:,4)>e_thresh,1:2);
        plot(filt_temp(:,1),filt_temp(:,2),'b+');
        hold off;
        e_thresh_good=input('1 if thresh is good, 0 if not: ');
    end
    close(fig1)
    close(fig2)
end

peaksout(peaks(:,4)>e_thresh,:)=0;
%Now remove peaks too close to the edge
peaksout(peaks(:,1)<=distance,:)=0;
peaksout((x_lim-peaks(:,1))<=distance,:)=0;
peaksout(peaks(:,2)<=distance,:)=0;
peaksout((y_lim-peaks(:,2))<=distance,:)=0;

%Finally remove peaks that are too close to each other
%use pdist to create a list of distances
%distances for two points are at i,j in the matrix
dist_m=squareform(pdist(peaks(:,1:2)));
%set the i,i peaks to a large value
dist_m(dist_m==0)=1e4; %only the i,i peaks should have a distance exactly 0
[X Y]=find(dist_m<=distance);
peaksout(X,:)=0;
%write the non-zero lines
peaksout=peaksout(any(peaksout,2),:);
end
        