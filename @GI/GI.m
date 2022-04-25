classdef GI < Eiger & ROI
    properties
        Description = 'GI'
        ReflectionCenterX
        ReflectionCenterY
        IncidentAngle = deg2rad(0.05) % in radians
        CartesianData
        PoleData
        PoleqrAxis
        PoleqzAxis
        qzMap
        qrMap
        DataReduceRatio = 0.8
        IntegralROI % only can be applied on the pole figure
    end
    
    methods
        Cartesian2Pole(obj)
        [Axis,NormalizedIntensity] = Integral(obj,Direction)
        LogicalROI = DefineROI(obj,qrRange,qzRange)
    end
    
    methods (Static = true)
    end
end