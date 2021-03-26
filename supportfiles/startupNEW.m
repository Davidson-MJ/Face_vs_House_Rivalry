% Code that just makes everything in the directory accessible

if ~exist('basefol', 'var')
    basefol=pwd;
    addpath(basefol)
end

%%
%add path for saved data
cd(basefol);
try cd('OutputData_FaceHouseEXP')
catch
    cd(basefol);
    mkdir('OutputData_FaceHouseEXP')
    cd('OutputData_FaceHouseEXP')
end

params.savedatadir = pwd;

%% key responses.
KbName('UnifyKeyNames')
    params.keyLeft = KbName('LeftArrow'); % windows OS
    params.keyRight= KbName('RightArrow');

    
%% check for previous participant information.
savedstartNEW           %checks for participant info, incase we crashed.


