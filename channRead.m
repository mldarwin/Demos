% ---Function 'channRead'---
% Read in single channel of unfiltered NLX data from NWB file
% 
% channel input = 1-8 for MW channels 257-264 respectively
% basePath input = location of the folder that conatins all patient folders
% wireType input = 1 for macro data, 2 for micro data
% 
% Example inputs: 
% subjectID='MW5';
% session='3';
% channel=1;
% basePath='C:\Users\darwinm\Documents\Thompson Lab\Microwire\PatientData\';
% wireType=1;
% Marielle L. Darwin | October 7 2021 | Last revision: November 18 2021

function [MWchannel, Fs, channelData, refTS] = channRead(subjectID, ...
    session, channel, basePath, wireType)

% Location of subject folder
subjectFolder = insertAfter(basePath,length(basePath),subjectID);

% Recreate NWB file name from input arguments
    % Insert subject ID into file name
    str1 = "_Session__raw.nwb";
    newstr1 = insertBefore(str1,1,subjectID);
    % Insert session number into file name
    str2 = newstr1;
    newStr2 = insertAfter(str2,12,session);

% Location of subject NWB subfolder
filePath = append(subjectFolder,"\NWB_Data");

% Read in NWB
cd(filePath);
mwNWB = nwbRead(newStr2);

% Pop up to browse contents of NWB file
%util.nwbTree(mwNWB)

% Extract relevant NWB info
    % Handle for general electrophysiology - both macro and micro
    genEphys = mwNWB.general_extracellular_ephys_electrodes;
    % Handle for data
    vecInfo = genEphys.vectordata;
    % Handle for channel number ID
    channEl = vecInfo.get('channID').data.load();
    % Handle for timestamps
    refTS = mwNWB.timestamps_reference_time;

% Specify channel number
MWchannel=channEl(channel);

% Sampling frequency
    % Access the struct names in the NWB acquisition field 
    unit_names = keys(mwNWB.acquisition);
    mwireData = mwNWB.acquisition.get(unit_names{wireType});
    
Fs = mwireData.starting_time_rate;

% Extract channel data
    % Extract vector of data
    ALLchannelData = mwireData.data.load();

    % Extract data from channel of interest
    channelData = ALLchannelData(channel,:);
end