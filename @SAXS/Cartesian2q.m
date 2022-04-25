function Cartesian2q(obj)
% create pxiel distant map
[ColIdx,RowIdx] = meshgrid(1:obj.XPixelsInDetector,1:obj.YPixelsInDetector);

VerticalPixelDisMatrix = RowIdx-obj.BeamCenterY; % signed
HorizontalPixelDisMatrix = ColIdx-obj.BeamCenterX; % signed
PixelDisMatrix =sqrt(VerticalPixelDisMatrix.^2 + HorizontalPixelDisMatrix.^2); % sqrt() is very slow. un-signed.

% create q/tth-map matrix
TwoThetaMatrix = atan(PixelDisMatrix*obj.XPixelSize/obj.DetectorDistance); % q = 4pi/sin(th)/lambda, atan also takes a lot of time.
qMatrix = 4*pi/(obj.Wavelength*1E10)*sin(1/2 *TwoThetaMatrix); % [1/A]

% create azimuth-map matrix
Temp = HorizontalPixelDisMatrix + 1i*(-VerticalPixelDisMatrix);
azimuthMatrix = angle(Temp);
azimuthMatrix(VerticalPixelDisMatrix>0) = 2*pi + azimuthMatrix(VerticalPixelDisMatrix>0);
% azimuthMatrix from 0 to 360 deg, and the 0 along the +x direction

% assign values
obj.PixelDistanceMap = PixelDisMatrix;
obj.qMap = qMatrix;
obj.tthMap = TwoThetaMatrix;
obj.azimuthMap = azimuthMatrix;

%{
% reduce 2D to 1D part
% create masked matrix
MaskedPixelDisMatrix = PixelDisMatrix .* NaNMask;
MaskedqMatrix = qMatrix .* NaNMask;

% create q axis with 1 pixel resolution
PixelDisMin = min(MaskedPixelDisMatrix,[],'all');
PixelDisMax = max(MaskedPixelDisMatrix,[],'all');
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
NormolizedDataTemp = obj.NormolizedDataContainer(:);
SkipIdx = BinTemp == 0;
BinTemp(SkipIdx) = [];
NormolizedDataTemp(SkipIdx) = [];


Intensity = accumarray(BinTemp,NormolizedDataTemp)./N';
Error = accumarray(BinTemp,sqrt(abs(NormolizedDataTemp)))./N';

plot(qAxis,Intensity)
%}