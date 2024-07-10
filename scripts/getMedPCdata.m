function TrialAnSt = getMedPCdata(subject, date, medpcFiles)

MSN = {'Switch_18L6R_SITI_RI_MAW', 'Switch_6L18R_SITI_RI_MAW', ...
    'Switch_6L18R_SITI_REINFORCE_FP_V3', 'Switch_18L6R_SITI_REINFORCE_FP_V3', ...
    'Switch_6L18R_SITI_RI_MAW_LONGERSESSION'};
    
idMatch = subject;

dateRange = {date date};
%dateRange = cat(2, dateRange{:});

% This section will parse out information into structure TrialAnSt
mpcParsed = getDataIntr(medpcFiles, MSN, idMatch, dateRange);
TrialAnSt = getTrialData(mpcParsed);