function DI = GaussianDerivative3D(I,sigma,order,voxsz)
%  Compute the Gaussian derivative of an image using fft

if  length(sigma)==1, sigma=[sigma,sigma,sigma]; end
if  length(order)==1, order=[order,order,order]; end
if  nargin<4, voxsz=1; end
if  length(voxsz)==1, voxsz=[voxsz,voxsz,voxsz]; end

sigma = sigma(:)./voxsz(:);
dims = size(I);

% compute kernel
[Wx,Wy,Wz] = meshgrid( (2*pi/dims(2))*((0:dims(2)-1)-dims(2)/2), ...
    (2*pi/dims(1))*((0:dims(1)-1)-dims(1)/2), (2*pi/dims(3))*((0:dims(3)-1)-dims(3)/2));
FG = exp( -0.5*sigma(1)^2*Wx.^2 + -0.5*sigma(2)^2*Wy.^2 + -0.5*sigma(3)^2*Wz.^2 );

%rearranges a Fourier transform input by shifting the zero-frequency component to the center of the array.
K = fftshift( (complex(0,Wx).^order(1)).*(complex(0,Wy).^order(2)).*(complex(0,Wz).^order(3)).*FG );

% fft
%returns the real part of the n-dimensional inverse discrete Fourier transform of input, 
%computed with a multidimensional fast Fourier transform (FFT) algorithm
DI = real(ifftn(K.*fftn(double(I)),'nonsymmetric'));


