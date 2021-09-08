%%  Sparse Constrained Adaptive Structure Consistency based Unsupervised Image Regression for Heterogeneous Remote Sensing Change Detection
%{
Code: SCASC - 2021
This is a test program for the Sparse Constrained Adaptive Structure Consistency method (SCASC) for heterogeneous change detection.

If you use this code for your research, please cite our paper. Thank you!

Sun, Yuli, et al. "Sparse Constrained Adaptive Structure Consistency based Unsupervised Image Regression for Heterogeneous Remote Sensing Change Detection."
IEEE Transactions on Geoscience and Remote Sensing, Accepted, 2021,
doi:10.1109/TGRS.2021.3110998.
===================================================
%}

clear;
close all
addpath('auxi_funcs')
%% load dataset
addpath('datasets')
% #2-Texas is download from Professor Michele Volpi's webpage at https://sites.google.com/site/michelevolpiresearch/home
% #3-Img7, #4-Img17, and #7-Img5 can be found at Professor Max Mignotte's webpage (http://www-labs.iro.umontreal.ca/~mignotte/) and they are associated with this paper https://doi.org/10.1109/TGRS.2020.2986239.
% #6-California is download from Dr. Luigi Tommaso Luppino's webpage (https://sites.google.com/view/luppino/data) and it was downsampled to 875*500 as shown in our paper.
% For other datasets, we recommend a similar pre-processing as in "Load_dataset"
dataset = '#5-Shuguang';% #1-Italy, #2-Texas, #3-Img7, #4-Img17, #5-Shuguang, #6-California, #7-Img5 
Load_dataset
fprintf(['\n Data loading is completed...... ' '\n'])
%% Parameter setting
% With different parameter settings, the results will be a little different
% Ns: the number of superpxiels,  A larger Ns will improve the detection granularity, but also increase the running time. 5000 <= Ns <= 20000 is recommended.
% Niter: the maximum number of SCASC iterations, Niter =10 is recommended.
% lamda: sparse regularization parameter, which should be selected according to the proportion of the changed component. 
% alfa: balance parameter. The smaller the lambda, the smoother the CM. 0.025<= alfa <=0.1 is recommended.
opt.Ns = 10000;
opt.Niter = 10;
opt.lamda = 0.1;
opt.alfa = 0.05; % for #2-Texas, alfa = 0.025 is better.
%% SCASC
t_o = clock;
fprintf(['\n SCASC is running...... ' '\n'])
%------------- Preprocessing: Superpixel segmentation and feature extraction---------------%
t_p1 = clock;
Compactness = 1;
[sup_img,Ns] =  SuperpixelSegmentation(image_t1,opt.Ns,Compactness);
[t1_feature,t2_feature,norm_par] = MSMfeature_extraction(sup_img,image_t1,image_t2) ;% MVE;MSM
fprintf('\n');fprintf('The computational time of Preprocessing (t_p1) is %i \n', etime(clock, t_p1));
fprintf(['\n' '====================================================================== ' '\n'])

%------------- Algorithm 1: Graph Construction---------------%
t_p2 = clock;
Kmax =round(size(t1_feature,2).^0.5);
[Sx] = AdaptiveStructureGraph(t1_feature,Kmax);%
fprintf('\n');fprintf('The computational time of Graph Construction (t_p2) is %i \n', etime(clock, t_p2));
fprintf(['\n' '====================================================================== ' '\n'])

%------------- Algorithm 2: Image Regression---------------%
% Sparse constrained adaptive structure consistency based image regression
% image_t1 ----> image_t2
t_p3 = clock;
if opt.Ns <=10000
    [regression_t1, delt,RelDiff] = SCASC_IR(t1_feature,t2_feature,Sx,opt);% t1--->t2
elseif opt.Ns >10000 % for large Ns, the preconditioned conjugate gradient method is recommended
    [regression_t1, delt,RelDiff] = SCASC_IR_PCG(t1_feature,t2_feature,Sx,opt);% t1--->t2
end
fprintf('\n');fprintf('The computational time of Image Regression (t_p3) is %i \n', etime(clock, t_p3));
fprintf(['\n' '====================================================================== ' '\n'])

%------------- Algorithm 3: MRF segmentation---------------%
t_p4 = clock;
[CM_map,labels] = MRFsegmentation(sup_img,opt.alfa,delt);
fprintf('\n');fprintf('The computational time of MRF segmentation (t_p4) is %i \n', etime(clock, t_p4));
fprintf(['\n' '====================================================================== ' '\n'])

fprintf('\n');fprintf('The total computational time of SCASC (t_total) is %i \n', etime(clock, t_o));
%% Displaying results
fprintf(['\n' '====================================================================== ' '\n'])
fprintf(['\n Displaying the results...... ' '\n'])
%---------------------AUC PCC F1 KC ----------------------%
n=500;
Ref_gt = Ref_gt/max(Ref_gt(:));
DI_tmep = sum(delt.^2,1);
DI  = suplabel2DI(sup_img,DI_tmep);
[TPR, FPR]= Roc_plot(DI,Ref_gt,n);
[AUC, Ddist] = AUC_Diagdistance(TPR, FPR);
[tp,fp,tn,fn,fplv,fnlv,~,~,pcc,kappa,imw]=performance(CM_map,1*Ref_gt);
F1 = 2*tp/(2*tp + fp + fn);
result = 'AUC is %4.3f; PCC is %4.3f; F1 is %4.3f; KC is %4.3f \n';
fprintf(result,AUC,pcc,F1,kappa)

%------------Regression image,  Difference imag and Change map --------------%
figure; plot(FPR,TPR);title('ROC curves');
[RegImg,~,~] = suplabel2ImFeature(sup_img,regression_t1,size(image_t2,3));% t1--->t2
RegImg = DenormImage(RegImg,norm_par(size(image_t1,3)+1:end));
figure;
if strcmp(dataset,'#2-Texas') == 1
    subplot(131);imshow(6*uint16(RegImg(:,:,[5 4 3])));title('Regression image')
elseif strcmp(dataset,'#6-California') == 1
    subplot(131);imshow(RegImg,[-1 1]);title('Regression image')
elseif strcmp(dataset,'#7-Img5') == 1
    subplot(131);imshow(uint8(exp(RegImg*3.75+1.8)));title('Regression image')
else
    subplot(131);imshow(uint8(RegImg));title('Regression image')
end
subplot(132);imshow(remove_outlier(DI),[]);title('Difference image')
subplot(133);imshow(CM_map,[]);title('Change mape')
