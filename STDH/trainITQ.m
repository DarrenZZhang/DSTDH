function ITQparam = trainITQ(X, ITQparam)

% Input:
%          X: n*d, n is the number of images
%          ITQparam:
%                           ITQparam.pcaW---PCA of all the database
%                           ITQparam.nbits---encoding length
% Output:
%             ITQparam:
%                           ITQparam.pcaW---PCA of all the database
%                           ITQparam.nbits---encoding length
%                           ITQparam.r---ITQ rotation projection

pc = ITQparam.pcaW;     %所有数据库的pca
nbits = ITQparam.nbits; %编码长度

V = X*pc;  %数据矩阵 * 所有数据库的pca →降维

% initialize with a orthogonal random rotation：所有数据库都以正交随机旋转进行初始化
R = randn(nbits, nbits);  %返回一个nbits*nbits的随机项标准正态分布的矩阵 →初始化R为一个随机的正交矩阵
[U11 S2 V2] = svd(R); %对R进行奇异值分析，返回一个与R同大小的对角矩阵S2，两个酉矩阵U 和V
R = U11(:, 1: nbits); %U11的行不变，列取从1到nbits

% ITQ to find optimal rotation
for iter=0:500
    %（1）固定R，更新B(B用UX表示)
    Z = V * R; %降维后的矩阵 * 随机正交矩阵
    UX = ones(size(Z,1),size(Z,2)).*-1;  %ones(a,b) ones(a,b) ;  size(X,dim)→返回矩阵的行数或列数，dim=1返回行数，dim=2返回列数
    UX(Z>=0) = 1; 
    % （2）固定B，更新R
    C = UX' * V; % （>0→设为1；<0→设为-1） * 降维后的矩阵
    [UB, sigma, UA] = svd(C);    
    R = UA * UB';
    %fprintf('iteration %d has finished\r',iter);
end

% make B binary
%B = UX;
%B(B<0) = 0;

ITQparam.r = R;