function [Z, delt,RelDiff] = SCASC_IR(X,Y,Sx,opt)
%Sparse constrained adaptive structure consistency based image regression
% X----> Y
Niter = opt.Niter;
lamda = opt.lamda;
mu = 0.4;
[M,N] = size(Y);
delt = zeros(M,N);% initialization
W = zeros(M,N);% initialization
Tx = 4 * LaplacianMatrix(Sx);% 4*Lx
inv_TmuI = inv(Tx + mu * eye(N));% (4*Lx+u*I)^-1
for i=1:Niter
    delt_old = delt;
    Z = (mu * (Y + delt) - W) * inv_TmuI; % Z update
    Q = Z - Y + W/mu;
    delt = deltUpdate(Q,lamda/mu,21);% delt update£» 1---> L1 norm; 21---> L21 norm
    W = W + mu * (Z - Y - delt); % W update
    RelDiff(i) = norm(delt - delt_old,'fro')/norm(delt,'fro');
    if i > 3 && RelDiff(i) < 1e-2
        break
    end
end
%figure;plot(log(RelDiff)); %log-relative-difference