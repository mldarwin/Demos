% ---Function 'MWfilter'---
% Filters data after channRead function 
% 
% MWchannel & Fs inputs = output from channRead function
% plotFlag input = 0 or 1
%
% Example inputs:
% highpassFreq=600;
% lowpassFreq=3000;
% plotFlag=1;
%
% Marielle L. Darwin | October 14 2021 | Last revision: October 21 2021

function [filterData] = MWfilter(MWchannel, Fs, highpassFreq, lowpassFreq, plotFlag)

% Highpass filter
[highPASS,~] = highpass(MWchannel,highpassFreq ,Fs,'ImpulseResponse','iir','Steepness',0.8);

% Lowpass filter
[filterData,~] = lowpass(highPASS, lowpassFreq, Fs, 'ImpulseResponse', 'iir', 'Steepness' ,0.8);

% Notch filter for macrowire data
    %spectral interpolation function from Miguel
   
% Plot
if plotFlag
    period = 1/Fs;
    plotTime = period:period:length(filterData)*period;
    plot(plotTime,filterData);
end 
end