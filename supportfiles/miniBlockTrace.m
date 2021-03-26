% miniBlockTrace
removemixedperiods=0;

rivTrackingData=blockout.rivTrackingData;
Trials= blockout.Trials;
scrRate=params.scrRate;
windowRect=params.windowRect;
%ignore switches that happen in first xstim_s after stimulust presentation

quick=0;
num='practice';
sanitycheckON=0; %refrain from printing,

fontsize=15;

%
skswitch=0;
if blockout.HousePos==1
    Limg = 'House';
    Rimg = 'Face';
else
    Limg='Face';
    Rimg='House';
end

%%

%Prepare the data into easy matrix
Timing = rivTrackingData(:,3);
Timesecs = 1:size(Timing,1)/scrRate;

%Total Exp is difference between button presses.
TotalExp = rivTrackingData(:,2) - rivTrackingData(:, 1);


%remove zeros at start of trial. if button press was late.
if TotalExp(1)==0
    firstvalue=find(TotalExp, 1, 'first'); %finds first nonzero
    for i=1:firstvalue
        TotalExp(i,1)=TotalExp(firstvalue);
    end
end

%remove single frame 'mixed' reponses, as they mess up the calculations
for i = 2:length(TotalExp)-1
    if TotalExp(i)==0
        if TotalExp(i+1)~=0 && TotalExp(i-1)~=0
            TotalExp(i) = TotalExp(i-1);
        end
    end
end
if removemixedperiods==1%remove periods of mixed response
for i =2:length(TotalExp)-1
    if TotalExp(i)==0
        TotalExp(i) = TotalExp(i-1); %removes mixed periods
    end
end
end


%%
% finds 'switch' time points in button press (when changing from left to
% right eye)
if removemixedperiods==0
switchpoint=[];
switchtime=[];
switchFROM=[];
mixed_durationALL=[];

mixedperceptsindx = (find(TotalExp==0)); %whenever both or no buttons pressed
mixedperceptsindx(end+1) = mixedperceptsindx(end)+2; % allows for last if mixed percept not held till end of trial
mixedperceptsdur= diff(mixedperceptsindx); %of all those indexed, how long? (to find middle point of mixed periods)
%
endmixedcounter=1; %start counter
%
endmixedperceptsindx = find(mixedperceptsdur>1);

%%
for iframe = 2:length(Timing)-1 %switch point in frames
    
    if TotalExp(iframe)~= TotalExp(iframe-1) % ie if at two frames don't match perceptually (a switch)
        if TotalExp(iframe)==0 %coming to mixed dominance, so find middle point of zeros
            
            %find the details of this period of mixed dominance.
            startmixedindx = iframe;
            endindxtmp = endmixedperceptsindx(endmixedcounter);
            endindx = mixedperceptsindx(endindxtmp);
            
            mixed_duration = endindx - startmixedindx;
            switchpointtmp= startmixedindx + round(mixed_duration/2);
            endmixedcounter=endmixedcounter+1;
            
            switchFROMp = TotalExp(iframe-1);%= what the person was seeing before they switched
            
            try switchTOp = TotalExp(endindx+1);
            catch
                switchTOp= TotalExp(end);
            end
            
            if switchFROMp ~=switchTOp; %actual swich around zeros not false switch [-1 0 0 0 -1] etc
                
                %should also be a switch which resulted in a long enough
                %change (not quick switch then switch back)
                %thus:
                
                if ~isempty(switchpoint)
                    if (switchpointtmp - (switchpoint(end))) > skswitch; %ie if (newswitch point - the previous) is longer than minimum required.
                        
                        switchFROM = [switchFROM, switchFROMp];
                        switchpoint = [switchpoint switchpointtmp]; %aligns to middle of mixed dom period
                        mixed_durationALL=[ mixed_durationALL, mixed_duration];
                    else
%                         switchpoint(end)=[]; %and if not then remove the previous switchpoitn, since we've captured a 'false'
%                         switchFROM(end) =[];
                    end
                else %its the first switchpoint
                    switchFROM = [switchFROM, switchFROMp];
                    switchpoint = [switchpoint switchpointtmp]; %aligns to middle of mixed dom period
                    mixed_durationALL=[ mixed_durationALL, mixed_duration];
                end
            end
        else %coming out of mixed dominance (which we skip), or a clean switch (rare)
            switchpointtmp = iframe;
            %clean switch
            if TotalExp(iframe) ~=0 && TotalExp(iframe-1)~=0
                if length(switchpoint)>0
                    if(switchpointtmp-(switchpoint(end))) > skswitch
                        switchpoint=[switchpoint, iframe];
                        switchFROM = [switchFROM, TotalExp(iframe-1)];
                        mixed_duration=0;
                        mixed_durationALL=[ mixed_durationALL, mixed_duration];
                    else
                        switchpoint(end)=[];
                        switchFROM(end)=[];
                    end
                else %first switch  (length(switchpoint)=0)
                    switchpoint=[switchpoint, iframe];
                    switchFROM = [switchFROM, TotalExp(iframe-1)];
                    mixed_duration=0;
                    mixed_durationALL=[ mixed_durationALL, mixed_duration];
                end
            end
        end
        
    end
end

if length(switchpoint) ~=length(switchFROM)
    error('count off between switchpoint and switchFROM')
end
else
    switchpoint=[];
switchtime=[];
switchFROM=[];


%%
for iframe = 2:length(Timing)-1 %switch point in frames
    
    if TotalExp(iframe)~= TotalExp(iframe-1) % ie if at two frames don't match perceptually (a switch)
        %coming out of mixed dominance (which we skip), or a clean switch (rare)
        switchpointtmp = iframe;
        %clean switch
        if TotalExp(iframe) ~=0 && TotalExp(iframe-1)~=0
            if length(switchpoint)>0
                if(switchpointtmp-(switchpoint(end))) > skswitch
                    switchpoint=[switchpoint, iframe];
                    switchFROM = [switchFROM, TotalExp(iframe-1)];
                    
                    
                else
                    switchpoint(end)=[];
                    switchFROM(end)=[];
                end
            else %first switch  (length(switchpoint)=0)
                switchpoint=[switchpoint, iframe];
                switchFROM = [switchFROM, TotalExp(iframe-1)];
                
                
            end
        end
        
        
    end
end

if length(switchpoint) ~=length(switchFROM)
    error('count off between switchpoint and switchFROM')
end
end


%%
% sanity check of switch data(zero's removed)
%set a decent size figure
set(0, 'DefaultFigurePosition', [0 0 800 400]);

if sanitycheckON==0
    set(gcf, 'visible', 'off');
end

% subplot(2,2,1:2)
plot(Timing, TotalExp, 'Color', 'k');
ylim([-2 2]);
xlim([0 length(TotalExp)/scrRate])


%% Calculate L/Right dominance
Left_tot = abs(sum(TotalExp(TotalExp==-1)));
Right_tot= sum(TotalExp(TotalExp==1));

L_pct=100*(Left_tot/length(TotalExp));
R_pct=100*(Right_tot/length(TotalExp));

%mean percept dur
m_dur = mean(diff(switchpoint))/scrRate;
% 
% 
% %mean Lefteyedur 
% xl = TotalExp==-1;
% leftdurs=findstr(xl',[0 0]);
% 
% zcnt= (leftdurs(diff([1 leftdurs])~=1))
% xld=diff(find(diff(xl))); %whenever there is a change from 0 to 1. 
% %%
% ldurs=[];
% if xl(1)==1, %then first 'change' was to a percept
%     for i=1:length(xld)
%         if mod(i,2)~=0
%             ldurs=[ldurs,xld(i)]
%         end
%     end
% else
%     for i=1:length(xld)
%         if mod(i,2)==0
%             ldurs=[ldurs,xld(i)]
%         end
%     end
% end
%%
L_pct=sprintf('%.2f', L_pct);
R_pct=sprintf('%.2f', R_pct);
M_dur=(sprintf('%.2f',m_dur)); %plotted in final image.
%%
set(gca, 'yTick', [ -1 1], 'yTickLabel',...
    {[num2str(Limg)];...
    [num2str(Rimg)]},...
    'Fontsize', fontsize);
title([ 'Buttonpress Activity during ' num2str(num)  ], 'fontsize', fontsize*2);
xlabel('Seconds');
%%

%


% check switchpoints correlate
hold on

text(130, -1.5, ['Total switches = ' num2str(length(switchpoint))], 'Fontsize', fontsize*2)


TexttoShow = [Limg ' ' num2str(L_pct) '%, ' Rimg ' ' num2str(R_pct) '% \n\n Mean Duration ' num2str(M_dur) ' secs'];

%%
set(gca,'fontsize', fontsize*2)
shg
F = getframe(gcf);
[X, Map] = frame2im(F);
% Open Screen
%%
% screenPREPs
%
figtoshow=Screen('MakeTexture', params.windowPtr, X);
Screen('TextSize', params.windowPtr,40);

%prepare screen locations:
windowRect=params.windowRect;
imCenter = windowRect/2 ;
imdimensions = size(X)/4;
stimRect = round([(imCenter(3) -imdimensions(2)), (imCenter(4)-imdimensions(1) ), (imCenter(3)+imdimensions(2)), (imCenter(4)+imdimensions(1))]);
%%
for drawLR=0:1
    
    
    % Select left-eye image buffer for drawing:
    Screen('SelectStereoDrawBuffer', params.windowPtr, drawLR);
    imCenter = params.windowRect/2;
    
    
    
    % Drawing the texture
    Screen('DrawTexture',params.windowPtr, figtoshow, [], stimRect)
    
    DrawFormattedText(params.windowPtr, TexttoShow, 'center', [imCenter(4)*.2],  [255 255 255])
   
end
Screen('Flip', params.windowPtr);

%%
KbWait()
pause(2);



