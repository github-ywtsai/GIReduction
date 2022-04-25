function Logical2CSV(LogicalROI,CSVFP)

% 1:    CSV format difference using Tool/XY coordininate in different imageJ version
%       New imageJ
%       Col_1:x; Col_2:y; Col_3;value
%       early imageJ
%       Col_1:idx; Col_2:x; Col_3:y; Col_4: value
%       Only supprot format from new imageJ
% 2:    x(col) and y(row) indice start from 0 in imageJ but 1 from Matlab

[RowIdxList,ColIdxList,Value] = find(LogicalROI);
Y = RowIdxList - 1;
X = ColIdxList - 1;

DataArray = array2table([X,Y,Value]);
DataArray.Properties.VariableNames(1:3) = {'X','Y','Value'};
writetable(DataArray,CSVFP)