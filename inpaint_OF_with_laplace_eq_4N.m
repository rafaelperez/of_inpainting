function u = inpaint_OF_with_laplace_eq_4N(v,g,f,lambda,d)

% input flow components
v1 = v(:,:,1); v1 = v1(:); % x component
v2 = v(:,:,2); v2 = v2(:); % y component
% guide image colour components
if ismatrix(g)
    g = repmat(g,[1 1 3]);
end
gr = g(:,:,1); gr = gr(:); % red channel
gg = g(:,:,2); gg = gg(:); % green channel
gb = g(:,:,3); gb = gb(:); % blue channel
% inainting mask
f = f/max(max(f)); % mask of ones and zeros
[h,w] = size(f); % width and height of inputs

% compute weighted Laplacian Lw
B = grid_incidence_4N(h,w); % incidence matrix of graph hxw
m = size(B,1); % number of edges
[X,Y] = meshgrid(1:w,1:h);
switch d
    case 0
        D = (1-lambda)*( (B*gr).*(B*gr) + (B*gg).*(B*gg) + (B*gb).*(B*gb) ) +...
    lambda*( (B*X(:)).*(B*X(:)) + (B*Y(:)).*(B*Y(:)) );
    case 1
        D = sqrt( (1-lambda)*( (B*gr).*(B*gr) + (B*gg).*(B*gg) + (B*gb).*(B*gb) ) +...
    lambda*( (B*X(:)).*(B*X(:)) + (B*Y(:)).*(B*Y(:)) ) );
    case 2
        D = (1-lambda)*sqrt( (B*gr).*(B*gr) + (B*gg).*(B*gg) + (B*gb).*(B*gb) ) +...
    lambda*sqrt( (B*X(:)).*(B*X(:)) + (B*Y(:)).*(B*Y(:)) );
    otherwise
        disp('distance identifier not valid');
end
% W = exp(-D); W1. we use the following weight since for this case the
% range very small.max(W1(:))/min(W1(:))=~4 and max(W2(:))/min(W2(:))=~10^6
W = 1./D; %W2
% max(W(:))/min(W(:))
W = spdiags(W,0,m,m); % weight matrix
Lw = -B'*(W*B); % weighted Laplacian operator

% sparse matrix containing the mask in the diagonal
f = f(:);
ff = spdiags(f==1,0,w*h,w*h);
A = speye(w*h) - ff + ff*Lw;
% condest(A)
% issymmetric(A)
b1 = (speye(w*h) - ff)*v1;
b2 = (speye(w*h) - ff)*v2;
x1 = A\b1;
x2 = A\b2;
u1 = reshape(x1,h,w);
u2 = reshape(x2,h,w);
u = cat(3,u1,u2);