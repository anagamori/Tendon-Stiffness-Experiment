function [CoV] = movingCoV(signal,windowSize,overlap)

% Find starting points of each segment with the specified window size and
% overlap 
startPoints = [1:windowSize-overlap:length(signal)];
% Remove starting points that are larger than the last window due to
% overlapping 
startPoints(startPoints>length(signal)-windowSize+1) = [];

% Initialize matrices and vectors
dataSegments = zeros(length(startPoints),windowSize);
CoV = zeros(1,length(startPoints));

for i = 1:length(startPoints)
   % Segment the input signal and stack them into a matrix
   dataSegments(i,:) = signal(startPoints(i):startPoints(i)+windowSize-1); 
   
   % Store the amplitude of input signal at each frquency 
   CoV(i) = std(dataSegments(i,:))/mean(dataSegments(i,:)); 
end

end