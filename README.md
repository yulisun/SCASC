# SCASC
Sparse Constrained Adaptive Structure Consistency based Unsupervised Image Regression for Heterogeneous Remote Sensing Change Detection

## Introduction
MATLAB Code: SCASC - 2021
This is a test program for the Sparse Constrained Adaptive Structure Consistency based method (SCASC) for heterogeneous change detection.

SCASC is an unsupervised image regression method based on the  structure consistency between heterogeneous images. SCASC first adaptively 
constructs a similarity graph to represent the structure of pre-event image, then uses the graph to translate the pre-event image to the 
domain of post-event image, and then computes the difference image. Finally, a superpixel-based Markovian segmentation model is designed 
to segment the difference image into changed and unchanged classes. 

Please refer to the paper for details. You are more than welcome to use the code! 

===================================================

## Available datasets

#2-Texas is download from Professor Michele Volpi's webpage at https://sites.google.com/site/michelevolpiresearch/home.

#3-Img7, #4-Img17, and #7-Img5 can be found at Professor Max Mignotte's webpage (http://www-labs.iro.umontreal.ca/~mignotte/) and they are associated with this paper https://doi.org/10.1109/TGRS.2020.2986239.

#6-California is download from Dr. Luigi Tommaso Luppino's webpage (https://sites.google.com/view/luppino/data) and it was downsampled to 875*500 as shown in our paper.

===================================================

## Citation

If you use this code for your research, please cite our paper. Thank you!

@ARTICLE{Sun2021Sparse,
  author={Sun, Yuli and Lei, Lin and Guan, Dongdong and Li, Ming and Kuang, Gangyao},  
  journal={IEEE Transactions on Geoscience and Remote Sensing},   
  title={Sparse Constrained Adaptive Structure Consistency based Unsupervised Image Regression for Heterogeneous Remote Sensing Change Detection},   
  year={2021},  
  volume={},  
  number={},  
  pages={},  
  doi={10.1109/TGRS.2021.3110998}}  

## Future work

In this work, due to the computational complexity, we only consider the forward transformation, i.e., translating the pre-event image to the domain of post-event image. 
Our future work is to improve its computation efficiency and design an effective fusion strategy to fuse the forward and backward detection results, 
thus improving the detection performance.

## Q & A

If you have any queries, please do not hesitate to contact me (yulisun@mail.ustc.edu.cn).
