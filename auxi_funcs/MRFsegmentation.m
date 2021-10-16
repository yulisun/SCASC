function [CM_map,labels] = MRFsegmentation(sup_img,alfa,delt)
[h,w]   = size(sup_img);
nbr_sp  = max(sup_img(:));
idx_img = label2idx(sup_img);
%% R-adjacency neighborhood system
for i = 1:nbr_sp
    index_vector = idx_img{i};
    [location_x, location_y] = ind2sub(size(sup_img),index_vector);
    location_center(i,:) = [round(mean(location_x)) round(mean(location_y))];
end
adj_mat = zeros(nbr_sp);
for i=2:h-1
    for j=2:w-1       
        label = sup_img(i,j);        
        if (label ~= sup_img(i+1,j-1))
            adj_mat(label, sup_img(i+1,j-1)) = 1;
        end
        if (label ~= sup_img(i,j+1))
            adj_mat(label, sup_img(i,j+1)) = 1;
        end
        if (label ~= sup_img(i+1,j))
            adj_mat(label, sup_img(i+1,j)) = 1;
        end
        if (label ~= sup_img(i+1,j+1))
            adj_mat(label, sup_img(i+1,j+1)) = 1;
        end      
    end
end
adj_mat_1 = double((adj_mat + adj_mat')>0);
R = 2*round(sqrt(h*w/nbr_sp));
adj_mat = zeros(nbr_sp);
for i=1:nbr_sp
    for j = i:nbr_sp
    if ((location_center(i,1) - location_center(j,1))^2 + (location_center(i,2) - location_center(j,2))^2 < R^2)
     adj_mat (i,j) = 1;  
    end
    end
end
adj_mat = double((adj_mat + adj_mat')>0);
adj_mat_2 = adj_mat - eye(nbr_sp);
adj_mat = adj_mat_1|adj_mat_2;
%% edgeWeights
edgeWeights = zeros(sum(adj_mat(:)),4);
[node_x, node_y] = find(adj_mat ==1);
edgeWeights(:,1) = node_x; % index of node 1
edgeWeights(:,2) = node_y; % index of node 2
for i = 1:sum(adj_mat(:))
    index_node_x = edgeWeights(i,1); 
    index_node_y = edgeWeights(i,2); 
    feature_x = delt(:,index_node_x);
    feature_y = delt(:,index_node_y);
    Dpq(i) = norm(feature_x-feature_y,2)^2;
    dist(i) = max(norm(location_center(index_node_x,:)-location_center(index_node_y,:),2),1);
end
sigma = mean(Dpq);
Vpq = exp(-Dpq/(2*sigma));
Vpq = Vpq ./dist;
edgeWeights(:,3) = (1 - alfa)*Vpq;                  % node 1 ---> node 2
edgeWeights(:,4) = (1 - alfa)*Vpq;                  % node 2 ---> node 1
%% calculate W
 for i = 1:nbr_sp
     idx = find(node_y==i);
     W_temp(i) = sum(Vpq(idx));
 end
 W = max(W_temp)+log(2);    
%% termWeights
Ic = (sum(delt.^2,1));
Ic = remove_outlier(Ic);
Ic = Ic/max(Ic);
T_theory = graythresh(Ic); 
termWeights = zeros(nbr_sp,2);
termWeights_sp = alfa*(-log(Ic/2/T_theory));
termWeights_sp(Ic>2*T_theory) = 0;
termWeights_tp = alfa*(-log(1 - Ic/2/T_theory));
termWeights_tp(Ic>2*T_theory) = W;
termWeights(:,1) = real(termWeights_sp);
termWeights(:,2) = real(termWeights_tp);
%% graph-cut;
% use the graphCutMex download from https://github.com/aosokin/graphCutMex_BoykovKolmogorov.
% Yuri Boykov and Vladimir Kolmogorov, An experimental comparison of Min-Cut/Max-Flow algorithms for energy minimization in vision, 
% IEEE TPAMI, 26(9):1124-1137, 2004.
addpath('GC');
[cut, labels] = graphCutMex(termWeights, edgeWeights);
%% CM calculation
idx_img = label2idx(sup_img);
for i = 1:size(delt,2)
    index_vector = idx_img{i};
    CM_map(index_vector) = labels(i);
end
CM_map  =reshape(CM_map,[size(sup_img,1) size(sup_img,2)]);
