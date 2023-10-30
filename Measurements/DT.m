function [SC] = DT(RefWindow,PFA,GaurdCells,Data)

Length = lenth(Data);
DataAfterPowerLawDetector = abs(Data).^2 ;

% Setting the needed parameters                       % number of gaurd cells on each side
TrainCells = RefWindow/2;              % amount of training cells on each side of CUT

% Calculating the start and end indices that our reference window allows 
StartIdx = TrainCells + GaurdCells + 1;
StopIdx  = Length - (TrainCells + GaurdCells);

% Allocating space for a faster for loop
g_hatLead = zeros(1,Length);
g_hatLag = zeros(1,Length);
Threshold = zeros(1,Length);

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
         SC(idx_CUT) = idx_CUT;
     end
end