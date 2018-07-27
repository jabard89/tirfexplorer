%%Export Traces
%Jared Bard
%July 27, 2018
%Function to export traces as a structure
% Struct
%     Time
%     Traces
%     PeakLocs
%     Filename
%     Params
%Traces are stored in a cell array (nMols x 1) in which each cell contains
%a [2 nFrames] array with Donor and Acceptor traces
function h = exportTraces(handles,whichTraces)
    fprintf(['Beginning export','\n']);
    if ~handles.allTracesCalculated
        handles=calcAllTraces(handles);
        handles.allTracesCalculated=1;
    end
    
    switch whichTraces
        case 'selected'
            if isfield(handles,'donorTrace') && isfield(handles,'fretTrace') && ...
                    isfield(handles,'acceptorTrace')
                temp=[squeeze(handles.donorTrace)';squeeze(handles.fretTrace)';...
                    squeeze(handles.acceptorTrace)'];
                exportName = inputdlg('Name the trace [donor;acceptor;sensor]');
                assignin('base',exportName{1},temp);

            elseif isfield(handles,'donorTrace') && isfield(handles,'fretTrace')
                temp=[squeeze(handles.donorTrace(:,1,:))';...
                    squeeze(handles.fretTrace(:,1,:))'];
                exportName = inputdlg('Name the trace [donor;acceptor]');
                assignin('base',exportName{1},temp);
            end
    
        case 'all'
            linkedDonorTraces=squeeze(handles.allDonorTraces(handles.exp.linki(:,1),1,:));
            linkedFretTraces=squeeze(handles.allFretTraces(handles.exp.linki(:,2),1,:));
            leftPeaks=handles.exp.linked_lpeaks(:,1:2,1);
            rightPeaks=handles.exp.linked_rpeaks(:,1:2,1);
            
            [nMols nFrames] = size(linkedDonorTraces);

            temp = cell(nMols,1);
            for i = 1:nMols
                temp{i} = [linkedDonorTraces(i,:);linkedFretTraces(i,:)];
            end
            %Make the paramter structure
            params.rinnercircle = handles.rinnercircle; %circle around peak for data collection
            params.routercircle = handles.routercircle; %donut around peak for background information
            params.left_dim = handles.left_dim; %based on alignment of tetraspeck
            params.right_dim = handles.right_dim;
            params.nImagesProcess = handles.nImagesProcess; %frames to analyze (0=all)
            params.alexToggle = handles.alexToggle; %use a seperate channel for acceptor
            params.driftToggle = handles.driftToggle; %track a peak to calculate drift
            
            %Make the traces structure
            traceExport.time = handles.time;
            traceExport.nMols = nMols;
            traceExport.nFrames = nFrames;
            traceExport.traces = temp;
            %Peaks are exported as [xdonor ydonor xacceptor yacceptor]
            traceExport.peakLocs = [leftPeaks rightPeaks];
            traceExport.fileName = handles.donorFile;
            traceExport.params = params;
            
            exportName=inputdlg('Name the Traces File');
            assignin('base',exportName{1},traceExport);

            if handles.alexToggle
                linkedAcceptorTraces=squeeze(handles.allAcceptorTraces...
                    (handles.exp.linki(:,2),1,:));
                temp2 = cell(nMols,1);
                for i = 1:nMols
                    temp2{i} = linkedAcceptorTraces(i,:);
                end
                acceptorName=inputdlg('Name the Acceptor Traces');
                assignin('base',acceptorname{1},linkedAcceptorTraces);
            end
    end
    h = handles;
    fprintf(['Traces exported to ' exportName{1} '.' '\n']);