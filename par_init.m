function param=par_init()
% �޶�ʱ�䣺2013-1-3
% �γ�BOFģ���еĲ���

param.parallel=1;       % 0 ���߳����㣬1��������

% setp0 imgs����
param.imgdir='images2\';
param.nimgs=655;

% step1 densesift������ȡ����
param.gridSpacing = 6;  
param.patchSize = 16;   
param.maxImSize = 300;
param.nrml_threshold = 1;

% step2 kmeans����
param.kmeansK=400;      % �������

% sc 
param.scmode='mean';    % mean max ���� Ĭ��Ϊmean
