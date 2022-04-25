function EnvConfig = EnvConfiguration()
OSType = GetOSType();
switch OSType
    case 'PC'
        EnvConfig = PCCase();
    case 'UNIX'
        EnvConfig = UNIXCase();
    case 'MAC'
        EnvConfig = MACCase();
end

if ~EnvConfig
    disp('System parameters have been modified.')
    disp('Please restart Matlab.')
    input('Press "Enter" to close Matlab...')
    exit;
end



function EnvConfig = PCCase()
if CheckDLL()
    % H5 DLL OK
    EnvConfig = true;
else
    DLLPATH = fullfile(pwd,'+EigerFunc','H5DLL');
    cmd = sprintf('setx HDF5_PLUGIN_PATH "%s', DLLPATH);
    system(cmd);
    EnvConfig = false;
end

function EnvConfig = UNIXCase()
EnvConfig = true;

function EnvConfig = MACCase()
EnvConfig = true;


function DLLCheckResult = CheckDLL()
DLLMemberList = {'libh5blosc.dll','libh5bz2.dll','libh5lz4.dll','libh5lzf.dll','libh5mafisc.dll','libh5zfp.dll'};
CheckingList = zeros(length(DLLMemberList),1);
Default_HDF5_PLUGIN_PATH = getenv('HDF5_PLUGIN_PATH');
for DLLSN = 1:length(CheckingList)
    DLLFP = fullfile(Default_HDF5_PLUGIN_PATH,DLLMemberList{DLLSN});
    CheckingList(DLLSN) = logical(exist(DLLFP,'file'));
end
DLLCheckResult = all(CheckingList);

function OSType = GetOSType()
if ispc
    OSType = 'PC';
elseif isunix
    OSType = 'UNIX';
elseif ismac
    OSType = 'MAC';
end