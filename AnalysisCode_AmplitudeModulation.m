%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 8/23/2018
% Descriptions:
%   Plot 1) coherence spectrum between EMGs of wrist flexors and extensors
%        2) boxplot for average coherence between 8-15 Hz
%   Used to generaste Fig.1
%--------------------------------------------------------------------------
close all
clear all
clc



Fs = 1000; % sampling frequench [Hz]
t = [1:50*Fs]./Fs;
subjectNo = 1:12; % Subject ID
count = 1; % counter to track the number of iterations in for-loop

windowSize = 5*Fs;
[b_high,a_high] = butter(4,0.1/(Fs/2),'high');
[b,a] = butter(4,3/(Fs/2),'low');

for j = 1 %:2
    for k = 4
        % loop through subjects
        for i = 1 %:length(subjectNo)
            index_Sub = subjectNo(i);
            if index_Sub < 10
                subjectID = ['20' num2str(index_Sub)];
            else
                subjectID = ['2' num2str(index_Sub)];
            end
            dataDirectory = ['/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
            codeDirectory = '/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment';
            
            if j == 1
                condition = ['Fl_' num2str(k)];
                muscle = 1:2;
                muscle_ant = 3:4;
            else
                condition = ['Ex_' num2str(k)];
                muscle = 3:4;
                muscle_ant = 1:2;
            end
            
            % Load data
            cd (dataDirectory)
            load ([condition '_Data'])
            Data_temp = Data;          
            cd (codeDirectory)
            
            Force = Data_temp(:,end);
            Force = Force - mean(Force);
            Force_low = filtfilt(b,a,Force);
            Force_low = Force_low - mean(Force_low);
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1 = zscore(EMG_1);
            EMG_1_env = filtfilt(b,a,EMG_1);
            EMG_1_env = EMG_1_env-mean(EMG_1_env);
            %EMG_1_env = filtfilt(b_high,a_high,EMG_1_env);
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2 = zscore(EMG_2);
            EMG_2_env = filtfilt(b,a,EMG_2);
            %EMG_2_env = filtfilt(b_high,a_high,EMG_2_env);
            EMG_2_env = EMG_2_env-mean(EMG_2_env);
            
            [rho] = movingCorrelation(EMG_1_env,EMG_2_env,windowSize,0);
            [cor_Force(i,:),~] = xcorr(Force,EMG_1_env,1000,'coeff');
            [cor_Force_2(i,:),~] = xcorr(Force,EMG_2_env,1000,'coeff');
            [cor(i,:),lags] = xcorr(EMG_1_env,EMG_2_env,1000,'coeff');
            
            max_cor(i) = max(cor(i,901:1001));
            max_cor_Force(i) = max(cor_Force(i,1001:1400));
            max_cor_Force_2(i) = max(cor_Force_2(i,1001:1400));
        end
        
        figure(1)
        plot(lags,mean(cor))
        
        figure(2)
        plot(lags,mean(cor_Force))
        hold on
        plot(lags,mean(cor_Force_2))
        
    end
    
    
end
