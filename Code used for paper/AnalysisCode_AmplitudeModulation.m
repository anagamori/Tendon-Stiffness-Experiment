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
startTime = 10*Fs+1;
subjectNo = 1:12; % Subject ID
count = 1; % counter to track the number of iterations in for-loop

windowSize = 2*Fs;
[b_high,a_high] = butter(4,0.1/(Fs/2),'high');
[b,a] = butter(4,2/(Fs/2),'low');

for j = 1 %:2
    for k = 4
        % loop through subjects
        for i = 1:length(subjectNo)
            index_Sub = subjectNo(i);
            if index_Sub < 10
                subjectID = ['20' num2str(index_Sub)];
            else
                subjectID = ['2' num2str(index_Sub)];
            end
            dataDirectory = ['/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
            codeDirectory = '/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Code used for paper/';
            
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
%             Force = Data_temp(:,end);
%             load ([condition '_Data_EMG'])
%             Data_temp = Data;    
            cd (codeDirectory)
            
            Force = Data_temp(startTime:end,end);
            Force = Force - mean(Force);
            Force_low = filtfilt(b,a,Force);
            Force_low = Force_low - mean(Force_low);
            %Force_low = Force_low(0.5*Fs:end);
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1 = zscore(EMG_1);
            EMG_1_env = filtfilt(b,a,EMG_1);
            %EMG_1_env = filtfilt(b_high,a_high,EMG_1_env);
            %EMG_1_env = EMG_1_env-mean(EMG_1_env);
            EMG_1_env = EMG_1_env(startTime:end);
            EMG_1_env = EMG_1_env-mean(EMG_1_env);           
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2 = zscore(EMG_2);
            EMG_2_env = filtfilt(b,a,EMG_2);
            %EMG_2_env = filtfilt(b_high,a_high,EMG_2_env);
            %EMG_2_env = EMG_2_env-mean(EMG_2_env);
            EMG_2_env = EMG_2_env(startTime:end);
            EMG_2_env = EMG_2_env-mean(EMG_2_env);
            
            [rho,corr_mat,lags] = movingCorrelation(EMG_1_env,EMG_2_env,windowSize,0);
            [cor_Force(i,:),~] = xcorr(Force_low,EMG_1_env,1000,'coeff');
            [cor_Force_2(i,:),~] = xcorr(Force_low,EMG_2_env,1000,'coeff');
            [cor(i,:),lags] = xcorr(EMG_1_env,EMG_2_env,1000,'coeff');
            
            max_cor(i) = max(cor(i,901:1001));
            max_cor_Force(i) = max(cor_Force(i,1001:1400));
            max_cor_Force_2(i) = max(cor_Force_2(i,1001:1400));
            
            mean_rho(i) = tanh(mean(atanh(rho)));
            
            figure(3)
            plot(lags,mean(corr_mat))
            hold on 
            
            
        end
        
        figure(1)
        plot(lags,mean(cor))
        
        figure(2)
        plot(lags,mean(cor_Force))
        hold on
        plot(lags,mean(cor_Force_2))
        
    end
    
    
end
