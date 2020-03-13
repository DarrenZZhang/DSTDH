function color=gen_color(curve_idx)

colors=[];
colors{end+1}='r'; %��ɫ 1
colors{end+1}='b'; %��ɫ 2
%colors{end+1}='g'; %��ɫ 3
colors{end+1}=[ 0.83 0.33 0]; % 9
colors{end+1}='m'; %�ۺ�ɫ 4
colors{end+1}='c'; %��ɫ 5
colors{end+1}='k'; %��ɫ 6
colors{end+1}=[0.7 0 0.7 ]; % 7
colors{end+1}=[0 0.7 0.7 ]; % 8
%colors{end+1}=[ 0.83 0.33 0]; % 9
colors{end+1}='g'; %��ɫ 3

%  length(colors)=9
sel_idx=mod(curve_idx-1, length(colors))+1;
color=colors{sel_idx};

end