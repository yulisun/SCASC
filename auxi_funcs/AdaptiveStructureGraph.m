function [S] = AdaptiveStructureGraph (X,K)
if nargin == 1
    K = round(sqrt(size(X,2)));
end
if nargin <= 2
    X = X';
    N = size(X,1);
    S = zeros(N,N);
    K = K+1;
    [idx,value] = knnsearch(X,X,'k',K);
    degree = tabulate(idx(:));
    Kmat = degree(:,2);
    kmax = K;
    kmin = round(kmax/10)+1;
    Kmat(Kmat>=kmax)=kmax;
    Kmat(Kmat<=kmin)=kmin;
    if length(Kmat)<N
        Kmat(length(Kmat)+1:N) = kmin;
    end
    for i = 1:N
        K = Kmat(i);
        k = K-1;
        id_x = idx(i,1:K);
        di = value(i,1:K);
        W = (di(K)-di)/(k*di(K)-sum(di(1:k))+eps);
        S(i,id_x) = W;    
    end
end