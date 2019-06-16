function ParserTagScript(inputFile, outputFolder)

% INPUT: this function take as input a txt file where are listed the
% directories containing patient data
% 
% OUTPUT: it will save the segmented data in binary volume in a .mat file
% in outputFolder directory  

% open the file with the directory paths
fidIN = fopen(inputFile);

pth = fgetl(fidIN);

while ischar(pth)
    
    %find the folder name
    stringSplit = strsplit(pth,'/');
    foldername= char(stringSplit(length(stringSplit))); 
    
    % iterate through the folders
    allDir = dir(foldername);
    allDir (1:2) = [];
    
    for i=1:length(allDir)
    
    % check if the segmentation is found
    found = 0;
    %find the tag files for Pancreas
    dirName = allDir(i).name;
    
    pathFolder = [foldername '\' dirName];
    if (isdir(pathFolder))
        files=dir(pathFolder);
        files(1:2) = [];
        
        for j=1:length(files)
            if(~files(j).isdir)
                 %parse the name file in order to find the right one
                 fileName = files(j).name;
                 [p,n,e]=fileparts(fileName);
                % tagFound = strfind(fileName, 'PANCVol');
                 if ((strcmp(e,'.tag')))
                     % .tag file found
                     found = 1;
                     pathFile = [pathFolder '\' fileName];
                     
                     % parse the current file
                     fid = fopen(pathFile);
                     header = [];
                     
                    endFound = 0;
                    while (~endFound)
                        var = fread(fid, 1, '*char');
                        if (double(var) == 12) % 0x0C = 12 in decimal
                            endFound = 1;
                        end
                        header = [header var];
                    end
                    % write the header
                    headerV = strrep(header, ':', ' ');
                    [nameV, valueV] = strread(headerV, '%s %s');
                    
                    xx=str2double(cell2mat(valueV(strcmp(nameV, 'x'))));
                    yy=str2double(cell2mat(valueV(strcmp(nameV, 'y'))));
                    zz=str2double(cell2mat(valueV(strcmp(nameV, 'z'))));
                    
                    % write the binary file
                    data=zeros(zz,yy,xx);
                 
                    for k=1:zz
                        for j=1:yy
                            for i=1:xx
                                data(k,j,i) = fread (fid, 1, '*ubit8');
                            end
                        end
                    end
                    %data(data==3) = 0;
                    
                     maxV = max(data(:));
                     minV = min(data(:));
                    
                    % count how many segmentation data
                    count = 0;
                    dataTemp = data;
                    if maxV == 0
                        continue;
                    end
                    while(maxV ~= 0)
                            count = count + 1;
                            dataTemp(dataTemp==maxV) = 0;
                            maxV = max(dataTemp(:));
                    end
                    
                    if (count > 2)
                        ['Case ' foldername ': More the one organ have been segmented']
                        continue;
                    end
                    
                    fclose(fid);
                    mkdir(outputFolder)             
                    filename = [outputFolder '\' dirName];
                    
                    % save the folowwing data for the next script:
                    % data (binary volume)
                    % .hdr file to extracat data from MRI
                    hdrFile = [pathFolder '\' n '.hdr'];
                    % volume size and voxel size
                    sizeHeader = size(nameV);
                    volSize = zeros(1,3);
                    interpVoxSize = zeros(1,3);
                    
                    for ii=1:sizeHeader(1)
                        %volume size
                        if (strcmp(nameV(ii), 'x'))
                            volSize(1) = cellfun(@(x)str2double(x), valueV(ii));
                        end
                        if (strcmp(nameV(ii), 'y'))
                            volSize(2) = cellfun(@(x)str2double(x),valueV(ii));
                        end
                        if (strcmp(nameV(ii), 'z'))
                            volSize(3) = cellfun(@(x)str2double(x),valueV(ii));
                        end
                        %voxel size
                        if (strcmp(nameV(ii), 'inc_x'))
                            interpVoxSize(1) = cellfun(@(x)str2double(x),valueV(ii));
                        end
                        if (strcmp(nameV(ii), 'inc_y'))
                            interpVoxSize(2) = cellfun(@(x)str2double(x), valueV(ii));
                        end
                        if (strcmp(nameV(ii), 'epais'))
                            interpVoxSize(3) = cellfun(@(x)str2double(x),valueV(ii));
                        end
                    end
                    
                    save (filename, 'hdrFile', 'data', 'nameV', 'valueV', 'volSize', 'interpVoxSize');
                           
                 end
            end
        end
    end
    end
        if (found == 0)
             ['Case ' foldername ': No manual segmentation']
        end
    
    pth = fgetl(fidIN); 
end
    fclose(fidIN);
end


    
