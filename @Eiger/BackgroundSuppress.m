function BackgroundSuppress(obj,BGobj,DataCompensationFactor,BGCompensationFactor)
%Using the Normalized data in BGobj as the background to suppress
%background of raw data in obj. Then Normalized it and send to
%obj.NormalizedDataContainer.
obj.ProcessedImage = (sum(obj.RawImage/obj.CountTime/DataCompensationFactor - BGobj.ProcessedImage/BGCompensationFactor,3))/obj.ProcessedSheetNum;