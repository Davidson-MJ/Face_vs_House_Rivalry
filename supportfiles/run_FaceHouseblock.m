function [blockout] = run_FaceHouseblock(params, FaceTex, HouseTex, iblock)
dbstop if error
%Shows the binocular rivalry images over an entire block, with
%Audio/Tactile output if needed.

%% Text code
% needed for DrawFormattedText with Exp.winRect ... otherwise text is not drawn
global ptb_drawformattedtext_disableClipping;
ptb_drawformattedtext_disableClipping=1;

%% Trial making
% Creates the trial order for all stim types (including vis only).

HousePos = params.ExpOrder(iblock,2); % 1,2 for left and right

if HousePos==1
    LEFTtexture = HouseTex(iblock);
    RIGHTtexture = FaceTex(iblock);
else
    LEFTtexture = FaceTex(iblock);
    RIGHTtexture = HouseTex(iblock);
end

duration = params.blockduration; % Length of block (in seconds)
Trials = zeros(1, duration*params.scrRate); 

% Prepares for tracking of data
rivTrackingData = NaN(length(Trials),3);

%prepare screen locations:
windowRect=params.windowRect;
imCenter = windowRect/2 ;

%adjust centre position slightly to avoid after effects:
if mod(iblock,2)==0
    shiftImage = ceil(10*rand()); %10 pixel max
    % which direction to move?
    directionmv = randi(4); %4 diagonal directions.
    switch directionmv
        case 1 %diagonal upleft.
            imCenter= [imCenter(1), imCenter(2), (imCenter(3) -shiftImage), (imCenter(4)-shiftImage)]; %[00--]
        case 2 %diagonal upRight
            imCenter= [imCenter(1), imCenter(2), (imCenter(3) +shiftImage), (imCenter(4)-shiftImage)]; %[00+-]
        case 3 %diagonal downleft
            imCenter= [imCenter(1), imCenter(2), (imCenter(3) -shiftImage), (imCenter(4)+shiftImage)]; %[00-+]
        case 4 % diagonal down Right
            imCenter= [imCenter(1), imCenter(2), (imCenter(3) +shiftImage), (imCenter(4)+shiftImage)]; %[00+]
    end
end


%For the images, define their location. Note that they are 500x400
%originally, so preserve this ratio. on the Y axis.
% i.e. [ImSizeY, ImSizeX] =[ImSize, ImSize*.8]
params.imSizeX=params.imSize*.8;

stimRect = round([(imCenter(3) -params.imSizeX/2), (imCenter(4)-params.imSize/2 ), (imCenter(3)+params.imSizeX/2), (imCenter(4)+params.imSize/2)]);
frameRect=stimRect +[-10, -10, 10, 10];


%%
% if stereomode~=6
for drawLR=0:1
    Screen('TextSize', params.windowPtr, 20);
    
    
    
    switch drawLR
        case 0 %LHS
            
            texturetodraw=LEFTtexture;
           
        case 1 %RHS
            texturetodraw=RIGHTtexture;
            
            
    end
    
    
    %DRAW on both sides of screen.
    
    % Select appropriate-eye image buffer for drawing:
    
    if params.stereoMode==4
        Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
    else
        Screen('SelectStereoDrawBuffer', params.windowPtr);
    end
    
    %
    
    % Drawing the texture
    Screen('DrawTexture', params.windowPtr, texturetodraw,[], stimRect);%
    
    %     Screen('Flip', params.windowPtr)
    %    %
    %Draw the frame
    Screen('FrameRect', params.windowPtr,[255 255 255], frameRect, 10);
    
    
    % Drawing instructions for the user
    DrawFormattedText(params.windowPtr, ['Align stereoscope. \n \n Press any key when ready. \n \n  Block ' num2str(iblock)  '\n'],...
        'center', 'center', [255 255 255],15,[],[],[],[],...
        [0 0 windowRect(3) windowRect(4)+windowRect(4)/2]);
%     
%     if params.drawfixcross
%         %Draw Fix cross
%         drawFixCross(params.windowPtr,windowRect(3)/2,windowRect(4)/2);
%     end
    
%     %Draw arrows
    Screen('TextSize', params.windowPtr, 60);
    switch drawLR
        case 0
            DrawFormattedText(params.windowPtr, 'H \n<', 'center', 'center', [255 255 255],[],[],[],[],[],...
                [0 0 windowRect(3)-(params.imSize*1.4) windowRect(4)]);
        case 1
            DrawFormattedText(params.windowPtr, 'F \n>', 'center', 'center', [255 255 255],[],[],[],[],[],...
                [0 0 windowRect(3)+(params.imSize*1.4) windowRect(4)]);
    end
    
end


Screen('Flip', params.windowPtr);
pause(0.2);
KbWait;



% Preparing for timing
InitialTime = GetSecs;
iTest = -1;


%%
while 1
    % Calculates the current frame, ignoring frames if they lag.
    i = ceil( (GetSecs - InitialTime) * params.scrRate );
    
    % Breaks if we finished
    if i > length(Trials)
        % Just in case final frame is not recorded, because that would
        % break the frame fixing function
        if isnan(rivTrackingData(end, 3))
            rivTrackingData(end, :) = [1, 0, GetSecs - InitialTime];
        end
        break
    end
    
    % Waits for the next frame if we are getting ahead of ourselves
    if i == iTest
        pause(((i+1)/params.scrRate) - GetSecs);
        i = i + 1;
    end
    
    iTest = i;
        
    %% Drawing the stimuli each Frame:
    
    for drawLR=0:1
        % Changes the size of the text
        Screen('TextSize', params.windowPtr,60);
        
        if drawLR==0
            texturetodraw = LEFTtexture;
        else
            texturetodraw = RIGHTtexture;
        end
        
        % Select left-eye image buffer for drawing:
        Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
        
        
        %Draw the frame
        Screen('FrameRect', params.windowPtr,[255 255 255],frameRect, 10);
        
        % Drawing the texture
        Screen('DrawTexture', params.windowPtr, texturetodraw,[], stimRect);%
        
        
%         if params.drawfixcross
%             %     % Only if you want a cross in the circles
%             drawFixCross(params.windowPtr,windowRect(3)/2,windowRect(4)/2);
%         end
           %Draw arrows
           Screen('TextSize', params.windowPtr, 60);
           switch drawLR
               case 0
                   DrawFormattedText(params.windowPtr, 'H \n<', 'center', 'center', [255 255 255],[],[],[],[],[],...
                       [0 0 windowRect(3)-(params.imSize*1.4) windowRect(4)]);
               case 1
                   DrawFormattedText(params.windowPtr, 'F \n>', 'center', 'center', [255 255 255],[],[],[],[],[],...
                       [0 0 windowRect(3)+(params.imSize*1.4) windowRect(4)]);
           end
           
    end
    
    
    %% Draw Text of the time elapsed (to catch crashes).
    progress=round((GetSecs - InitialTime),1);
    Screen('TextSize', params.windowPtr, 20);
    DrawFormattedText(params.windowPtr, num2str(progress), [] ,[], [255 255 255]);
    
    Screen('Flip', params.windowPtr);
     
    %% Time and recording of data
    % Tracks the time from the start and now, which'll be given in seconds
    % (accurate to milliseconds)
    rivTrackingData(i,3) = GetSecs-InitialTime;
    
    
    % collect key press data frame by frame
    [~,~,keys] = KbCheck;
    
    
    %ensures that first column is House data
    
    if HousePos == 1 % Same direction as arrows
        rivTrackingData(i,1:2) = [ keys(params.keyLeft) keys(params.keyRight) ]; % 80 & 79 are Left & Right arrows respectively (37 and 39 for windows)
        
    else % Opposite directions
        rivTrackingData(i,1:2) = [ keys(params.keyRight) keys(params.keyLeft) ]; % 80 & 79 are Left & Right arrows respectively
        
    end
    
end
%% Frame fixes
% Fixes missing frames by interpolating values for the time, and assuming
% that the user has not changed anything within those frames.

% Initialises the while loop

i=0;

while 1
    i = i + 1; % Next one
    
    % Ends the while loop for the end of the vector
    if i > length(rivTrackingData(:,3))
        break
    end
    
    % Replaces values if current value is NaN
    if isnan(rivTrackingData(i,3))
        
        % First time value
        t0 = rivTrackingData(i - 1, 3);
        
        % First i position
        iMark = i - 1;
        
        % Finds consecutive NaNs and fixes them
        while 1
            
            i = i + 1;
            
            % Starts the replacing when it finds a non-NaN value
            if ~isnan(rivTrackingData(i,3))
                Frames = i-iMark; % Finds the number of Frames in between
                t1 = rivTrackingData(i,3); % Second time value
                gap = (t1 - t0)/Frames; % The time gaps
                
                % Replaces all values
                for a = 1:Frames - 1
                    rivTrackingData(iMark + a,3) = ...
                        rivTrackingData(iMark + a - 1,3) + gap;
                    rivTrackingData(iMark + a,1:2) = ...
                        rivTrackingData(iMark + a - 1,1:2);
                end
                % Finally, breaks the entire loop
                break
            end
        end
    end
    
end




%%
% Changes the size of the text back to small
Screen('TextSize', params.windowPtr,20);


%% store output in structure
blockout.rivTrackingData= rivTrackingData;
blockout.Trials = Trials;
blockout.scrRate =params.scrRate;
blockout.HousePos = HousePos;
blockout.ExpOrder = params.ExpOrder;
blockout.FaceHouseSet= params.ExpOrder(iblock,1);

if iblock <= params.nprac
blockout.isprac = 1;
else
blockout.isprac = 0;
end
% Deletes textures
%  Screen('Close');
%
% Screen('Close');
%Screen('CloseAll');
