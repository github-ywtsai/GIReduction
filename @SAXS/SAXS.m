classdef SAXS < Eiger & ROI
    properties
        Description = 'SAXS'
        PixelDistanceMap
        qMap
        tthMap
        azimuthMap
    end
    
    methods
        Cartesian2q(obj)
        [Axis,Intensity,Error] = Integral(obj,LogicalROI,Direction)
        LogicalROI = DefineROI(obj,qRange,azimuthRange)
    end
end