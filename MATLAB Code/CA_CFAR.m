function [y] = CA_CFAR(RefWindow,PFA,GaurdCells,Data)

% RefWindow - gives us the reference window which we will use to calculate
% our reference cells
% PFA - The constant probability of false alarm that we want.
% GaurdCells - Set the gaurd cells on each side of the Cell Under Test
% Data - all of the data to be processed

[row_length, column_length] = size(Data); % Get the length of the rows and columns

y = zeros(row_length,column_length); % alocate space

% Loop through each column and perform CA_CFAR algorithm
for column = 1:column_length 
    Data_transposed = Data(:,column).'; % Transpose the data to what I want
    DataAfterPowerLawDetector = abs(Data_transposed).^2 ;
                     
    TrainCells = RefWindow/2;      

% Calculating the start and end indices that our reference window allows 
    StartIdx = TrainCells + GaurdCells + 1;
    StopIdx  = row_length - (TrainCells + GaurdCells);

% Allocating space for a faster for loop
    g_hatLead = zeros(1,row_length);
    g_hatLag = zeros(1,row_length);
    Threshold = zeros(1,row_length);

% Calculating the CA-CFAR constant
    alpha_CA = RefWindow*(PFA^-(1/RefWindow) - 1) ;


    for idx_CUT=StartIdx:StopIdx
     % Index for the lagging train cells
        StartIdx_fLag = idx_CUT-(TrainCells+GaurdCells);
        StopIdx_fLag = idx_CUT-GaurdCells-1;

     % index for the leading train celss
        StartIdx_fLead = idx_CUT+GaurdCells+1;
        StopIdx_fLead = idx_CUT+GaurdCells+TrainCells;

     % Averaging the Lagging and Leading train cells
        g_hatLead(:,idx_CUT) = sum(DataAfterPowerLawDetector(StartIdx_fLead:StopIdx_fLead))/TrainCells;
        g_hatLag(:,idx_CUT)  = sum(DataAfterPowerLawDetector(StartIdx_fLag:StopIdx_fLag))/TrainCells;
     
     % Calculating the threshold by taking the mean between the  leading
     % and lagging averages and multiplying the CA-CFAR constant
        Threshold(:,idx_CUT) = alpha_CA*((g_hatLag(idx_CUT) + g_hatLead(idx_CUT))/2);
     
     % Comparing the Threshold with the Data. If the Data which is noise is
     % greater than the threshold it would be a false alarm. 
        if DataAfterPowerLawDetector(idx_CUT)>Threshold(idx_CUT)
            y(idx_CUT,column) = Data_transposed(idx_CUT);
        end

    end

end

