% ---Function 'Taskfunc'---
% 
% Input instructions:
% numCSV: Generate a specific number of CSV files 
%   Each file contains a 2x10 array of random integers
%   Column 1 named "Experiment" data; Column 2 named "Control" data
% saveDIR: Indicate path to folder to save files
% sumStat: Generate a table 'sumTable' with summary statistic for all files
%   Choice of mean, median, or standard deviation
% numPLOT: Indicate which CSV file to use to generate a plot
%
% Example: Taskfunc(4,'C:\Documents','mean',2)
%   - Generate 4 CSV files saved in C:\Documents
%   - Calculate means for all Experiment data and all Control data 
%   separately, output into one table
%   - Plot datapoints from 2nd CSV file
%
% Marielle L. Darwin | December 30 2020

function [sumTable]=Taskfunc(numCSV,saveDIR,sumStat,numPLOT)

tempDir=uigetdir([saveDIR],'Select Data Folder');                    % Select folder to save using GUI pop up
C=[];                                                                % Undefined input argument for use below
for iter=1:numCSV                                                    % Loop through to create arrays, number of times based on 'numCSV' value
    Y=randi(100,10,2);                                               % Random array of integers 'Y' between 1-100 with 2 columns and 10 rows
    Ytable=array2table(Y,'VariableNames',{'Experiment','Control'});  % Convert array 'Y' to table 'Ytable' with 'array2table' function
    filename=sprintf('iter_%d.csv', iter);                           % Create a string variable to name the file with 'sprintf' function    
    save(fullfile(tempDir, filename),'Ytable');                      % Update contents of 'save' function 
    X(:,:,iter)=Y;                                                   % Convert separate 10x2 arrays from 'Y' into 1 10x2xnumCSV 3D matrix 'X'
    C = [C,{Y}];                                                     % Create 1 cell matrix 'C' with the generated 10x2 arrays 'Y' added each loop
end

MMatrix=cell2mat(C);                    % Create 1 matrix with numCSV arrays of 10x2

% Extract every other column from MMatrix starting with first column to isolate all 'Experiment' data
    MatrixExp=MMatrix;                                                     % Rename to preserve original variable
    colToKeep=1;                                                           % Keep every other column starting with the first one
    colToDelete=1;                                                         % Delete every other column starting with the second one
    ColIndex=mod(0:size(MatrixExp,2)-1,colToKeep+colToDelete)<colToKeep;
    MatrixExp(:,~ColIndex)=[];

% Extract every other column from MMatrix to isolate all 'Control' data
    MatrixCont=MMatrix;                                                    % Rename to preserve original variable
    colToKeep=1;                                                           % Keep every other column starting with the first one
    colToDelete=1;                                                         % Delete every other column starting with the second one
    ColIndex=mod(0:size(MatrixCont,2)-1,colToKeep+colToDelete)<colToKeep;
    MatrixCont(:,ColIndex)=[];                                             % Absence of '~' creates matrix with data deleted instead of data retained, leaving a table with data from every other column starting with the second one
   
% Calculate specific summary statistic from 'sumStat' input 
for sumStat='mean'
   SummaryExp=mean(MatrixExp)';          % Mean for each column in 'Experiment' matrix and transpose
   SummaryCont=mean(MatrixCont)';        % Mean for each column in 'Control' matrix and transpose
end
for sumStat='median'
   SummaryExp=median(MatrixExp)';        % Median for each column in 'Experiment' matrix and transpose
   SummaryCont=median(MatrixCont)';      % Median for each column in 'Control' matrix and transpose
end
for sumStat='standard deviation'
   SummaryExp=std(MatrixExp)';           % Standard deviation for each column in 'Experiment' matrix and transpose
   SummaryCont=std(MatrixCont)';         % Standard deviation for each column in 'Control' matrix and transpose
end

% Table of sumStat values
TableExp = array2table(SummaryExp,'VariableNames',{'Experiment'});  % Label column before concatenating with 'Control' data
TableCont = array2table(SummaryCont,'VariableNames',{'Control'});   % Label column before concatenating with 'Experiment' data
sumTable=[TableExp,TableCont]                                       % Concatenate into 1 table and display in command window

% Plot specified CSV file
if 0<numPLOT && numPLOT<=numCSV                             % Create a plot only if 'numPLOT' input <0, and if 'numPLOT' value is within the number of CSV files generated from 'numCSV' input
 Xm=X(:,:,numPLOT);                                         % Pulls the nth array (specified by 'numPLOT') out of 3D matrix 'X' to plot
 bar(Xm);                                                   % Bar graph of data file specified by 'numPLOT'
 xlabel('Row in Array');
 ylabel('Integer Value');
 title('Plot of data');
 legend('Experiment','Control');
 box on;                                                     %Box outline around figure
 legend('boxon');                                            %Box outline around figure legend
else error('numPLOT is not in range of generated CSV files') %If numPLOT value is not within the range specified in the 'if' statement, an error message appears                                                                             
end
end