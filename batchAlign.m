allFolders=dir;
fileList=cell(length(allFolders),3);
for i = 3:length(allFolders) %Skip the first to results which seem to be the folder and the previous folder
    if allFolders(i).isdir
        subFolder = allFolders(i).name;
        tempFile = dir(fullfile(subFolder,'*.tif'));
        if size(tempFile,1) == 1
            fileList(i,:) = {pwd subFolder tempFile.name};
        end
    end
end
fileList = fileList(~cellfun(@isempty,fileList(:,1)),:);

nFiles = size(fileList,1);
inputFiles = cell(nFiles,1);
outputFiles = cell(nFiles,1);
%Generate the names
for i = 1:nFiles
    inputFiles{i}=fullfile(fileList{i,1},fileList{i,2},fileList{i,3});
    outputFiles{i} = fullfile(fileList{i,1},fileList{i,2},['Aligned_' fileList{i,3}]);
end

%Excecute alignMovie5
parfor i = 1:nFiles
    alignMovie5(inputFiles{i},outputFiles{i});
end