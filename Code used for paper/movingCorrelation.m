function [rho,corr_mat,lags] = movingCorrelation(signal_1,signal_2,windowSize,overlap)

% Find starting points of each segment with the specified window size and
% overlap 
startPoints = [1:windowSize-overlap:length(signal_1)];
% Remove starting points that are larger than the last window due to
% overlapping 
startPoints(startPoints>length(signal_1)-windowSize+1) = [];

% Initialize matrices and vectors
dataSegments_1 = zeros(length(startPoints),windowSize);
dataSegments_2 = zeros(length(startPoints),windowSize);
rho = zeros(1,length(startPoints));
corr_mat = zeros(length(startPoints),2001);

for i = 1:length(startPoints)
   % Segment the input signal and stack them into a matrix
   dataSegments_1(i,:) = signal_1(startPoints(i):startPoints(i)+windowSize-1); 
   dataSegments_2(i,:) = signal_2(startPoints(i):startPoints(i)+windowSize-1); 
   % Store the amplitude of input signal at each frquency 
   [corr,lags] = xcorr(dataSegments_1(i,:)-mean(dataSegments_1(i,:)),dataSegments_2(i,:)-mean(dataSegments_2(i,:)),1000,'coeff');
   corr_mat(i,:) = corr;
   rho(i) = max(corr(801:1201)); 
end

end