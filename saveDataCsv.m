function saveDataCsv(pathFinalOutput)

% open the folder containing the final data
files=dir(pathFinalOutput);
files(1:2) = [];

fid = fopen('results.csv', 'w');
fprintf(fid, 'volume, curvature, nameData\n');

for j=1:length(files)
    if(~files(j).isdir)
        %parse the name file in order to find the right one
        fileName = files(j).name;
        
        % load the data
        pathFile = [pathFinalOutput '/' fileName];
        load(pathFile);
        
        %write csv file
        fprintf(fid, '%f, %f, %s,\n', volume * 10^(-3), meanCurv, fileName);
    end
end
fclose(fid);
end
