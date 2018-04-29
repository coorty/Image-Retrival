function [IDX,C,sumd] = kmeans_liy( X,k,initcenter )
% 修订时间： 2012-12-27 21:28
% Input：
%       X 数据，行为观察，列为变量
%       k 最大的簇数目，实际的数目小于等于k
%       initcenter 初始化中心
% Output：
%       IDX 为列向量，表明各个数据的簇编号，为连续的整数
%       C 各个簇的中心向量，每一行为一个簇的中心
%       sumd 为一行向量，表示各个簇到其中心点的数值之和，可以作为误差估计
% 本函数为kmeans的快速版本，可以大规模学习
% 采用欧式距离作为度量
% 如果要设置以距离来判断异常点，参考piotr的kmeans2.m文件
% 如果需要计算exemplar，则只需要修改计算C的地方，此处用的是mean来计算


% 检查
if nargin==1    error('参数过少...');   end
if nargin==2    initcenter=[];          end
if (k<=1)       error('簇数要大于1');    end  
if(~ismatrix(X) || any(size(X)==0))     error('Illegal X'); end

% 参数设置
maxiter=1000;
minCsize=1;

N= size(X,1);               % 数据点个数
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
    error('内存不够...请购置内存...');
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

% bestsumd = inf;             % 该数值判断聚类好坏
% if (sum(sumd)<sum(bestsumd)) 
%     bestIDX = IDX; 
%     bestC = C; 
%     bestsumd = sumd; 
% end
% 
% IDX = bestIDX; 
% C = bestC; 
% sumd = bestsumd; 


