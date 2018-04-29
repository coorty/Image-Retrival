function histc=featurehist_liy(data,dicts,mode)
% �޶�ʱ�䣺 2013-1-2 11:10
% Input��
%       data����ֱ��ͼ��������ݣ���Ϊ�۲�
%       dicts���ֵ����ݣ���Ϊһ���ֵ�
%       mode:  'mean'ƽ��pooling ��max�����pooling
% Output��
%       hist���������ݵ�һ��ƽ��ֱ��ͼͳ��

% step1 ������
if ~ismatrix(data) || ~ismatrix(dicts)
    error('�������ʹ���...');
end

K=5;
% step2 ֱ��ͼͳ��
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
    error('��������...');
end
