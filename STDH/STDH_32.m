%clear all;
nbit = 32;
r = nbit;
fprintf('======start %d bits STDH======\n\n', nbit);
    
%% set output save path
addpath(genpath('../utils/'));
dataset = 'flickr_25';
folder_name = '../data_from_STDH';
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
end
save_path = sprintf('%s/B_%dbits.h5', folder_name, nbit);
fprintf('---------------------------------------\n');
fprintf('save path is %s\n', save_path);
fprintf('---------------------------------------\n');

%% load dataset
fprintf('load dataset %s...\n', dataset);
load('../fc7_features/traindata_32.txt');
load ../flickr_25/train_tag.txt;
load('../fc7_features/tanx_32.txt');
Y = train_tag;
Hx = tanh(tanx_32);

traindata = double(traindata_32');
fprintf('Finished!\n');                                                         
fprintf('---------------------------------------\n'); 

%% data prepocess
fprintf('data prepocessing...\n');
X = traindata; 
X = normalize(X');
traindata = traindata';
sampleMean = mean(traindata, 1);                                                       
traindata = (traindata - repmat(sampleMean, size(traindata, 1), 1));
[n, d] = size(X);   
[~, c] = size(Y);
fprintf('Finished!\n');
fprintf('---------------------------------------\n');

%% Parameter set
nMaxIter = 100; 

%% Parameter initialization
% A, EA, EB n*r
A  = zeros(n, r);
EA = zeros(n, r);
EB = zeros(n, r);
% randn('seed',3);                   
% Z = sign(randn(n, r));  

Zparam.nbits = r;
Zparam =  trainPCAH(traindata, Zparam);
Zparam =  trainITQ(traindata,  Zparam); 
tempZ = traindata * Zparam.pcaW;
Z = sign(tempZ * Zparam.r);

%% (1) K-means1
[~, AnchorA] = litekmeans(X, nAnchorA, 'MaxIter', 5, 'Replicates', 1);

%% (2) construct anchor graph
V = zeros(n, nAnchorA);
Dis = sqdist(X', AnchorA');

val = zeros(n, sA);
pos = val;
for i = 1:sA
    [val(:,i), pos(:,i)] = min(Dis, [], 2); % val-value, pos-index
    tep = (pos(:,i) - 1) * n + [1:n]';
    Dis(tep) = 1e60;
end
clear Dis;
clear tep;

if sigmaA == 0
    sigmaA = mean(val(:,sA) .^ 0.5);
end

val = exp(-val / (1/1*sigmaA^2));
val = repmat(sum(val, 2).^ -1, 1, sA) .* val; % normalize
tep = (pos - 1) * n + repmat([1:n]', 1, sA);
val(isnan(val))=0; % 20190101 add
V([tep]) = [val];
clear tep;
clear val;
clear pos;

lamda = sum(V);
Lambda = diag(lamda .^ -1);
clear lamda; 

%% (3) K-means2
tempXY = [X, Y];  % n * (d + c)
[~, AnchorH] = litekmeans(tempXY, nAnchorH, 'MaxIter', 5, 'Replicates', 1);

%% (4) construct hypergraph
% 1. H (n * m) : incidence matrix    
sH = 10;
%sH = 2;
H = exp(- sqdist(tempXY', AnchorH') / (2*sigmaH*sigmaH));
% tempH = exp(- sqdist(tempXY', AnchorH') / (2*sigmaH*sigmaH));
% ballH = sort(tempH, 2);  % row
% ballH = mean(ballH(:,sH));
% H = double(tempH < ballH);
clear Dis;
clear tep;

% 2. Dw (m * m) : hyperedge weight matrix    all set 1
W = ones(nAnchorH, 1);
Dw = diag(W); 

% 3. De (m * m) : hyperedge degree matrix 
tempDe = sum(H, 1);
De = diag(tempDe.^-1); % sum col

% 4. Dv (n * n) : vertex degree matrix
tempDv = H * W;
Dv = diag(tempDv.^-0.5);

%% loop
i = 0; 
loss_old = 0;

while i < nMaxIter
    i = i + 1;  
    
    %% P-step
    tempP = Z - A + (1/mu) * EA;
    P = pinv(Y' * Y) * (Y' * tempP);

    %% A-step
    T = Z - Y*P + (1/mu) * EA;
    [A] = L21_solver(T, 1/mu);

    %% B-step
    M = Dv * H * Dw * De * (H' * Dv) * Z;
    N = V * Lambda * (V' * Z);
    B = (1/mu) * (beta*M + alpha*N + mu*Z + EB);

    %% Z-step
    Q = B' * Dv * H * Dw * De * (H' * Dv);
    G = B' * V * Lambda * V';
    Z = sign(mu*Y*P + mu*A + mu*B + beta*Q' + alpha*G' - EA - EB + 2*nu*Hx);

    %% EA, EB, mu-step
    EA = EA + mu*(Z - Y*P - A);
    EB = EB + mu*(Z - B);
    mu = mu * pho;
    
    %% calculate object function value  
    % part1 ||Z - Y*P||_2,1
    Temp1  = Z - Y * P;
    nTemp1 = 0;
    for j = 1 : r 
        nTemp1 = norm(Temp1(:, j), 2) + nTemp1;
    end

    % part2  -beta * Tr(B'*Dv^{-1/2}*H*Dw*De^{-1}*H'*Dv^{-1/2}*Z)
    Temp2  = B'* Dv * H * Dw * De * H' * Dv * Z;
    nTemp2 = -beta * trace(Temp2);

    % part3  -alpha * Tr(B' * V * Lambda * V'* Z)
    Temp3  = B' * V * Lambda * V'* Z;
    nTemp3 = -alpha * trace(Temp3);

   % part4
    nTemp4 = nu * norm(Hx-Z, 'fro');

    % total  
    loss = nTemp1 + nTemp2 + nTemp3 + nTemp4;
    res = (loss - loss_old)/loss_old;
    loss_old = loss;

    fprintf('iteration %3d, loss is %.4f, residual error is %.5f\n', i, loss, res);
    fprintf('---------------------------------------\n'); 

    % break  
    if (loss_old - loss) < 0.0001
        if i > 3
            break
        end
    end   
end

%fprintf('iteration %3d\n', i);
fprintf('======end %d bits STDH======\n\n', nbit);

clear B;
B = Z;
final_B = B;
final_B = sign(final_B);

fprintf('save B and final_B as HDF5 file\n');
fprintf('save path is %s\n' ,save_path);
h5create(save_path, '/final_B',[size(final_B, 2) size(final_B, 1)]);
h5create(save_path, '/B',[size(B, 2) size(B, 1)]);
h5write(save_path, '/final_B', final_B');
h5write(save_path, '/B', B');
fprintf('Finished!\n');                                                         
fprintf('---------------------------------------\n'); 
