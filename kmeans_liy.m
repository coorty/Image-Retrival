function [IDX,C,sumd] = kmeans_liy( X,k,initcenter )
% �޶�ʱ�䣺 2012-12-27 21:28
% Input��
%       X ���ݣ���Ϊ�۲죬��Ϊ����
%       k ���Ĵ���Ŀ��ʵ�ʵ���ĿС�ڵ���k
%       initcenter ��ʼ������
% Output��
%       IDX Ϊ�������������������ݵĴر�ţ�Ϊ����������
%       C �����ص�����������ÿһ��Ϊһ���ص�����
%       sumd Ϊһ����������ʾ�����ص������ĵ����ֵ֮�ͣ�������Ϊ������
% ������Ϊkmeans�Ŀ��ٰ汾�����Դ��ģѧϰ
% ����ŷʽ������Ϊ����
% ���Ҫ�����Ծ������ж��쳣�㣬�ο�piotr��kmeans2.m�ļ�
% �����Ҫ����exemplar����ֻ��Ҫ�޸ļ���C�ĵط����˴��õ���mean������


% ���
if nargin==1    error('��������...');   end
if nargin==2    initcenter=[];          end
if (k<=1)       error('����Ҫ����1');    end  
if(~ismatrix(X) || any(size(X)==0))     error('Illegal X'); end

% ��������
maxiter=1000;
minCsize=1;

N= size(X,1);               % ���ݵ����
if isempty(initcenter)
    index = randperm(N,k);  C = X(index,:);    
else
    C=initcenter;    k=size(initcenter,1);
end

[~,mem]=memory;
mem=(mem.PhysicalMemory.Available-10^9)/8;
d=size(C,2);
if matlabpool('size')<=0
    blocklen=floor((mem-k*(d+1))/(4*k+3));
else
    blocklen=floor((mem-k*(d+1))/(4*k+3)/matlabpool('size'));
end

if blocklen<=0
    error('�ڴ治��...�빺���ڴ�...');
    return;
end

m=size(X,1);
blocknum=ceil(m/blocklen);
if blocknum==1
    zb=[1;m];    
else
    zbx=1:blocklen:m;
    zby=zbx(2:end)-1;
    zby=[zby m];
    zb=[zbx;zby];    
end
clearvars zbx zby;

niters = 0;
IDX = ones(N,1); 
oldIDX = zeros(N,1);
while( ~isequal(oldIDX,IDX) && niters < maxiter )
    oldIDX = IDX;  
    n = size(C,1);    
    IDX=[];mind=[];
    
    for i=1:blocknum
        Yt = C';
        YY = sum(Yt.*Yt,1);
        xtemp=X(zb(1,i):zb(2,i),:);
        XX = sum(xtemp.*xtemp,2);
        D = XX(:,ones(1,n)) + YY(ones(1,zb(2,i)-zb(1,i)+1),:) - 2*xtemp*Yt;
        [mindtemp IDXtemp] = min(D,[],2);
        IDX=[IDX;IDXtemp];
        mind=[mind;mindtemp];
    end 
   
    i=1; 
    while(i<=k) 
        if (sum(IDX==i)<minCsize) 
            IDX(IDX==i)=-1;
            if(i<k) 
                IDX(IDX==k)=i; 
            end
            k=k-1; 
        else
            i=i+1; 
        end 
    end
    
%     if( k==0 ) 
%         IDX( randint2( 1,1, [1,N] ) ) = 1; 
%         k=1; 
%     end
    
    for i=1:k 
        if ((sum(IDX==i))==0)            
            error('should never happen - empty cluster!'); 
        end
    end    
    
    C=[];
    for i=1:k
        C(i,:)=mean(X(IDX==i,:),1);
    end  
    
    niters = niters+1;    
end

sumd = zeros(1,k); 
for i=1:k 
    sumd(i) = sum( mind(IDX==i) ); 
end
sumd=sum(sumd)/N;

% bestsumd = inf;             % ����ֵ�жϾ���û�
% if (sum(sumd)<sum(bestsumd)) 
%     bestIDX = IDX; 
%     bestC = C; 
%     bestsumd = sumd; 
% end
% 
% IDX = bestIDX; 
% C = bestC; 
% sumd = bestsumd; 


