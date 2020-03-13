function [E]=L21_solver(Y,lambda)
% this function solves the equation
%  min 1/2||W-Q||_F^2+lambda*||W||_2,1

E=zeros(size(Y));
for i=1:size(Y,2)  % dim = 2，返回列数
    temp=norm(Y(:,i),2); % Euclid范数（欧几里得范数，常用计算向量长度），即向量元素绝对值的平方和再开方
    if temp<lambda
        E(:,i)=0;
    else E(:,i)=(temp-lambda)/temp*Y(:,i);
    end
end
