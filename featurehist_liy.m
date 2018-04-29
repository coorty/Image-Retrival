function histc=featurehist_liy(data,dicts,mode)
% 修订时间： 2013-1-2 11:10
% Input：
%       data：待直方图计算的数据，行为观察
%       dicts：字典数据，行为一个字典
%       mode:  'mean'平均pooling ‘max’最大pooling
% Output：
%       hist：所有数据的一个平均直方图统计

% step1 检查错误
if ~ismatrix(data) || ~ismatrix(dicts)
    error('数据类型错误...');
end

K=5;
% step2 直方图统计
[ndata,nvar]=size(data);
C=zeros(ndata,size(dicts,1));
for i=1:ndata
    [~,ID]=pdist2(dicts,data(i,:),'euclidean','Smallest',K);
    B=dicts(ID,:);
    C(i,ID)=quadprog(B*B',-B*data(i,:)',[],[],ones(1,K),1,[],[],[],optimset('Display','off','MaxIter',1500));
    
end
if strcmp(mode,'mean')
    histc=mean(C,1);
elseif strcmp(mode,'max');
    histc=max(C,1);
else
    error('参数错误...');
end
