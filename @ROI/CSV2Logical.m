function LogicalROI = CSV2Logical(obj,CSVFP)

CSVData = LoadDataFromCSV(CSVFP);
LogicalROI = logical(accumarray(CSVData,1,[obj.YPixelsInDetector,obj.XPixelsInDetector]));

function CSVData = LoadDataFromCSV(CSVFP)
temp = importdata(CSVFP,',');
NumData = temp.data;

% 1:    CSV format difference using Tool/XY coordininate in different imageJ version
%       New imageJ
%       Col_1:x; Col_2:y; Col_3;value
%       early imageJ
%       Col_1:idx; Col_2:x; Col_3:y; Col_4: value
%       Only supprot format from new imageJ
% 2:    x(col) and y(row) indice start from 0 in imageJ but 1 from Matlab

CSVData = fliplr(NumData(:,1:2)+1);