function out=densesift_liy(imgpath,param)
% 计算图像的稠密sift特征，输入为图像的路径

I = imread(imgpath);            % 读入图像
if ndims(I) == 3                % 灰度化
    I = im2double(rgb2gray(I));
else
    I = im2double(I);
end

% 参数设置
maxImSize=param.maxImSize;
patchSize=param.patchSize;
gridSpacing=param.gridSpacing;
nrml_threshold=param.nrml_threshold;

% for计算量
[im_h, im_w] = size(I);
if max(im_h, im_w) > maxImSize,
    I = imresize(I, maxImSize/max(im_h, im_w), 'bicubic');
    [im_h, im_w] = size(I);
end;

% 生成densesift网格参数
remX = mod(im_w-patchSize,gridSpacing);
offsetX = floor(remX/2)+1;
remY = mod(im_h-patchSize,gridSpacing);
offsetY = floor(remY/2)+1;
[gridX,gridY] = meshgrid(offsetX:gridSpacing:im_w-patchSize+1, offsetY:gridSpacing:im_h-patchSize+1);

% 对dense点计算sift特征
siftArr = sp_find_sift_grid(I, gridX, gridY, patchSize, 0.8);
[out, ~] = sp_normalize_sift(siftArr, nrml_threshold);