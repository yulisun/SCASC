function [Lx] = LaplacianMatrix(Sx)
N = size(Sx,2);
Lx_temp1 = -(Sx + Sx')/2;
Lx_temp2 = sum(Lx_temp1,2);
Lx = Lx_temp1;
for i = 1:N
    Lx(i,i) = - Lx_temp2(i) + Lx_temp1(i,i);
end
