% script to create visual flicker gratings based on pre-determined contrast
% values.


%% Generate visual stimulus

% Set up flicker params
scrRate = Screen('NominalFrameRate',params.windowPtr); %Different monitors have different rates
windowRect=params.windowRect;
if ~scrRate
    error( ['NO frame rate recorded, likely problem is that you have moved',...
        '\n Matlab from one screen to another, after running the first script \n or are running on MAC OSX']);
end
%

imSize= angle2pix(params.display, params.degVA);   % convert angles 2 pixels.


if mod(imSize,2)==1; % odd number will throw errors
    imSize=imSize+1;
end
% imSize = 240; % Image size (pixels)

wvlengthsperimage = 4;                          % how many cycles in image?;
gratingLambda = ceil(imSize/wvlengthsperimage); % Affects the grating calcs / cpd

% duration = 60; % Length of calibration block (in seconds)


% cos mask to soften edges of the grating:
nCosStepsMask =20;
% nCosStepsMask = 200;
rcm = makeRaisedCosineMask(imSize,  nCosStepsMask, imSize ,imSize );
raisedCosMask = repmat(rcm, [1,1,3]);

% make a vertical and a horizontal grating
% oriV = pi/2; % Vertical
oriV=pi/2+pi/4; %-45;
grat_neg = makeCosineGrating(imSize,oriV,gratingLambda); % This output is a vertical grate

oriH = pi/2-pi/4; %+45;
grat_pos = makeCosineGrating(imSize,oriH,gratingLambda); % This output is a horizontal grate
%noramlize both (0 - 1);
grat_neg = grat_neg + abs(min(min(grat_neg)));
grat_pos = grat_pos + abs(min(min(grat_pos)));

%%
% Picking left or right for speed
% force red colour (left eye), to be low flicker, if anaglyph mode.
if params.stereoMode==4
switch Speed
    case 'H'
        FreqLeft = params.FreqHigh; FreqRight = params.FreqLow;
    case 'L'
        FreqLeft = params.FreqLow; FreqRight = params.FreqHigh;
end

else
    % 
     FreqLeft = params.FreqLow; FreqRight = params.FreqHigh;
    
end
    



%% define the sinusoidal modulator
tspan1 = 0:scrRate*FreqLeft/FreqLeft-1;
tspan2 = 0:scrRate*FreqRight/FreqRight-1;

% Modulating vectors
amLeft = sin(2*pi*tspan1*FreqLeft/scrRate - pi/2) * 0.5 + 0.5;
[~, lngth]= find(amLeft==0, 1, 'last'); %finds nearest full wavelength to a full second
amLeft= amLeft(1:lngth-1);

amRight = sin(2*pi*tspan2*FreqRight/scrRate - pi/2) * 0.5 + 0.5;
[~, lngth]= find(amRight==0, 1, 'last'); %finds nearest full wavelength to a full second
amRight= amRight(1:lngth-1);
%we want to use a full wavelength, to avoid slipping.
%%
% Colour creation
RGBmat = zeros(imSize,imSize,3);
red_neg = RGBmat;
red_neg(:,:,1) = grat_neg*255;
red_pos=RGBmat;
red_pos(:,:,1)=grat_pos*255;

%use green for stereomode 4, otherwise we need blue pictures
if params.stereoMode==4
green_neg = RGBmat;
green_neg(:,:,2) = grat_neg*255;
green_pos = RGBmat;
green_pos(:,:,2) = grat_pos *255;

else % make 'green' actually blue.
    green_neg = RGBmat;
green_neg(:,:,2) = grat_neg*255;
green_pos = RGBmat;
green_pos(:,:,2) = grat_pos *255;
end
    


%% %% multiply colour output by a certain contrast value
green_pos=green_pos*GreenMulti;
green_neg=green_neg*GreenMulti;

red_pos=red_pos*RedMulti;
red_neg=red_neg*RedMulti;
%% %%
% Picking from given values
%randomize Orientation;

switch Colour
    case 'R'
        if strcmp(Orien,'-45')
            Lcol = red_neg; Rcol = green_pos;
        else
            Lcol = red_pos; Rcol = green_neg;
        end
    case 'G'
        if strcmp(Orien,'-45')
            Lcol = green_neg; Rcol = red_pos;
        else
            Lcol = green_pos; Rcol = red_neg;
        end
end

% if steremode ~=4, we need to set the right colour to match the gain.
if params.stereoMode ==8  % red(left eye) blue (right eye).
     Lcol = red_neg; Rcol = green_pos;
elseif params.stereoMode ==9
     Lcol = green_neg; Rcol = red_pos;
end
%

%% Diode imaging
% makeDiode
% Rects for diode stimuli on LHS:
diodeImSize = 100;
diodeStimRect = [ 0 0 diodeImSize diodeImSize ];
diodeMVrectL = [ 0, 0, diodeImSize, diodeImSize];
% diodeMVrectR = [ windowRect(3)-diodeImSize, windowRect(4)-diodeImSize, windowRect(3), windowRect(4)];
diodeMVrectR = [ 0, windowRect(4)-diodeImSize, diodeImSize, windowRect(4)];


% Colours for diodes
RGBmat = zeros(diodeImSize,diodeImSize,3);
redDiodeIm = RGBmat;
redDiodeIm(:,:,1) = 255; %entire R dimension is opaque
greenDiodeIm = RGBmat;
greenDiodeIm(:,:,2) = 255; %entire green.

% Picking from given values, for diode
switch Colour
    case 'R'
        LDiode = redDiodeIm; RDiode = greenDiodeIm;
    case 'G'
        LDiode = greenDiodeIm; RDiode = redDiodeIm;
end

%%
%create texture handles ahead of time.
for i = 1:length(amLeft)
    % Makes the frames ahead of time
    textureis= Lcol .* raisedCosMask * amLeft(i);
    
    gratTex1(i)= Screen('MakeTexture', params.windowPtr, textureis);
    
end


for i = 1:length(amRight)
    gratTex2(i) = Screen('MakeTexture', params.windowPtr, Rcol .* raisedCosMask * amRight(i) );
end






% %free up memory as we go
clearvars greenH greenV redH redV tspan1 tspan2
