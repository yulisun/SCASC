function [delt] = deltUpdate(Q,alfa,type)
switch type
    case 1
        delt = shrinkage(Q,alfa);
    case 21
        Q1 = sqrt(sum(Q.^2,1));
        Q1(Q1==0) = alfa;
        Q2 = (Q1 - alfa) ./ Q1;
        delt = Q * diag((Q1 > alfa) .* Q2);
end



