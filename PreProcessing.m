function [ProcessedData] = PreProcessing(Data)
   
    Fs = 1000;
    F_Nyquest = Fs/2;
    [b,a] = butter(10,150/F_Nyquest,'high');
    [nrow,ncol] = size(Data);
    ProcessedData = zeros(nrow,ncol);
    for i = 1:ncol
        ProcessedData(:,i) = Data(:,i) - mean(Data(:,i));
        ProcessedData(:,i) = filtfilt(b,a,ProcessedData(:,i));
        ProcessedData(:,i) = abs(ProcessedData(:,i));
    end

end