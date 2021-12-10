% ---Function 'EXTRACT_NWB'---
% Loads NWB file into Matlab, 
% extracts selected data and metadata from NWB file,
% and creates table with selected metadata.
%
% Input instructions: file_path is the location of the NWB file 
%
% Marielle L. Darwin | SPARC Codeathon 2021 | Updated: July 25 2021 

function EXTRACT_NWB(file_path)

% Extract file name from file_path
str=[file_path];
level=wildcardPattern + "\";
pat = asManyOfPattern(level);
filename = extractAfter(str,pat);

% Load NWB file into Matlab workspace
nw=nwbRead(filename);

% Pop up to browse contents of NWB file
util.nwbTree(nw);

% Extract data from NWB file 
    % Extract vector data
    vectorData=nw.general_extracellular_ephys_electrodes.('vectordata');

% Extract subject metadata from NWB file as string variables
    % Age 
    age=convertCharsToStrings(nw.general_subject.('age'));
    % Genotype 
    genotype=convertCharsToStrings(nw.general_subject.('genotype'));
    % Sex 
    sex=convertCharsToStrings(nw.general_subject.('sex'));
    % Species
    species=convertCharsToStrings(nw.general_subject.('species'));
    % Subject ID
    subject_id=convertCharsToStrings(nw.general_subject.('subject_id'));
    % Weight 
    weight=convertCharsToStrings(nw.general_subject.('weight'));

 % Create output table with subject metadata
  % Create column for metadata values
        % Define component cell arrays
        v1={age};
        v2={genotype};
        v3={weight};
        % Determine length that each cell array should be
        lv1 = length(v1);
        lv2 = length(v2);
        lv3 = length(v3);
        rows = max([lv1,lv2,lv3]);
        % Instatiate cell array of the max size
        v4 = cell(rows, 3);
        % Enter values into each column of cell array
        v4(1:lv1, 1) = v1;
        v4(1:lv2, 2) = v2;
        v4(1:lv3, 3) = v3;
        %Transpose cell array 
        Y=transpose(v4);
        % Convert cell array into table
        Column_Value=cell2table(Y,'VariableNames',{'Value'});
   % Create column for metadata value names
        % Define component cell arrays
        m1={'age'};
        m2={'genotype'};
        m3={'weight'};
        % Determine length that each cell array should be
        lm1 = length(m1);
        lm2 = length(m2);
        lm3 = length(m3);
        rows = max([lm1,lm2,lm3]);
        % Instatiate cell array of the max size
        m4 = cell(rows, 3);
        % Enter values into each column of cell array
        m4(1:lm1, 1) = m1;
        m4(1:lm2, 2) = m2;
        m4(1:lm3, 3) = m3;
        %Transpose cell array
        Y=transpose(m4);
        % Convert cell array into table
        Column_Metadata=cell2table(Y,'VariableNames',{'Metadata'});
   % Combine columns into a single table
        metadata_table=[Column_Metadata Column_Value]
end
