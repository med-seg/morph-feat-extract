function  v = LaplaceMeshSmoothing(f,v,n,type,p1,p2,vfix)
% This is a mesh smoothing function using a number of algorithms related to
% Laplace operator, 
% v = LaplaceMeshSmoothing(f,v,n);
% f - a m-by-3 triangulation
% v - a n-by-3 vertices coordintes list
% n - number of iterations, default is 10
% returns a smoothed vertices coordintes list in v
%
% Other options:
% v = LaplaceMeshSmoothing(f,v,n,'LowPass',lambda,mu);
%   'LowPass' is default algorithm, where lambda is regularisation 
%   parameter [0,1] with default value 0.9; mu is the ratio of the 
%   reduction regularisation default is -1.02.
%
% v = LaplaceMeshSmoothing(f,v,n,'Laplace',lambda);
%   regularised Laplacian smoothing algorithm with regularisation 
%   parameter lambda [0,1] default value 0.9.
% 
% v = LaplaceMeshSmoothing(f,v,n,'LaplaceHC',alpha,beta);
%   Laplacian+HC smoothing algorithm with regularisation 
%   parameter alpha [0,1] and beta [0,1], for contributions from original 
%   and previous vertices, default values are 0 and 0.2, respectively. 
%
% v = LaplaceMeshSmoothing(f,v,n,'...',p1,p2,vfix);
%   list all the fixed vertices in vector vfix.

% All the parameters are described in the references
% Refs: Bade et al (2006) and Vollmer et al (1999)

% Yipeng Hu, CMIC, UCL, 2012 (yipeng.hu@ucl.ac.uk)

if  nargin<3 || isempty(n), n=10; end
if  nargin<4 || isempty(type), type='LowPass'; end
switch lower(type),
    case  {'laplace','laplacian'},
        if  nargin<5 || isempty(p1), p1=0.9; end
        type='la';
    case  {'hc','laplacehc','laplacianhc'},
        if  nargin<5 || isempty(p1), p1=0; end
        if  nargin<6 || isempty(p2), p2=0.2; end
        type='hc';
    case  {'low','lowpass'},
        if  nargin<5 || isempty(p1), p1=0.9; end
        if  nargin<6 || isempty(p2), p2=-1.02*p1; else  p2=p2*p1; end
        type='lo';
end
if  nargin<7 || isempty(vfix), vfix=[]; end

%% first find neighbours, nb - cell contains
vind = setdiff(unique(f(:)),vfix);  % vector valid variable vertices
vi = num2cell(vind);  % vertices cell
nb = cellfun(@(x) setdiff(unique(f(any(x==f,2),:)),x),vi,'UniformOutput',false);


%% start iterations
switch  type,    
    case  'la',  %% regularised Laplace operator
        for  nn = 1:n,
            v(vind,:) = cell2mat( cellfun(@(xvi,xnb)(1-p1)*v(xvi,:)+p1*mean(v(xnb,:)),vi,nb,'UniformOutput',false) );
        end
    
    case  'hc',  %% Laplace + HC algorithm
        vori=v; % original
        for  nn = 1:n,
            v0 = v;  % previous vertices
            v(vind,:) = cell2mat( cellfun(@(xnb)mean(v(xnb,:)),nb,'UniformOutput',false) );  % orignial laplace
            b = v-(p1*vori+(1-p1)*v0);
            v(vind,:) = v(vind,:) - cell2mat( cellfun(@(xvi,xnb)p2*b(xvi,:)+(1-p2)*mean(b(xnb,:)),vi,nb,'UniformOutput',false) );
        end
        
    case  'lo',
        for  nn = 1:n,
            % forward filtering
            v(vind,:) = cell2mat( cellfun(@(xvi,xnb)(1-p1)*v(xvi,:)+p1*mean(v(xnb,:)),vi,nb,'UniformOutput',false) );
            % backward filtering
            v(vind,:) = cell2mat( cellfun(@(xvi,xnb)(1-p2)*v(xvi,:)+p2*mean(v(xnb,:)),vi,nb,'UniformOutput',false) );
        end
end




