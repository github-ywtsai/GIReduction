function [Axis,NormalizedIntensity] = Integral(obj,Direction)
LogicalROI = obj.IntegralROI;
% Direction: qr or qz
if isempty(LogicalROI)
    LogicalROI = true(obj.YPixelsInDetector,obj.XPixelsInDetector);
end
NaNROI = obj.Logical2NaN(LogicalROI);

Data = obj.PoleData.*NaNROI;
Avaliable = ~isnan(Data);
Direction = lower(Direction);
switch Direction
    case 'qr'
        Intensity = sum(Data,1,'omitnan');
        NormalizedFactor = sum(Avaliable,1);
        Axis = obj.PoleqrAxis;
    case 'qz'
        Intensity = sum(Data,2,'omitnan');
        NormalizedFactor = sum(Avaliable,2);
        Axis = obj.PoleqzAxis;
end
Intensity = Intensity(:);
NormalizedFactor = NormalizedFactor(:);

NormalizedIntensity = Intensity./NormalizedFactor;