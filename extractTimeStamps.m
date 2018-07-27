function times = extractTimeStamps(filename)
if nargin<1
    [file path]=uigetfile('.tif');
    fileInfo=imfinfo([path file]);
else
    fileInfo=imfinfo(filename);
end

[num_frames a] = size(fileInfo);
times = [];

% Only for first frame
frameInfo = fileInfo(1).UnknownTags(3).Value; % Extract char array
str = frameInfo(2:end-1); % Convert to string
temp = strsplit(str,',');
% temp2 = strsplit(temp{77},':'); % If you know row number index here e.g. 77 
% Othewise use this nonsense...
IndexA = strfind(temp, 'ElapsedTime-ms');
Index1 = find(not(cellfun('isempty', IndexA)));
IndexB = strfind(temp, 'Andor');
Index2 = find(not(cellfun('isempty', IndexB)));
Index_ts = setdiff(Index1,Index2);
temp2 = strsplit(temp{Index_ts},':');

times = [times; str2num(temp2{2})];
 
% For all subsequent frames
for n = 2:num_frames
	frameInfo = fileInfo(n).UnknownTags.Value; % Extract char array
	str = frameInfo(2:end-1); % Convert to string
	temp = strsplit(str,',');
	% temp2 = strsplit(temp{77},':');
	IndexA = strfind(temp, 'ElapsedTime-ms');
	Index1 = find(not(cellfun('isempty', IndexA)));
	IndexB = strfind(temp, 'Andor');
	Index2 = find(not(cellfun('isempty', IndexB)));
	Index_ts = setdiff(Index1,Index2);
	temp2 = strsplit(temp{Index_ts},':');

	times = [times; str2num(temp2{2})];
end