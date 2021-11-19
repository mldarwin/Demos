% ---Function 'channRead_filtered'---
% Read in single channel of filtered NLX data from NWB file
% 
% channel input = 1-8 for MW channels 257-264 respectively
% basePath input = location of the folder that conatins all patient folders
% wireType input = 1 for macro data, 2 for micro data
% 
% Example inputs: 
% subjectID='MW4';
% session='3';
% channel=1;
% basePath='C:\Users\darwinm\Documents\Thompson Lab\Microwire\PatientData\';
% wireType=1;
% Marielle L. Darwin | November 18 2021

function [behavior, refTS, MWchannel, NLXdata, channelData, NLX_TS, Fs] = ...
    channRead_filtered(subjectID, session, channel, basePath, wireType)

% Location of subject folder
subjectFolder = insertAfter(basePath,length(basePath),subjectID);

% Recreate NWB file name from input arguments
    % Insert subject ID into file name
    str1 = "_Session__filter.nwb";
    newstr1 = insertBefore(str1,1,subjectID);
    % Insert session number into file name
    str2 = newstr1;
    newStr2 = insertAfter(str2,12,session);

% Location of subject NWB subfolder
filePath = append(subjectFolder,"\NWB_Data");

% Load behavioral event file 
behavior = load(uigetfile(subjectFolder, 'Select behavioral data file'));

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
    % Handle for timestamps
    refTS = mwNWB.timestamps_reference_time;
    % Timestamps of behavioral data per trial
    behaviorTS = mwNWB.acquisition.get('events').timestamps.load();

% Indicate channel number
MWchannel=channEl(channel);

% Access struct names to determine wire type 
unit_names = keys(mwNWB.processing. ...
        get('ecephys').nwbdatainterface.get('LFP'). ...
        electricalseries);    
    
% NLX timestamps
    % Extract vector of data
    NLXdata = mwNWB.processing. ...
        get('ecephys').nwbdatainterface.get('LFP'). ...
        electricalseries.get(unit_names{wireType}).data.load;
    
    % Extract data from channel of interest
    channelData = NLXdata(channel,:);
   
    % Timestamps and Fs for NLX data
    NLX_TS = mwNWB.processing.get('ecephys'). ...
        nwbdatainterface.get('LFP').electricalseries. ...
        get(unit_names{wireType}).timestamps.load;    
 
    if wireType == 1   
        Fs = 500;
        % Downsample from 4KHz to 500 Hz for macrowire data
        NLX_TS = linspace(NLX_TS(1), NLX_TS(end), length(NLXdata));
    elseif wireType == 2
        Fs = 32000;
    end
end