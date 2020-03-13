function [evaluation_info] = eva_ranking_single(hammTrainTest, traingnd, testgnd)
%addpath('./utils/');

cateTrainTest = bsxfun(@eq, traingnd, testgnd');

% hash lookup: precision and reall
hammRadius = 2;
Ret = (hammTrainTest <= hammRadius+0.00001);
[Pre, Rec] = evaluate_macro(cateTrainTest, Ret);

% hamming ranking: MAP
[~, HammingRank] = sort(hammTrainTest, 1);
MAP = cat_apcal(traingnd, testgnd, HammingRank);
% [Pre_500, ~]  = cat_ap_topK(cateTrainTest, HammingRank, 500);
% [Pre_2000, ~] = cat_ap_topK(cateTrainTest, HammingRank, 2000);
[Pre_5000, ~] = cat_ap_topK(cateTrainTest, HammingRank, 5000);

evaluation_info.precision = Pre;
evaluation_info.recall    = Rec;
evaluation_info.mAP       = MAP;
% evaluation_info.Pre_500   = Pre_500;
% evaluation_info.Pre_2000  = Pre_2000;
evaluation_info.Pre_5000  = Pre_5000;