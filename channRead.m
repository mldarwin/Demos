% ---Function 'channRead'---
% Read in single channel of microwire data from NWB file
% Inputs flexible to specify subject, session, channel, and BasePath
% 
% Channel inputs are 1-8 for MW channels 257-264 respectively
% BasePath is the location of the folder that conatins all patient folders
%     E.g.-> C:\Users\darwinm\Documents\Thompson Lab\Microwire\PatientData\ 
%
% Marielle L. Darwin | October 7 2021


function [MWchannel]=channRead(subjectID,session,channel,BasePath)

% Convert inputs to string variables
session = num2str(session);
subjectID = num2str(subjectID);

% Location of subject folder
subjectFolder = insertAfter(BasePath,length(BasePath),subjectID);

% Recreate NWB file name from input arguments
    % Insert subject ID into file name
    str1 = "_Session__raw.nwb";
    newstr1 = insertBefore(str1,1,subjectID);
    % Insert session number into file name
    str2 = newstr1;
    newStr2 = insertAfter(str2,12,session);

% Location of subject NWB subfolder
filePath = append(subjectFolder, "\NWB_Data");

% Read in NWB
cd(filePath);
mwNWB = nwbRead(newStr2);

% Pop up to browse contents of NWB file
util.nwbTree(mwNWB)

% Extract relevant NWB info
    % Handle for general electrophysiology - both macro and micro
    genEphys = mwNWB.general_extracellular_ephys_electrodes;
    % Handle for data
    vecInfo = genEphys.vectordata;
    % Handle for channel number ID
    channEl = vecInfo.get('channID').data.load();

% Specify channel
MWchannel=channEl(channel);
end