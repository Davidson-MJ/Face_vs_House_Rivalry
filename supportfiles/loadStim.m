
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

%% %%
%create texture handles ahead of time.
[FaceTex, HouseTex]=deal(zeros(size(params.ExpOrder,1),1));

StimIndex = params.ExpOrder(:,1);
for i = 1:length(StimIndex)
    fol = StimIndex(i);
    cd([basefol filesep 'FaceHouseStim'])    
    % Makes the frames ahead of time
    cd(num2str(fol))
    
    FaceIM= imread([pwd filesep 'f1.jpg']);
    HouseIM= imread([pwd filesep 'h1.jpg']);
%     FaceIM= imread([pwd filesep 'f2.jpg'])
%     HouseIM= imread([pwd filesep 'h2.jpg'])
    
    %images should be the same size already.(500x400)
    FaceTex(i) = Screen('MakeTexture', params.windowPtr, FaceIM);
    HouseTex(i) = Screen('MakeTexture', params.windowPtr, HouseIM);
    
end


imSize= angle2pix(params.display, params.degVA);   % convert angles 2 pixels.
if mod(imSize,2)==1 % odd number will throw errors
    imSize=imSize+1;
end
params.imSize=imSize;
