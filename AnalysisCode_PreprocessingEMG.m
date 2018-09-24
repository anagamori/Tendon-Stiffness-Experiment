%--------------------------------------------------------------------------
% Analysis code for tendon stiffness (preprocessing)
% Last update:8/22/18
% Function: Preprocess data
% Note: Study No. 200
%       Run this code before AnalysisCode_2 and 3
%--------------------------------------------------------------------------

close all
clear all
clc

for i = 1:12
    if i < 10
        subjectID = ['20' num2str(i)];
    else
        subjectID = ['2' num2str(i)];
    end
    dataDirectory = ['/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
    codeDirectory = '/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment';
    
    Fs = 1000;
    
    for j = 1:2
        if j == 1
            condition = 'Fl_2';
        elseif j == 2
            condition = 'Ex_2';
        end
              
        Data_EMG_temp = dlmread([dataDirectory condition '.txt'],'',10,0);
        Data_EMG_temp(:,1:3) = [];
        
        calibMatrix = [12.669 0.2290 0.1050; 0.1600 13.2370 -0.3870; 1.084 0.6050 27.0920];
        
        
        Data = PreProcessing(Data_EMG_temp(end-50*Fs+1:end,:),150);
        %Data = [Data Data_Force_temp(end-50*Fs+1:end,:)];
        
        cd (dataDirectory)
        save([condition '_Data_EMG'], 'Data')
        cd (codeDirectory)
        
    end
end
