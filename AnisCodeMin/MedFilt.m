%MEDFILT  One dimensional median filter.
%   Y = MEDFILT(X,N) returns the output of the order N, one dimensional
%   median filtering of vector X.  Y is the same length as X; for the edge
%   points, zeros are assumed to the left and right of X.
%   **SCK--Instead of zero padding, terminal values of X are extended
%   **to the left & right
%
%   For N odd, Y(k) is the median of X( k-(N-1)/2 : k+(N-1)/2 ).
%   For N even, Y(k) is the median of X( k-N/2 : k+N/2-1 ).
%
%   If you do not specify N, MEDFILT uses a default of N = 3.
%
%   From MatLab Signals Library
%   Modified & annotated by SCK 991102 -- Use fmedfilt() mex is faster
function y = medfilt(x,n,blksz)

if nargin < 2
   n = 3;
end

if n==1, y=x; return; end

if all(size(x) > 1)  %recursion to handle arrays
    nx = size(x,1);
    if nargin < 3
        blksz = nx;    % default: one big block (block size = length(x))
    end
    y = zeros(size(x));
    for i = 1:size(x,2)
        y(:,i) = medfilt(x(:,i),n,blksz);
    end
    return
end

nx = length(x);
if nargin < 3
    blksz = nx;    % default: one big block (block size = length(x))
end
if rem(n,2)~=1    % n even
    m = n/2;
else
    m = (n-1)/2;
end

%X = [zeros(1,m) x(:)' zeros(1,m)]; %original code
%pad with terminal values, SCK
X = [(ones(1,m)*x(1)) x(:)' (ones(1,m)*x(nx))];
y = zeros(1,nx);
% Work in chunks to save memory
indr = (0:n-1)';
indc = 1:nx;
for i=1:blksz:nx
    ind = indc(ones(1,n),i:min(i+blksz-1,nx)) + ... %clever overlapping indexing, n-by-nx
          indr(:,ones(1,min(i+blksz-1,nx)-i+1));
    xx = reshape(X(ind),n,min(i+blksz-1,nx)-i+1); %make sure xx is n-by-nx
    y(i:min(i+blksz-1,nx)) = median(xx);
end

% transpose if necessary
if size(x,2) == 1  % if x is a column vector ...
    y = y.';
end

