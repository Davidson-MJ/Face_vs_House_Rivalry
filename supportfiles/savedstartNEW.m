
%% This was only added in to add robustness, if the user had to restart
% the program due to problems with EEG (OR THE PROGRAM DYING)

SaveOrNot = upper(input('Do you want to use the previous experiment order? (Y/N): ', 's'));

if SaveOrNot == 'N'
    clc;
    % Getting their name
    params.Initials = upper(input('Subject Initials: ', 's'));    
    % initializing the random seed
    Date = clock;
    seed = round(sum(Date));
    rng(seed, 'v4');
    
    
    %% Creating the random permutations
    % we have different blocks in this design. 
    
    assert(mod(params.nreps,2) ==0, ['Warning! params.nreps should be a ',...
    'multiple of 2, to balance Face and House eye locations'])
    
    nblocks = params.ntrials*params.nreps + params.nprac;
    
    Exps = zeros(nblocks, 2);
    
    %% now define the block order for this experiment.
    Blocksets=repmat([1:params.ntrials]',1,params.nreps);
    
    % Defining each situation
    ExpsNEW=[]; 
for irow = 1:size(Blocksets,1)
    %%
    newpair =Blocksets(irow,:)'; 
    tmp=randperm(params.nreps);
    newpair(:,2)=tmp; %
    
    
    %% add for storage. 
    ExpsNEW=[ExpsNEW;newpair]; %concatenate (in order).
end
%%
%add extra column to randomize.
tmp = randperm(size(ExpsNEW,1))';
ExpsNEW(:,3)=tmp;
%sort according to this new column
tmp = sortrows(ExpsNEW,3);
ExpsNEW=tmp(:,1:2);

%% Save experiment order
% practice trials:
paramsets=repmat(10,params.nprac,params.nprac);
paramsets(:,2) = 1;

Exps = [paramsets; ExpsNEW];

%%
params.ExpOrder=Exps;

cd(params.savedatadir)
   
    
    % Names the subject's folder
    params.namedir = [params.Initials '_On_' num2str(Date(3)) '-' num2str(Date(2))];
    
    %since this is a new ppant,
    mkdir(num2str(params.namedir))
    
    cd(params.namedir); % Saving the Seed and Date
    save('Seed_Data', 'seed', 'Date', 'params', 'Exps');
    cd ../
end

%% Checks whether the user wants to start from another position
StartPos = 1; % Default starting position is from the first block.

if SaveOrNot == 'Y' % Checks if we need to start from a different position
    params.Initials = upper(input('Subject Initials: ', 's'));  
    % initializing the random seed
    Date = clock;
  
    
    cd(params.savedatadir)
    params.namedir = [params.Initials '_On_' num2str(Date(3)) '-' num2str(Date(2))];
    cd(params.namedir)
    load('Seed_Data', 'params', 'Exps');
    disp(Exps);
    % Hopefully, you can read which position you were on before it died.
    StartPos = input('From which block position do you wish to start from?: ');
    
    
end

