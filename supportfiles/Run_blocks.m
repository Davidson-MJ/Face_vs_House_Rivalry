%Load and run the parameters for each block.


%%
ShowInstructions %different instructions based on the AttendEXP ver



% perform stimulus  presentation, collect button press data.
[blockout] = run_FaceHouseblock(params, FaceTex, HouseTex, iblock);

%% check user accuracy and present block outline on screen for practice trials.
if iblock<=params.nprac 
    
    miniBlockTrace
    %%    
end

%% save data.
    cd(params.savedatadir)
    cd(params.namedir)

% Specifies the file name for rest of data save
%%
filename = ['Block' num2str(iblock)];
% Saves all the data as a .mat file
save(filename, 'blockout', 'params');

%%
% Flip to Grey screen.
try   Screen('Flip', params.windowPtr);
catch
    screenPREPs
end