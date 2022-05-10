function Open(obj,MasterFP)
% Enviroment check
obj.EnviromentCheck = Eiger.EnvConfiguration();
if ~obj.EnviromentCheck
    error('Enviroment setting for Eiger files does''t ready.')
end

% create and check file path
[obj.MasterFF,obj.MasterFN,obj.MasterFP] = AnalyzeMasterFP(MasterFP);
% read header from master file
obj.BitDepthImage = double(h5read(MasterFP,'/entry/instrument/detector/bit_depth_image'));
obj.XPixelsInDetector = double(h5read(MasterFP,'/entry/instrument/detector/detectorSpecific/x_pixels_in_detector'));
obj.YPixelsInDetector = double(h5read(MasterFP,'/entry/instrument/detector/detectorSpecific/y_pixels_in_detector'));
obj.CountTime = double(h5read(MasterFP,'/entry/instrument/detector/count_time'));
obj.DetectorDistance = double(h5read(MasterFP,'/entry/instrument/detector/detector_distance')); % [m]
obj.XPixelSize = double(h5read(MasterFP,'/entry/instrument/detector/x_pixel_size')); % [m]
obj.YPixelSize = double(h5read(MasterFP,'/entry/instrument/detector/y_pixel_size')); % [m]
obj.Wavelength = double(h5read(MasterFP,'/entry/instrument/beam/incident_wavelength'))*1E-10; % read as [A], save as [m]
obj.BeamCenterX= double(h5read(MasterFP,'/entry/instrument/detector/beam_center_x'));
obj.BeamCenterY= double(h5read(MasterFP,'/entry/instrument/detector/beam_center_y'));
obj.PixelMask = logical(transpose(h5read(MasterFP,'/entry/instrument/detector/detectorSpecific/pixel_mask')));

% get link file information
temp = h5info(MasterFP,'/entry/data');
NLinks = length(temp.Links); 
for LinkIdx = 1:NLinks
    LinkedFN = temp.Links(LinkIdx).Value{1};
    LinkedFP = fullfile(obj.MasterFF, LinkedFN);
    if exist(LinkedFP,'file')
        obj.Links(LinkIdx).FN = LinkedFN;
        obj.Links(LinkIdx).FF = obj.MasterFF;
        obj.Links(LinkIdx).FP = LinkedFP;
        obj.Links(LinkIdx).Location = temp.Links(LinkIdx).Value{2};
        obj.Links(LinkIdx).ImageNrLow = h5readatt(obj.Links(LinkIdx).FP,obj.Links(LinkIdx).Location,'image_nr_low');
        obj.Links(LinkIdx).ImageNrHigh = h5readatt(obj.Links(LinkIdx).FP,obj.Links(LinkIdx).Location,'image_nr_high');
    else
        break
    end
end

% get total frame num
obj.TotalFrameNum = obj.Links(end).ImageNrHigh;

function [MasterFF,MasterFN,MasterFP] = AnalyzeMasterFP(MasterFP)
[MasterFF,MasterFN,MasterEXT] = fileparts(MasterFP);
MasterFN = [MasterFN MasterEXT];

if isempty(MasterFF)
    MasterFF = pwd;
end

% check file existing
if exist(fullfile(MasterFF,MasterFN),'file')
    MasterFP = fullfile(MasterFF,MasterFN);
else
    fprintf('File %s doesn''t exist.\n',MasterFP)
    MasterFP = [];
    MasterFN = [];
    MasterFF = [];
end