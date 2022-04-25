function LogicalROI = DefineROI(obj,qRange,azimuthRange)
% qRange in 1/A, azimuth Ranage in degree.
azimuthRange = deg2rad(azimuthRange);

qPart = false(obj.YPixelsInDetector,obj.XPixelsInDetector);
azimuthPart = false(obj.YPixelsInDetector,obj.XPixelsInDetector);
qPart(and(obj.qMap>=min(qRange),obj.qMap<=max(qRange))) = true;
azimuthPart(and(obj.azimuthMap>=min(azimuthRange),obj.azimuthMap<=max(azimuthRange))) = true;

LogicalROI = and(qPart,azimuthPart);