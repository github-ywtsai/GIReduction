function LogicalROI = DefineROI(obj,qrRange,qzRange)
qrPart = false(obj.YPixelsInDetector,obj.XPixelsInDetector);
qzPart = false(obj.YPixelsInDetector,obj.XPixelsInDetector);
qrPart(and(obj.qrMap>=min(qrRange),obj.qrMap<=max(qrRange))) = true;
qzPart(and(obj.qzMap>=min(qzRange),obj.qzMap<=max(qzRange))) = true;

LogicalROI = and(qrPart,qzPart);