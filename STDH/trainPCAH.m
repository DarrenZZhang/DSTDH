function PCAHparam = trainPCAH(X, PCAHparam)

% Input:
%          X: features matrix [Nsamples, Nfeatures]
%          PCAHparam.nbits: number of bits (nbits do not need to be a multiple of 8)
%
% Output:
%          PCAHparam:
%             PCAHparam.pcaW---princele component projection
%             PCAparam.nbits---encoding length

npca = PCAHparam.nbits;
% cov(X)：   求矩阵X的协方差矩阵
% [V, D] = eigs(A,k)：返回矩阵A的k个最大特征向量V，和特征值D
[pc, ~] = eigs(cov(X), npca);

% 20180228 测试用代码
%XX = cov(X);
%[pc, D] = eigs(cov(XX), npca);

PCAHparam.pcaW = pc; % no need to remove the mean

%{ 
PCA实现方法
（1）方法一：直接调用Matlab工具箱princomp( )函数实现
    [COEFF SCORE latent]=princomp(X)
    参数说明：
    1）COEFF 是主成分分量，即样本协方差矩阵的特征向量；
    2）SCORE主成分，是样本X在低维空间的表示形式，即样本X在主成份分量COEFF上的投影 ，若需要降k维，则只需要取前k列主成分分量即可
    3）latent：一个包含样本协方差矩阵特征值的向量；

（2）方法二：自己编程实现
    PCA的算法过程，用一句话来说，就是“将所有样本X减去样本均值m，再乘以样本的协方差矩阵C的特征向量V，即为PCA主成分分析”，其计算过程如下：
    [1].将原始数据按行组成ｍ行ｎ列样本矩阵X（每行一个样本，每列为一维特征）
    [2].求出样本X的协方差矩阵C和样本均值m；（Matlab可使用cov()函数求样本的协方差矩阵C，均值用mean函数）
    [3].求出协方差矩阵的特征值D及对应的特征向量V；（Matlab可使用eigs()函数求矩阵的特征值D和特征向量V）
    [4].将特征向量按对应特征值大小从上到下按行排列成矩阵，取前k行组成矩阵P；（eigs()返回特征值构成的向量本身就是从大到小排序的）
    [5].Y=(X-m)×P即为降维到k维后的数据；
（3）方法三：使用快速PCA方法
    [pcaData3 COEFF3] = fastPCA(X, k )；
%}
