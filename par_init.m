function param=par_init()
% 修订时间：2013-1-3
% 形成BOF模型中的参数

param.parallel=1;       % 0 单线程运算，1并行运算

% setp0 imgs参数
param.imgdir='images2\';
param.nimgs=655;

% step1 densesift特征提取参数
param.gridSpacing = 6;  
param.patchSize = 16;   
param.maxImSize = 300;
param.nrml_threshold = 1;

% step2 kmeans参数
param.kmeansK=400;      % 聚类个数

% sc 
param.scmode='mean';    % mean max 可用 默认为mean
