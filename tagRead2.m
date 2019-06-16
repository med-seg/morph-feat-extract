function [header, volSize, interpVoxSize, tags] = tagRead2( tagfile )

%fileinfo = dir(tagfile);
fileinfo = dir(fullfile(tagfile)); 

if isequal(fileinfo,0) 
  return; 
else
    L = fileinfo.bytes;
end

%{
if isequal(filename,0) || isequal(pathname,0) 
  return; 
end 

s = dir(fullfile(pathname,filename)); 
groesse = s.bytes; 

%fid = fopen(fullfile(pathname,filename)); 
%}

 
% Read header information to string
fid = fopen(tagfile);
header = [];
C = textscan(fid,'%s\n','delimiter',sprintf('\f'));
for i = 1:length(C{1})-1
    header = sprintf('%s', header,C{1}{i});
    header = sprintf('%s\n', header);
end
header = sprintf('%s\f',header);

% Go to last header position for start of reading pixel tags
fseek(fid, length(header), 'bof');

% Read sizes of tags data
headerV = strrep(header, ':', ' ');

C = textscan(headerV, '%s %s');

nameV = C{1,1};
valueV = C{1,2};

xx = str2double(cell2mat(valueV(strcmp(nameV, 'x'))));
yy = str2double(cell2mat(valueV(strcmp(nameV, 'y'))));
zz = str2double(cell2mat(valueV(strcmp(nameV, 'z'))));

% Reading tags data
data = fread (fid, L - length(header), '*ubit8');
data = reshape(data,xx,yy,zz);
data = permute(data,[3 2 1]);
tags = permute(data,[2 3 1]);

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

%}

fclose(fid);

end

