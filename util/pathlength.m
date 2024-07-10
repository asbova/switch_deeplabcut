function pl = pathlength(X)
%
% Function to calculate the Euclidean distance along a path described by the points in the rows of X
%
% INPUTS
%   X:          m x n array where each row represents a point in n-space
%
% OUTPUTS
%   pl:         path length along the points defined in X

if ~ismatrix(X)
    error('X must be a 2-dimensional array')
end

ptDiff = diff(X);

ss = sqrt(sum(ptDiff.^2,2));

pl = sum(ss);