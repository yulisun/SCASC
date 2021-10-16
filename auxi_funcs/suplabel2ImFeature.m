function [Im,feature,sigband] = suplabel2ImFeature(sup_img,X,b)
feature = suplabel2DI(sup_img,X);
Im = feature(:,:,1:b);
sigband = sum(feature.^2,3);