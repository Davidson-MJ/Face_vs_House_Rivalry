% screenPREPs
AssertOpenGL;

%note that if this is a windows or a MAC machine, then the PTB inputs need
%to be updated:

%determine OSX, if Mac and trying to run in stereoMode, update.

if strcmp(computer, 'MACI64') 
    Screen('Preference', 'SkipSyncTests',1)
    % new versions of MAC are unsupported by PTB, and will always error,
% e.g. see: https://github.com/Psychtoolbox-3/Psychtoolbox-3/issues/480
    
end


%%
if params.offscreen==0
scrnNum= min(Screen('Screens')); % Gives the native monitor's number
else
 scrnNum = max(Screen('Screens')); % Gives the external monitor's number
end

%% as part of screen reps, define dimensions, so that we can compute stimulus
%dimensions in degrees of visual angle.

screenparams = Screen('Resolution', scrnNum);
screct = [0,0, screenparams.width, screenparams.height];

params.display.resolution = screenparams.width; % this is alternate formulation for a later function (angle2pix).

%also extract physical screen width (in cm)
[width_mm, height_mm]= Screen('DisplaySize', scrnNum) ; % real size in MM
params.display.width = width_mm /10; % convert to cm (for angle2pix).  

%% open  PTB screen 

if params.debugg==1 %open smaller window.
windowsize_debug = [screct(3)*.05, screct(4)*.05 screct(3)*.6, screct(4)*.6];
else
    windowsize_debug = [0 0 screct(3), screct(4)];
end
   
if params.stereoMode==4
   %open window.
[params.windowPtr, params.windowRect]=Screen('OpenWindow', scrnNum, GrayIndex(scrnNum), ...
    [windowsize_debug], [], [], params.stereoMode);
else % enable imaging, which is much more robust for anaglyph demos:
    
    PsychImaging('PrepareConfiguration');
   
    % note now the change in function, same syntax though.   
[params.windowPtr, params.windowRect]= PsychImaging('OpenWindow', scrnNum, GrayIndex(scrnNum), ...
    [windowsize_debug], [], [], params.stereoMode);

% Set color gains. This depends on the anaglyph mode selected. The
% values set here as default need to be fine-tuned for any specific
% combination of display device, color filter glasses and (probably)
% lighting conditions and subject. The current settings do ok on a
% MacBookPro flat panel.
switch params.stereoMode
    case 6 % red green
        SetAnaglyphStereoParameters('LeftGains', params.windowPtr,  [1.0 0.0 0.0]);
        SetAnaglyphStereoParameters('RightGains', params.windowPtr, [0.0 0.6 0.0]);
    case 7 % green-red
        SetAnaglyphStereoParameters('LeftGains', params.windowPtr,  [0.0 0.6 0.0]);
        SetAnaglyphStereoParameters('RightGains', params.windowPtr, [1.0 0.0 0.0]);
    case 8 %red blue
%         SetAnaglyphStereoParameters('LeftGains', params.windowPtr, [0.4 0.0 0.0]);
%         SetAnaglyphStereoParameters('RightGains', params.windowPtr, [0.0 0.2 0.7]);
      SetAnaglyphStereoParameters('LeftGains', params.windowPtr, [1.4 0 0]);
        SetAnaglyphStereoParameters('RightGains', params.windowPtr, [0 .5 1]);
    case 9 %blue red
%         SetAnaglyphStereoParameters('LeftGains', params.windowPtr, [0.0 0.2 0.7]);
%         SetAnaglyphStereoParameters('RightGains', params.windowPtr, [0.4 0.0 0.0]);
        SetAnaglyphStereoParameters('LeftGains', params.windowPtr, [0 0 1]);
        SetAnaglyphStereoParameters('RightGains', params.windowPtr, [.4 0 0]);
                

    otherwise
        error('Unknown stereoMode specified.');
end
%set up antialiasing function for smooth blending.
Screen('BlendFunction', params.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

end
    
    



% Show a cleared screen to user.
params.ifi=Screen('GetFlipInterval', params.windowPtr);
Screen('Flip', params.windowPtr);

scrRate = Screen('FrameRate',params.windowPtr); %Different monitors have different rates

params.scrRate=scrRate;


%% also Load Stim each time the screen is reopened.
loadStim;