function NaNROI = Logical2NaN(LogicalROI)
% convert false to NaN, true to 1
NaNROI = ones(size(LogicalROI));
NaNROI(~LogicalROI) = nan;
