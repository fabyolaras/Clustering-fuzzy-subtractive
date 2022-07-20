function [stat_table] = stat (clstr)
%count
cnt = [length(clstr(:,1)) length(clstr(:,2)) length(clstr(:,3)) length(clstr(:,4)) ...
    length(clstr(:,5)) length(clstr(:,6)) length(clstr(:,7))];
%mean
mea = mean(clstr);
%minimum value
%mi = min(clstr);
%standar deviasi
%st = std(clstr);
%quartile 1,2,3
%qua = quantile(clstr, [0.25, 0.5, 0.75]);
%maximal value
%ma = max(clstr);
var = [cnt; mea]; %mi; st; qua; ma];
stat_table = array2table(var, ...
    'VariableNames', {'Kematian', 'Gizi_Kurang', 'Gizi_Kurus', 'Pendek', 'BBLR','Pneumonia', 'Diare'}, ...
    'RowNames', {'Count','Mean'});%'Min','Std','25%','50%','75%','Max'});


