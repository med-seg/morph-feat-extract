function  isovalue = getIsovalue(bw,vol,numSample,numIter)


% checks for [0,1] range can be relaxed as the smoothed volume may exceed
% this range without the efficacy of the isovalue computed 

if  nargin<3, numSample=10; end
if  nargin<4, numIter=5; end


isovalue_lower = 0;
isovalue_upper = 1;
volume_samples = zeros(numSample,1);
for  i = 1:numIter,
    
    % sample all the volumes
    isovalues_samples = isovalue_lower:(isovalue_upper-isovalue_lower)/(numSample-1):isovalue_upper;
    for  j = 1:numSample,  % avoid using the vectorisation for memory
        volume_samples(j) = nnz(bw>=isovalues_samples(j));
    end
    
    % update the bounds
    i_upper = find(volume_samples<vol,1,'first');
    if(isempty(i_upper))
        isovalue_lower = 0;
        isovalue_upper = 0;
        break;
    else
        isovalue_upper = isovalues_samples(i_upper);
        isovalue_lower = isovalues_samples(i_upper-1);
    end
    
end

% find the zero crossing by linear interpolation
volume_lower = volume_samples(i_upper-1);
volume_upper = volume_samples(i_upper);
isovalue = isovalue_lower + (isovalue_upper-isovalue_lower) * (volume_lower-vol)/(volume_lower-volume_upper);