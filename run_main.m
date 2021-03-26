% Code to run a basic BR experiment, displaying Faces and Houses on the
% Left and Right side of screen.

%% ----------------------- SETUP parameters -----------
params=[];
params.debugg =1;                %throws a smaller window which doesn't occlude matlab.
params.offscreen=1;              % to work in offscreen screenwindow (dual monitors)
params.nprac = 2;                % n practice trials
params.ntrials = 4;              % n exp trials.(diff Face/House combos)
params.nreps = 2;                % reps per trial above (diff Face/House combos)
                                 % make sure this is a multiple of 2, as
                                 % the face/house eye pos can be balanced.
params.blockduration=120;        % seconds


params.stereoMode = 4;           % on WINDOWS: 4 = for split display (left/ right
                                 % 8   for red blue separate. i.e. for mirrorscope
                                 % 6-9 = for anaglyph glasses (filtering colour).
                                 % Type Screen OpenWindow? for colour options.
                                 
params.display.dist= 55;        % approximate viewing distance (in cm) from screen

params.degVA = 8;               % approx degrees of visual angle for visual stimuli.

%% set up support directories.
basefol = pwd;
addpath([basefol filesep 'supportfiles'])
addpath([basefol filesep 'FaceHouseStim'])

%% design experiment (assign stim to trials).
startupNEW;

%% open Screen. Also preloads Face/House textures.
screenPREPs;

%% preload face/house textures

%% show BR:
for iblock= StartPos:length(params.ExpOrder)
    Run_blocks;
end
sca
