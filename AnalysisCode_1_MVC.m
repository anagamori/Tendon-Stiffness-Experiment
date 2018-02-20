%--------------------------------------------------------------------------
% Analysis code for tendon stiffness (preprocessing)
% Last update:10/14/17
% Function: Preprocess MVC data
% Note: Study No. 200
%       Run this code before AnalysisCode_2 and 3 
%--------------------------------------------------------------------------

close all
clear all
clc

subjectID = '212';
dataDirectory = ['/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
codeDirectory = '/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment';

Fs = 1000;

forceLevel = 20;
condition = 'Ex_MVC';

Data_EMG_temp = dlmread([dataDirectory condition '.txt'],'',10,0);
Data_EMG_temp(:,1:3) = [];

Data = PreProcessing(Data_EMG_temp);

t = 0:1/Fs:size(Data,1)/Fs;
t(1) = [];
figure(1)
plot(t,Data(:,1)')

cd (dataDirectory)
save([condition '_Data'], 'Data')
cd (codeDirectory)

