function ReadFrame(obj,FrameReqList)
% check FrameReqList
FrameReqList(FrameReqList < 1) = [];
FrameReqList(FrameReqList > obj.TotalFrameNum) = [];

ReqNum = length(FrameReqList);
RawImage = nan(obj.YPixelsInDetector,obj.XPixelsInDetector,ReqNum);

for Idx = 1:ReqNum
    SingleFrameReqSN = FrameReqList(Idx);
    RawImage(:,:,Idx) = ReadSingleFrame(obj,SingleFrameReqSN);
end

obj.RawImage = RawImage;
obj.FrameSN = FrameReqList;

% normalize data
obj.ProcessedSheetNum = size(obj.RawImage,3);
obj.ProcessedImage = sum(obj.RawImage,3)/obj.ProcessedSheetNum/obj.CountTime;

function SingleFrameData = ReadSingleFrame(obj,FrameSN)
% ruturn UINT32 format

% check master file pointing
if isempty(obj.MasterFP)
    error('Open a master file before read frame data.')
end


NLinkFile = length(obj.Links);
FrameSNinLinkFile = [];
for LinkFileSN = 1:NLinkFile
    if and(FrameSN >= obj.Links(LinkFileSN).ImageNrLow, FrameSN <= obj.Links(LinkFileSN).ImageNrHigh)
        FrameSNinLinkFile = double(FrameSN - obj.Links(LinkFileSN).ImageNrLow + 1);
        % get LinkFileSN and FrameSNinLinkFile
        break
    end
end

% Request SN out of range
if isempty(FrameSNinLinkFile)
    disp('Request frame out of range.')
    SingleFrameData = []; % return empty when require frame out of range
    return
end


SingleFrameData = h5read(obj.Links(LinkFileSN).FP,obj.Links(LinkFileSN).Location,[1,1,FrameSNinLinkFile],[obj.XPixelsInDetector,obj.YPixelsInDetector,1]);
SingleFrameData = transpose(SingleFrameData);