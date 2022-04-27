classdef Eiger < handle
    properties
        MasterFF
        MasterFN
        MasterFP
        BitDepthImage
        XPixelsInDetector
        YPixelsInDetector
        CountTime
        DetectorDistance
        XPixelSize
        YPixelSize
        Wavelength
        BeamCenterX
        BeamCenterY
        PixelMask
        EnviromentCheck
        Links
        RawImage % store raw data (multi-frame avaliable)
        FrameSN % store frame SNs correspounding to RawImage
        TotalFrameNum % total frame number in this h5 package
        ProcessedImage % store processed image, normalized (sum up all frame in RawImage and normalized by frame numers and count times), background supress etc.
        ProcessedSheetNum
    end
    
    methods
        Open(obj,MasterFP)
        ReadFrame(obj,FrameIdx)
        Export(obj,ExportFilePath)
        BackgroundSuppress(obj,BGobj,DataCompensationFactor,BGCompensationFactor)
    end

    
    methods  (Static = true, Access = private )
    end
        
    methods (Static = true)
        EnvConfig = EnvConfiguration()
        
        function NaNMask = LogicalMask2NaNMask(LogicalMask)
            NaNMask = ones(size(LogicalMask));
            NaNMask(LogicalMask) = nan;
        end
    end

end