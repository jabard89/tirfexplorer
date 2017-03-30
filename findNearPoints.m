function near=findNearPoints(refPeak,peakList,dist)
%Performs a sequential search looking for peaks in a certain neighborhood
pX=refPeak(1);
pY=refPeak(2);
pBox=[pX-dist pY-dist;pX+dist pY+dist];
%Find nearest peak using sequential search
near=peakList(find(peakList(:,1)>pBox(1,1)),:,:);
near=near(find(near(:,1)<pBox(2,1)),:,:);
near=near(find(near(:,2)>pBox(1,2)),:,:);
near=near(find(near(:,2)<pBox(2,2)),:,:);