function ReconstructionScript(inputFile, outputFolder)

% INPUT:this function take as input a txt file where are listed the
% directories containing segmented data
% 
% OUTPUT: it will save for each case in a .mat structure :
%         - the 3D mesh (vertices and faces)
%         - the volume
%         - the 3D curvature
% All the .mat files will be saved in the output folder

% open the file with the directory paths
fidIN = fopen(inputFile);

pth = fgetl(fidIN);

while ischar(pth)
    
    %find the folder name
%      if exist(pth, 'file') ==2
%      stringSplit = strsplit(pth,'/');
%      fileName= char(stringSplit(length(stringSplit))); 
%     if exist(pth, 'file') == 0
% 	continue
%    	disp('here')
%     end
    D = dir(pth);
    D(1:2)=[];

    % for each case
    for ii=1:length(D)
        pathFile = [pth '\' D(ii).name];
      	% pathFile = [pth];
        load(pathFile);

        % creat binary volume
        mask = zeros(volSize(2), volSize(1), volSize(3));
        for i=1:volSize(3)
            mask(:,:,i)=squeeze(data(i,:,:));
        end

        % estimate the volume
        volume=nnz(mask)*prod(interpVoxSize);

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
        dataInterp = interp3(coordX,coordY,coordZ,mask,xi,yi,zi, ...
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
        %compute 3D curvature
        x = fv.vertices(:,1);
        y = fv.vertices(:,2);
        z = fv.vertices(:,3);
        curvData = tricurv_v01(fv.faces, fv.vertices);

        %find the normals and curvature
        [normals,curvature] = findPointNormals(fv.vertices,50,[0,0,0],true); 
        meanCurv = mean(curvature);

        %save data
        mkdir(outputFolder)
        [p,n,e]=fileparts(D(ii).name);
        %[p,n,e]=fileparts(fileName);
	filename = [outputFolder '/' n '_output'];
        save (filename, 'hdrFile', 'volume', 'meanCurv', 'vertices', 'faces') 


     end %close the main for loop
	%end

    pth = fgetl(fidIN); 
end %close the while
fclose(fidIN);
end
