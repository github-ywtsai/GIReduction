classdef ROI < handle
    properties
        AdaptiveROI
        UserDefineROI
        DefaultROI
    end
    
    methods
        LogicalROI = CSV2Logical(obj,CSVFP)
    end
    
    methods (Static = true)
        Logical2CSV(LogicalROI,CSVFP)
        NaNROI = Logical2NaN(LogicalROI)
        LogicalROI = Mask2ROI(LogicalMask)
    end
end