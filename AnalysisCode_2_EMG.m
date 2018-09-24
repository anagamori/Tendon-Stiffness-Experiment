%--------------------------------------------------------------------------
% Analysis code for tendon stiffness
%   EMG
% Last update:2/17/18
% Note: Study No. 200
%       Run AnalysisCode_1 before this
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;

endTime = 50*Fs;
t = [1:50*Fs]./Fs;

subjectNo = 1:12;

pxx_mat = zeros(length(subjectNo),201);
pxx_all = zeros(4,201);

for j = 1
    for k = 1
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
                MVC_file = 'Fl_MVC';
                MVC_ant_file = 'Ex_MVC';
                muscle = 1:2;
                muscle_ant = 3:4;
            else
                condition = ['Ex_' num2str(k)];
                MVC_file = 'Ex_MVC';
                MVC_ant_file = 'Fl_MVC';
                muscle = 3:4;
                muscle_ant = 1:2;
            end
            
            cd (dataDirectory)            
            load ([condition '_Data'])
            Data_temp = Data;
            load ([MVC_file '_Data'])
            Data_MVC_temp = Data;
            load ([MVC_ant_file '_Data'])
            Data_MVC_ant_temp = Data;
            cd (codeDirectory)
            
            MVC_1 = Data_MVC_temp(:,muscle(1));
            MVC_1_conv = conv(MVC_1,gausswin(1*Fs));
            peak_MVC = max(MVC_1_conv(10:length(MVC_1)));
            
            EMG_1 = Data_temp(1:endTime,muscle(1));
            EMG_1_conv = conv(EMG_1,gausswin(0.1*Fs));
            EMG_1_amp = EMG_1_conv(1:length(EMG_1));
            %EMG_1_amp = EMG_1_amp./peak_MVC;
            
            EMG_1_mean(i) = mean(EMG_1_amp(5*Fs:end));
            
            MVC_2 = Data_MVC_temp(:,muscle(2));
            MVC_2_conv = conv(MVC_2,gausswin(1*Fs));
            peak_MVC = max(MVC_2_conv(10:length(MVC_2)));
            
            EMG_2 = Data_temp(1:endTime,muscle(2));
            EMG_2_conv = conv(EMG_2,gausswin(0.1*Fs));
            EMG_2_amp = EMG_2_conv(1:length(EMG_2));
            EMG_2_amp = EMG_2_amp./peak_MVC;
            
            EMG_2_mean(i) = mean(EMG_2_amp(5*Fs:end));
            
            MVC_3 = Data_MVC_ant_temp(:,muscle_ant(1));
            MVC_3_conv = conv(MVC_3,gausswin(1*Fs));
            peak_MVC = max(MVC_3_conv(10:length(MVC_3)));
            
            EMG_3 = Data_temp(1:endTime,muscle_ant(1));
            EMG_3_conv = conv(EMG_3,gausswin(1*Fs));
            EMG_3_amp = EMG_3_conv(1:length(EMG_3));
            EMG_3_amp = EMG_3_amp./peak_MVC;
            
            EMG_3_mean(i) = mean(EMG_3_amp(5*Fs:end));
            
            MVC_4 = Data_MVC_ant_temp(:,muscle_ant(2));
            MVC_4_conv = conv(MVC_4,gausswin(1*Fs));
            peak_MVC = max(MVC_4_conv(10:length(MVC_4)));
            
            EMG_4 = Data_temp(1:endTime,muscle_ant(1));
            EMG_4_conv = conv(EMG_4,gausswin(1*Fs));
            EMG_4_amp = EMG_4_conv(1:length(EMG_4));
            EMG_4_amp = EMG_4_amp./peak_MVC;
            
            EMG_4_mean(i) = mean(EMG_4_amp(5*Fs:end));
        end
        
        EMG_1_mean_all(:,k) = EMG_1_mean;
        EMG_2_mean_all(:,k) = EMG_2_mean;
        EMG_3_mean_all(:,k) = EMG_3_mean;
        EMG_4_mean_all(:,k) = EMG_4_mean;
        
    end
    
end

% figure(1)
% boxplot(EMG_1_mean_all)
% 
% figure(2)
% boxplot(EMG_2_mean_all)
% 
% figure(3)
% boxplot(EMG_3_mean_all)
% 
% figure(4)
% boxplot(EMG_4_mean_all)
