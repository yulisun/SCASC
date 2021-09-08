function [Img] = DenormImage(X,norm_p)
b=size(X,3);
Img = zeros(size(X));
for i=1:b
    Img(:,:,i) = X(:,:,i)*norm_p(i);
end