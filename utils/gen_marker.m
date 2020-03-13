
function marker=gen_marker(curve_idx)

markers=[];

% scheme
% scheme
markers{end+1}='o'; % 1
markers{end+1}='*'; % 2
markers{end+1}='d'; % 3 菱形
markers{end+1}='p'; % 4 五角星
markers{end+1}='s'; % 5 正方形
markers{end+1}='h'; % 6六边形
markers{end+1}='o';  
markers{end+1}='*';
markers{end+1}='o';
markers{end+1}='o';
markers{end+1}='o';
markers{end+1}='o';
markers{end+1}='o';

% markers{end+1}='s';
% markers{end+1}='o';
% markers{end+1}='d';
% markers{end+1}='^';
% markers{end+1}='*';
% markers{end+1}='v';
% markers{end+1}='x';
% markers{end+1}='+';
% markers{end+1}='>';
% markers{end+1}='<';
% markers{end+1}='.';
% markers{end+1}='p';
% markers{end+1}='h';

sel_idx=mod(curve_idx-1, length(markers))+1;
marker=markers{sel_idx};

end
