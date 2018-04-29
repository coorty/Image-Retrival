function id=imgre(ind)
% step0 生成参数
param=par_init();
% step1 图片稠密取样的sift特征
if ~exist('sift.mat','file') && ~exist('sift','var')       % 不存在 计算并保存
    if param.parallel
        if matlabpool('size')<=0
            matlabpool open local;
        end
        parfor i=1:param.nimgs
            imgpath=[param.imgdir num2str(i) '.jpg'];
            sift{i,1}=single(densesift_liy(imgpath,param));
        end
        matlabpool close;
    else
        for i=1:param.nimgs
            imgpath=[param.imgdir num2str(i) '.jpg'];
            sift{i,1}=densesift_liy(imgpath,param);
        end
    end
    save('sift.mat','sift');
else
    sift=load('sift.mat');
    sift=sift.sift;
end

% step2 BOF模型，采用kmeans聚类
if ~exist('cens.mat','file') && ~exist('cens','var')        % 不存在 计算并保存
    [~,cens,~] = kmeans_liy(double(cell2mat(sift)),param.kmeansK);
    save('cens.mat','cens');
else
    cens=load('cens.mat');
    cens=cens.cens;
end

% step3 sparse coding
if ~exist('histimg.mat','file') && ~exist('histimg','var')       % 不存在 计算并保存
    if param.parallel
        if matlabpool('size')<=0
            matlabpool open local;
        end
        parfor i=1:param.nimgs
            histimg(i,:)=featurehist_liy(sift{i,1},cens,param.scmode);
        end
        matlabpool close;
    else
        for i=1:param.nimgs
            histimg(i,:)=featurehist_liy(sift{i,1},cens,param.scmode);
        end
    end
    save('histimg.mat','histimg');
else
    histimg=load('histimg.mat');
    histimg=histimg.histimg;
end


[~,id]=pdist2(histimg,histimg(ind,:),'euclidean','Smallest',param.nimgs);


