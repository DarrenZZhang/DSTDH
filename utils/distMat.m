 function D=distMat(P1, P2)
% Euclidian distances between vectors → 两个向量之间的欧氏距离
% 返回一个矩阵：size=P1的行*P2的行，里面每个变量为P1中的每个点，对P2中的每个点的欧氏距离

if nargin == 2  % nargin：形参的个数
    P1 = double(P1);
    P2 = double(P2);
    
     %sum(a,dim)： dim=2表示对每一行进行求和； size(a,dim)→ dim=1返回行数，
    X1=repmat(sum(P1.^2,2),[1 size(P2,1)]); 
    X2=repmat(sum(P2.^2,2),[1 size(P1,1)]);
    R=P1*P2';
    D=real(sqrt(X1+X2'-2*R));
else
    P1 = double(P1);

    % each vector is one row
    X1=repmat(sum(P1.^2,2),[1 size(P1,1)]);
    R=P1*P1';
    D=X1+X1'-2*R;
    D = real(sqrt(D));
end


% 当P1（n*m）、P2（n*m）为矩阵时，每行代表一个数据点
% 返回一个n*n的矩阵A
% A(i,j)代表，第P1的i个数据点，与P2的第j个数据点的欧氏距离