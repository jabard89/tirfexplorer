function [ringIndex circleIndex] = calculateApertureIndex(frameSize, centre, innerCircleRadius, outerCircleRadius)
%   function [ringIndex circleIndex] = calculateApertureIndex(frameSize, centre, radius)
%
% calculate the points in index notation into the image frame which are inside the ring and
% the circle of given aperture size


if rem(innerCircleRadius , 1) ~= 0 
  error('the innerCircleRadius must be integer');
end

if rem(outerCircleRadius , 1) ~= 0 
  error('the outerCircleRadius must be integer');
end

x0 = centre(1);
y0 = centre(2);

% quantised circle - because we are using pixel coordinates
% the max makes sure the function only gives values greater than 1
circle = @(y,r, x0, y0) round( sqrt( r^2 - (y - y0).^2) + x0);

% boundaries of the outer and inner circle in x direction
xfinishO = circle( y0 - outerCircleRadius : y0 + outerCircleRadius, outerCircleRadius, x0, y0);
xstartO =  round(2*x0-xfinishO);
xfinishI = circle( y0 - innerCircleRadius : y0 + innerCircleRadius, innerCircleRadius, x0, y0);
xstartI =  round(2*x0-xfinishI);

% the (2*x0 - x) is just (x0-(x-x0)), ie the leftmost boundary of the circle
% (in case you were wondering)

ylim = frameSize(1);  % need to make sure we dont try to access out of 
xlim = frameSize(2);  % bounds values

% if j is out of bounds initialise it to an inbounds value
jstartO =  min( max( xstartO, 1) , xlim); 
jfinishO = min( max( xfinishO, 1), xlim);
jstartI =  min( max( xstartI, 1) , xlim); 
jfinishI = min( max( xfinishI, 1), xlim);

% sometimes jfinish is less than jstart due to rounding
% if this happens fix it
jfinishO(find(jfinishO<jstartO)) = jstartO(find(jfinishO<jstartO));
jfinishI(find(jfinishI<jstartI)) = jstartI(find(jfinishI<jstartI));

% boundaries in y direction
ystartO = round(y0)-outerCircleRadius; 
yfinishO = round(y0)+outerCircleRadius;
ystartI = round(y0)-innerCircleRadius; 
yfinishI = round(y0)+innerCircleRadius;

% if i is out of bounds initialise it to an inbounds value
istartO =  min( max( ystartO, 1), ylim); 
ifinishO = min( max( yfinishO, 1), ylim);
istartI =  min( max( ystartI, 1), ylim); 
ifinishI = min( max( yfinishI, 1), ylim);

% sometimes yfinish is less than ystart due to rounding
% if this happens fix it
ifinishO(find(ifinishO<istartO)) = istartO(find(ifinishO<istartO));
ifinishI(find(ifinishI<istartI)) = istartI(find(ifinishI<istartI));

% get the indexes of y-positions in the frame for the outer and inner circle
nO = 1;  
nI = 1;

% initialise the variables
maxSizeCircle = numel((round(y0)-outerCircleRadius : round(y0)+outerCircleRadius)) * numel(min(jstartO):max(jfinishO));
insideRing = zeros(maxSizeCircle , 2);
insideCircle = insideRing; 

%internal ring counter, m 
m = 0;
%internal circle counter, k
k = 0;

% loop over nO to create ring and circle
for i = istartO : ifinishO
  
  % left part of the ring
  if nO <= outerCircleRadius-innerCircleRadius
  
    RingPoints = numel(jstartO(nO):jfinishO(nO));
    
    if RingPoints > 0
      
      for s = 1 : RingPoints
      
      insideRing(m+s,1:2) =  [i, jstartO(nO)+s-1];
    
      end
      
      m = m + RingPoints;
      
    end
    
  end
  
  % middle part of the ring and the circle
  if nO > outerCircleRadius-innerCircleRadius
  if nO <= outerCircleRadius+innerCircleRadius+1
    
    leftRingPoints = numel(jstartO(nO):jstartI(nI));
    rightRingPoints = numel(jfinishI(nI):jfinishO(nO));
  
    if leftRingPoints + rightRingPoints > 0
      
      % create left part of the ring
      for s = 1 : leftRingPoints
      
        insideRing(m+s,1:2) =  [i, jstartO(nO)+s-1];
    
      end
      
      % create right part of the ring
      for s = 1 : rightRingPoints
    
	insideRing(m+leftRingPoints+s,1:2) =  [i, jfinishI(nI)+s-1];
  
      end
  
      m = m + leftRingPoints + rightRingPoints;
      
      % create circle inside the ring
      circlePoints = numel(jstartI(nI):jfinishI(nI))-2;
      
      if circlePoints > 0;
      
	for s = 1 : circlePoints
    
	  insideCircle(k+s,1:2) =  [i, jstartI(nI)+s];
  
	end
      
	k = k + circlePoints;
      
      end
    end
        
    %inner circle y-position index    
    nI = nI + 1;
  
  end
  end
  
  % right part of the ring
  if nO > outerCircleRadius + innerCircleRadius + 1
      
    RingPoints = numel(jstartO(nO):jfinishO(nO));
      
    if RingPoints > 0
          
      for s = 1 : RingPoints
          
        insideRing(m+s,1:2) =  [i, jstartO(nO)+s-1];
      
      end
          
      m = m + RingPoints;
          
    end
      
  end
  
  % outer circle y-position index
  nO = nO+1;

end

%convert the vectors from subscripts to indexes into frame
% 1: k-1 and m -1 because we dont want to try to index the zero padding values
ringIndex = sub2ind(frameSize, insideRing(1:m,1), insideRing(1:m,2));
circleIndex = sub2ind(frameSize, insideCircle(1:k,1), insideCircle(1:k,2));
% ringIndex=insideRing(1:m,:);
% circleIndex=insideCircle(1:k,:);
end