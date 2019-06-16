%addpath('to-NIFTI_20130306-folder');

tic

resultsFolder = 'path-to-folder-that-stores-results';

%eFilename = [resultsFolder 'pancreas_volume_curvature.xlsx']

%{
%write *.xlsx file headings
A = {'Filename'};
B = {'Volume'};
C = {'Curvature'};
xlswrite(eFilename,A,1,'A1');
xlswrite(eFilename,B,1,'B1');
xlswrite(eFilename,C,1,'C1');
%}

inputFolder = 'path-to-folder-that-contains-input-files-of-organ-segmentations-or-annotations';

% Organise .img files (image data files) into two structures: 
% one has .tag files (i.e. binary organ annotations) 
% and the other has no .tag files.
[Tagged, notTagged] = listPaths_revised (inputFolder);
totalData = Tagged;

for i = 1:length(totalData)
%for i = 1:1
filename = [totalData(i).path totalData(i).name '.tag']
[header, volSize, interpVoxSize, tags] = tagRead2(filename);

%sprintf('%d', volSize)
%sprintf('%d', interpVoxSize)
%sprintf('%s', filename)
    
format short g
%estimate the volume (default metric is mm^3)
volume = nnz(tags)*prod(interpVoxSize);   
%sprintf('%f', volume);
  
% find the interpolation coordinates
interpCoordX = (0:volSize(1)-1).*interpVoxSize(1); 
interpCoordY = (0:volSize(2)-1).*interpVoxSize(2); 
interpCoordZ = (0:volSize(3)-1).*interpVoxSize(3); 

% image coordinates
coordX = (0.5:volSize(1)-0.5).*interpVoxSize(1);
coordY = (0.5:volSize(2)-0.5).*interpVoxSize(2);
coordZ = (0.5:volSize(3)-0.5).*interpVoxSize(3);

% resize volume
[xi,yi,zi] = meshgrid(interpCoordX,interpCoordY,interpCoordZ);
dataInterp = interp3(coordX,coordY,coordZ,im2double(tags),xi,yi,zi, ...
['*','linear'],0);

% volumetric smooth
sigma = 1;
pixsz = [1,1,1];
dataFilt = GaussianDerivative3D(dataInterp,sigma,0,pixsz);

% compute isosurface
IsoValue = getIsovalue(dataFilt,volume./prod(interpVoxSize));
fv = isosurface(interpCoordX,interpCoordY,interpCoordZ,dataFilt,IsoValue);

% mesh smoothing
n = 10;
type = 'lowpass';
p1 = [];
p2 = [];
vfix = [];
vertices = LaplaceMeshSmoothing(fv.faces,fv.vertices,n,type,p1,p2,vfix);
faces = fv.faces;
fv.vertices = vertices;

% plot the 3D reconstruction of pancreas
f1 = figure;
p = patch(fv);
isonormals(interpCoordX,interpCoordY,interpCoordZ,dataFilt,p);
grid on;
ax = gca;
ax.GridColor = 'white';
p.FaceColor = 'red';
p.EdgeColor = 'none';

daspect([1,1,1]);
axis tight
camlight 
lighting gouraud
hold off

set(gca,'fontname','Times New Roman');
headline = totalData(i).name;
newHeadline = strrep(headline, '_','\_');
title(newHeadline);
testFile = [totalData(i).path totalData(i).name '_pic.png']
%saveas(gcf,testFile,'fig');
saveas(f1,testFile,'png');
close(f1);

%compute 3D curvature
x = fv.vertices(:,1);
y = fv.vertices(:,2);
z = fv.vertices(:,3);
curvData = tricurv_v01(fv.faces, fv.vertices);

%find the normals and curvature
[normals,curvature] = findPointNormals(fv.vertices,50,[0,0,0],true); 
meanCurv = mean(curvature);
%}

%save results to a MAT file
resultFile = [totalData(i).path totalData(i).name '.mat']
save(resultFile,'-v7.3','tags');
save(resultFile,'volume','-append');
save(resultFile,'dataInterp','-append');
save(resultFile,'dataFilt','-append');
save(resultFile,'curvData','-append');
save(resultFile,'meanCurv','-append');
%}

%{
%binarise the dataInterp volume (original is double type) 
dataFiltBin = logical(zeros(size(dataInterp)));
for thisSlice = 1:size(dataInterp,3)
test = dataInterp(:,:,thisSlice);
test = imbinarize(test, 'adaptive');
dataFiltBin(:,:,thisSlice) = test;
end
%}

%write dataFiltBin (binarised volume dataInterp) to *.nii file
%niftyFile = [totalData(i).path totalData(i).name];
%niftiwrite(im2double(dataFiltBin),niftyFile);

%{
% write volume and curvature information to the *.xlxs file
range = 'A';
subFolderName =  {totalData(i).name};
s = strcat(range,num2str(i+1));
xlswrite(eFilename,subFolderName,1,s);

range = 'B';
volumeText =  {num2str(volume)};
s = strcat(range,num2str(i+1));
xlswrite(eFilename,volumeText,1,s);

range = 'C';
curvText = {num2str(meanCurv)};
s = strcat(range,num2str(i+1));
xlswrite(eFilename,curvText,1,s);
%}

end
 
toc

t = (toc/60)