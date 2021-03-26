% ShowInstructions


Screen('TextSize', params.windowPtr, 20);

if iblock==3


for iDrawLR = 0:1
    
    
%>>>>>>>>>>> LEFT EYE
% Select left-eye image buffer for drawing:
Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);

%find center
imCenter = params.windowRect/2;

%Draw the frame in center.
Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);


% Drawing instructions for the user
    DrawFormattedText(params.windowPtr, [ '\n' '\n'...
        'End of Practice Blocks' '\n' 'Press any key when ready'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);
end%>>>>>>>>>>>> SHOW INSTRUCTIONS

Screen('Flip', params.windowPtr);
pause(0.2);
KbWait; %wait till ready.
end

for iDrawLR = 0:1
    
    
%>>>>>>>>>>> LEFT EYE
% Select left-eye image buffer for drawing:
if params.stereoMode~=6
Screen('SelectStereoDrawBuffer', params.windowPtr, iDrawLR);
else
Screen('SelectStereoDrawBuffer', params.windowPtr);
end
%find center
imCenter = params.windowRect/2;

%Draw the frame in center.
Screen('FrameRect', params.windowPtr,[255 255 255], [imCenter(3)- imCenter(3)/1.1, imCenter(4)-imCenter(4)/2, imCenter(3)+ imCenter(3)/1.1, imCenter(4)+imCenter(4)/2], 10);


    DrawFormattedText(params.windowPtr, [ '\n' '\n'...
        'Constantly report your dominant' '\n' 'visual percept using the arrow keys- ' '\n' '\n' 'House = "Left"'  '\n' '\n' 'Face = "Right"'] , 'center', 'center', [255 255 255],50,[],[],[],[],...
        [0 0 params.windowRect(3) params.windowRect(4)]);

end%>>>>>>>>>>>> SHOW INSTRUCTIONS

Screen('Flip', params.windowPtr);
pause(0.2);
KbWait; %wait till ready.
