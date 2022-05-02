% ---Function 'volBrain'---
% 
% Localize SEEG electrode contact to specific brain region
%
% Inputs: 1) Patient ID, 2) Contact of interest
% Example: volBrain('STMP83', 603)
%
% Outputs: elecContact = a table with:
% contact #, brain regions contact is in, hemispheres, & matter type
%
% Marielle L. Darwin | Lisa Hirt | John A. Thompson | April 29 2022

function [elecContact] = volBrain(patientID, contactNum)

% Set path structure
paths=[];
uiwait(msgbox('Navigate to and select CaseData folder'))
paths.basePath = uigetdir;
paths.path_patientID = [strcat(paths.basePath,'\',patientID,'\')];
paths.path_FinalProc = [strcat(paths.path_patientID,'FinalProc\')];
paths.path_volBrain = [strcat(paths.path_FinalProc,'volBrain\')];
    
% Locate and read in ESeg NIFTI w/ electrode location (STMP##_CT_ESeg)
cd(paths.path_FinalProc);
buildEseg_file = strcat(patientID,'_CT_ESeg.nii');
Eseg = niftiread(convertCharsToStrings(buildEseg_file)); % Read in file

% Locate and read in native structures NIFTI 
cd(paths.path_volBrain); 
volBrain_dir = dir(paths.path_volBrain); % Returns all the files and folders in the directory
volBrain_files = {volBrain_dir.name};    % Extract names of files in folder
find_nativeStructures = ...              % Find native structures file
    volBrain_files(contains(volBrain_files,'native_structures'));
nativeStructures = find_nativeStructures{1};   % Extract from cell array
nBrainArea_temp = niftiread(nativeStructures); % Read in file
nBrainArea = uint16(nBrainArea_temp);

% Find how many unique electrodes there are
% elecElements = unique(Eseg);
% elecElements(1,:) = []; % Deletes the 0 in the column

% Select contact of interest 
elecNum = false(size(Eseg));
elecNum(Eseg == contactNum) = 1;

% Index contact of interest into brain area to see where contact is located 
findContact = nBrainArea(elecNum); 
contactLocations = unique(findContact);

% Read in volBrain key and convert to cell array
volBrain_key_table = readtable('volBrain_region_key.csv');
volBrain_key = table2cell(volBrain_key_table);

% Isolate 1st column in volBrain_key_table and convert to double    
keyLabel = cell2mat(volBrain_key(:,1));

% Create # of contactLoc variables and extract metadata from key for each
lenGth = length(contactLocations);
C = [];
for i=1:lenGth
     contactLoc = double(contactLocations(i));  % Convert uint64 value of contactLocation to double
     
     % Match contactLoc with brain region name      
         % Find row/col in keyLabel with value of contactLoc    
         [row,col] = find(keyLabel==contactLoc); 
         % keyName is 1 column to the right of keyLabel in volBrain_key
         keyName = volBrain_key(row,col+1);
     
     % Extract hemisphere and white/gray matter from volBrain_key
     keyHemi = volBrain_key(row,col+2);      
     keyMatter = volBrain_key(row,col+3);
     
     % Store in an array that grows after each iteration to make into the table
     C = [C,contactNum, keyName, keyHemi, keyMatter];
end

% Table with output: contact #, brain area, hemi, & matter type
elecContact_cell = (reshape(C,4,lenGth))';
elecContact = cell2table(elecContact_cell,"VariableNames",...
    ["Contact number" "Brain region" "Hemisphere" "White or gray matter"]);
end