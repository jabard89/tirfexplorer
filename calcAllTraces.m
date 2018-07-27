function handles=calcAllTraces(handles)
%%Function to calculate the traces for all peaks in a movie
%Jared Bard
%December 20, 2017
%Takes handles from the gui as input

%First initialize trace array
fprintf(['\n' 'Calculating' '\n']);
donorPeaks=handles.exp.lfilt;
fretPeaks=handles.exp.rfilt; %fretPeaks are same as acceptorPeaks

%First calculate traces for donor movie
allDonorTraces=tracemovie(handles.donorFile,handles.rinnercircle,...
    handles.routercircle,handles.nImagesAvg,...
    2,donorPeaks,handles.left_dim,fretPeaks,handles.right_dim);
handles.allDonorTraces=allDonorTraces{1};
handles.allFretTraces=allDonorTraces{2};
%Then calculate acceptor peaks if necessary
if handles.alexToggle
    allAcceptorTraces=tracemovie(handles.acceptorFile,handles.rinnercircle,...
        handles.routercircle,handles.nImagesAvg,...
        1,fretPeaks,handles.right_dim);
    handles.allAcceptorTraces=allAcceptorTraces{1};
end