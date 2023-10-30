
%% Processing recordings

clear;
close all;
                
% insert wave file name
wavFile_CW_All = {'Audi_A1_Driving_Away_30KPH.wav'; 
                  'Audi_A1_Driving_Away_45KPH.wav';
                  'Audi_A1_Driving_Towards_15KPH_No_Slowing.wav'};

% Selecting which recording to process
RecordingNo2Process = 1;              
wavFile_CW = wavFile_CW_All{RecordingNo2Process};

% Processing the recording
cantenna_dop_v3_yunus(wavFile_CW)






