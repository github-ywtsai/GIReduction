function Cartesian2Pole(obj)
% notice: ignore the tilted angle that sample rotate along the sample x axis
if ~isempty(obj.IncidentAngle)
    % case 1: input only incident angle
    InputCase = 'IncidentAngle';
elseif ~isempty(obj.ReflectionCenterX)
    % case 2: input specular center
    InputCase = 'Reflection';
end

switch InputCase
    case 'IncidentAngle'
    % calculate reflection beam center by the sample-detector distance, direction beam center and the incident angle
    VerticalShift = obj.DetectorDistance * atan(2*obj.IncidentAngle);
    VerticalShiftPixel = VerticalShift/obj.YPixelSize;
    obj.ReflectionCenterX = obj.BeamCenterX ;
    obj.ReflectionCenterY = obj.BeamCenterY - VerticalShiftPixel; % Notice: y axis direction
    
    case 'Reflection'
    obj.ReflectionCenterX = obj.BeamCenterX; % notice: ignore the tilted angle that sample rotate along the sample x axis
    VerticalShift  = - (obj.ReflectionCenterY - obj.BeamCenterY) *obj.YPixelSize; % Notice: y axis direction
    obj.IncidentAngle = atan(VerticalShift/obj.DetectorDistance)/2;
    
end
% detemine the O point on the screen
OX = (obj.ReflectionCenterX + obj.BeamCenterX)/2;
OY = (obj.ReflectionCenterY + obj.BeamCenterY)/2;

% create X and Y index matrix
[YIdxMatrix,XIdxMatrix] = find(ones(obj.YPixelsInDetector,obj.XPixelsInDetector));
YIdxMatrix = reshape(YIdxMatrix,obj.YPixelsInDetector,obj.XPixelsInDetector) - 1; % in H5, the original is start from 0,0
XIdxMatrix = reshape(XIdxMatrix,obj.YPixelsInDetector,obj.XPixelsInDetector) - 1;

% create the matries record the pixel distance of x and y to O point
YPixelDistToOMatrix = YIdxMatrix-OY;
XPixelDistToOMatrix = XIdxMatrix-OX;
% create the matries recorded the real distance of x and y to O point
YDistToOMatrix = YPixelDistToOMatrix * obj.YPixelSize;
XDistToOMatrix = XPixelDistToOMatrix * obj.XPixelSize;

% create the matrix record the distacne of the scattering point (sample) to each pixel 
YPixelDistToDBMatrix = YIdxMatrix-obj.BeamCenterY; % to direct beam DB
XPixelDistToDBMatrix = XIdxMatrix-obj.BeamCenterX; % to direct beam DB
YDistToDBMatrix = YPixelDistToDBMatrix * obj.YPixelSize;
XDistToDBMatrix = XPixelDistToDBMatrix * obj.XPixelSize;
DistToDBMatrix = sqrt(XDistToDBMatrix.^2 + YDistToDBMatrix.^2);
DistToSample = sqrt(DistToDBMatrix.^2 + obj.DetectorDistance.^2);

% create 2th matrix defined by Fig.4 Zhang Jiang, J. Appl. Cryst. (2015). 48, 917¡V926
twoth = atan(XDistToOMatrix./obj.DetectorDistance); % singed
twoTh = acos(obj.DetectorDistance./DistToSample); % un signed
% create alpha_f matrix defined by Fig.4 Zhang Jiang, J. Appl. Cryst. (2015). 48, 917¡V926
OToDBDist = sqrt( ((OY - obj.BeamCenterY)*obj.YPixelSize)^2 + ((OX - obj.BeamCenterX)*obj.XPixelSize)^2 );
SampleToODist = sqrt(OToDBDist^2 + obj.DetectorDistance^2);
Temp = sqrt(SampleToODist^2 + XDistToOMatrix.^2);
alphaf = acos ((YDistToOMatrix.^2 - DistToSample.^2 - Temp.^2) ./ (-2 * DistToSample.*Temp)); % un signed
alphaf(YIdxMatrix>OY) = -1*alphaf(YIdxMatrix>OY); % signed

% create NaN ROI
if isempty(obj.UserDefineROI)
    NaNROI = obj.Logical2NaN(obj.DefaultROI);
else
    NaNROI = obj.Logical2NaN(and(obj.DefaultROI,obj.UserDefineROI));
end

% create qz, qx, qy matries and using angstrom as length unit
k = 2*pi/(obj.Wavelength*1E10);
qz = k*sin(alphaf) + k*sin(obj.IncidentAngle);
qx = k*cos(alphaf).*cos(twoth) - k*cos(obj.IncidentAngle);
qy = k*cos(alphaf).*sin(twoth);
qr = sqrt(qx.^2 + qy.^2);
qr(XIdxMatrix<OX) = qr(XIdxMatrix<OX)*-1;

% apply nan mask on qx qy qz qr
qz = qz.* NaNROI;
qx = qx.* NaNROI;
qy = qy.* NaNROI;
qr = qr.* NaNROI;

% re-create qr and qz axis using data reduce ratio
qzmin = min(qz,[],'all');
qzmax = max(qz,[],'all');
qzCen = (qzmax + qzmin)/2;
qzHalfRange = (qzmax - qzmin)/obj.DataReduceRatio/2;
qzmin = qzCen - qzHalfRange;
qzmax = qzCen + qzHalfRange;
qrmin = min(qr,[],'all');
qrmax = max(qr,[],'all');
qrCen = (qrmax + qrmin)/2;
qrHalfRange = (qrmax - qrmin)/obj.DataReduceRatio/2;
qrmin = qrCen - qrHalfRange;
qrmax = qrCen + qrHalfRange;
qzAxis = linspace(qzmin,qzmax,obj.YPixelsInDetector); % extned range and keep pixel number
qrAxis = linspace(qrmin,qrmax,obj.XPixelsInDetector); % extned range and keep pixel number
qzInterval = abs(qzAxis(2) - qzAxis(1));
qrInterval = abs(qrAxis(2) - qrAxis(1));
qzBoundaryList = [qzAxis qzAxis(end)+qzInterval] - qzInterval/2; % make the points on qzAxis at the center of each interval
qrBoundaryList = [qrAxis qrAxis(end)+qrInterval] - qrInterval/2; % make the points on qrAxis at the center of each interval

[N,~,~,BinX,BinY] = histcounts2(qr,qz,qrBoundaryList,qzBoundaryList);
% remove out of range points (such as NaN)
ProcessedImageTemp = obj.ProcessedImage(:);
BinXTemp = BinX(:);
BinYTemp = BinY(:);
SkipPoints = or(BinX == 0, BinY == 0);
ProcessedImageTemp(SkipPoints) = [];
BinXTemp(SkipPoints) = [];
BinYTemp(SkipPoints) = [];

PoleFig = accumarray([BinYTemp,BinXTemp],ProcessedImageTemp,[length(qzAxis),length(qrAxis)])./N';

% rebuid qx qz matrix
[qrMatrix, qzMatrix]  = meshgrid(qrAxis,qzAxis);

% assign value to obj
obj.PoleData = PoleFig;
obj.qrMap = qrMatrix;
obj.qzMap = qzMatrix;
obj.PoleqrAxis = qrAxis;
obj.PoleqzAxis = qzAxis;
obj.CartesianData = obj.ProcessedImage .* NaNROI;



