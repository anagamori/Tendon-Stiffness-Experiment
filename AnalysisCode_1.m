%--------------------------------------------------------------------------
% Analysis code for tendon stiffness (preprocessing)
% Last update:10/14/17
% Function: Preprocess data
% Note: Study No. 200
%       Run this code before AnalysisCode_2 and 3 
%--------------------------------------------------------------------------

close all
clear all
clc

subjectID = '210';
dataDirectory = ['/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
codeDirectory = '/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment';

Fs = 1000;

forceLevel = 20;
condition = 'Fl_1';
forceFile = 5;

Data_EMG_temp = dlmread([dataDirectory condition '.txt'],'',10,0);
Data_EMG_temp(:,1:3) = [];

calibMatrix = [12.669 0.2290 0.1050; 0.1600 13.2370 -0.3870; 1.084 0.6050 27.0920];

load([dataDirectory 'Subject' subjectID '_' num2str(forceFile)])
MVC = Trial.Info{3,2};
Offset = Trial.Info{4,2};
Data_Force_temp = Trial.Data(:,8:10);
Data_Force_temp = Data_Force_temp*calibMatrix;
Data_Force_temp(:,end) = -Data_Force_temp(:,end);
Data_Force_temp(:,end) = (Data_Force_temp(:,end) + Offset)/MVC;

Data = PreProcessing(Data_EMG_temp(end-50*Fs+1:end,:));
Data = [Data Data_Force_temp(end-50*Fs+1:end,:)];

t = 0:1/Fs:50;
t(1) = [];
figure(1)
plot(t,Data(:,end)')

cd (dataDirectory)
save([condition '_Data'], 'Data')
cd (codeDirectory)

