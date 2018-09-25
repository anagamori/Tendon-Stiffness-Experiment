%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 9/25/2018
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
startTime = 0; %0*Fs+1;
subjectNo = 1:12; % Subject ID
count = 1; % counter to track the number of iterations in for-loop

windowSize = 2*Fs;
[b_high,a_high] = butter(4,0.1/(Fs/2),'high');
[b,a] = butter(4,5/(Fs/2),'low');

for j = 1:2
    for k = 2:2:4
        % loop through subjects
        for i = 1:length(subjectNo)
            index_Sub = subjectNo(i);
            if index_Sub < 10
                subjectID = ['20' num2str(index_Sub)];
            else
                subjectID = ['2' num2str(index_Sub)];
            end
            dataDirectory = ['/Users/akira/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
            codeDirectory = '/Users/akira/Documents/GitHub/Tendon-Stiffness-Experiment/Code used for paper/';
            
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
            
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1_demean = EMG_1 - mean(EMG_1);
            EMG_1_env = filtfilt(b,a,EMG_1);
            EMG_1_env = EMG_1_env-mean(EMG_1_env);   
            
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2_demean = EMG_2 - mean(EMG_2);
            EMG_2_env = filtfilt(b,a,EMG_2);
            EMG_2_env = EMG_2_env-mean(EMG_2_env);
            
            [rho,corr_mat,lags] = movingCorrelation(EMG_1_env,EMG_2_env,windowSize,0);
            
            mean_rho(count,i) = tanh(mean(atanh(rho)));
            
            [Coh,frequencies] = mscohere(EMG_1,EMG_2,rectwin(windowSize),0,0:0.5:500,Fs);
            Fz = atanh(sqrt(Coh));
            mean_Coh_Z(count,i) = (mean(Fz(17:31)));
        end
        
        count = count + 1;
    end
    
    
end


%%
figure(1)
boxplot(mean_rho')


figure(2)
plot(mean_rho',mean_Coh_Z','o')
xlabel('Correlation coefficient','FontSize',14)
ylabel('Average z-coherence between 8-15 Hz','FontSize',14)
xlim([0.2 0.45])
ylim([0.1 0.7])
set(gca,'TickDir','out')
set(gca, 'FontName', 'Arial')
set(gca,'LineWidth',1)
box off