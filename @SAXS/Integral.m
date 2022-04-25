function [Axis,Intensity,Error] = Integral(obj,Direction)
% Direction: q or azimuth
if isempty(obj.UserDefineROI)
    LogicalROI = true(obj.YPixelsInDetector,obj.XPixelsInDetector);
else
    LogicalROI = and(obj.UserDefineROI,obj.DefaultROI);
end

NaNROI = obj.Logical2NaN(LogicalROI);


Direction = lower(Direction);
switch Direction
    case 'q'
        MaskedPixelDisMatrix = obj.PixelDistanceMap .* NaNROI;
        MaskedqMatrix = obj.qMap .* NaNROI;
        % create q axis with 1 pixel resolution
        [PixelDisMin , PixelDisMax] = bounds(MaskedPixelDisMatrix,'all');
        % pixel axis and edge
        PixelAxis = round(PixelDisMin):round(PixelDisMax);
        PixelEdge = (PixelAxis(1):PixelAxis(end)+1)  - 0.5;
        % convert pixel axis to tth axis
        TwoThetaAxis = atan(PixelAxis*obj.XPixelSize/obj.DetectorDistance);
        TwoThetaEdge = atan(PixelEdge*obj.XPixelSize/obj.DetectorDistance);
        % convert tth axis to q axis
        qAxis =  4*pi/(obj.Wavelength*1E10)*sin(1/2 *TwoThetaAxis); % [1/A]
        qEdge =  4*pi/(obj.Wavelength*1E10)*sin(1/2 *TwoThetaEdge); % [1/A]
        % get guiding vector
        [N,~,Bin] = histcounts(MaskedqMatrix,qEdge);
        % remove nan part
        BinTemp = Bin(:);
        ProcessedImageTemp = obj.ProcessedImage(:);
        SkipIdx = BinTemp == 0;
        BinTemp(SkipIdx) = [];
        ProcessedImageTemp(SkipIdx) = [];
        
        Intensity = accumarray(BinTemp,ProcessedImageTemp,size(N'))./N';
        Error = accumarray(BinTemp,sqrt(abs(ProcessedImageTemp)),size(N'))./N';
        Axis = qAxis;
        
    case 'azimuth' % 1 deg resoult
        azimuthAxis = deg2rad(0:360);
        azimuthEdge = deg2rad((0:360+1)-0.5);
        MaskedazimuthMatrix = obj.azimuthMap .* NaNROI;
        [N,~,Bin] = histcounts(MaskedazimuthMatrix,azimuthEdge);
        BinTemp = Bin(:);
        ProcessedImageTemp = obj.ProcessedImage(:);
        SkipIdx = BinTemp == 0;
        BinTemp(SkipIdx) = [];
        ProcessedImageTemp(SkipIdx) = [];
        Intensity = accumarray(BinTemp,ProcessedImageTemp,size(N'))./N';
        Error = accumarray(BinTemp,sqrt(abs(ProcessedImageTemp)),size(N'))./N';
        Axis = azimuthAxis;
end