%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 8/21/2018
% Descriptions: 
%   Plot 1) coherence spectrum between EMGs of wrist flexors and extensors
%        2) boxplot for average coherence between 8-15 Hz
%   Used to generaste Fig.1 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
close all
clear all
clc

Fs = 1000;

endTime = 50*Fs;
t = [1:50*Fs]./Fs;

subjectNo = 1:12;

Cxy_mat = zeros(length(subjectNo),1001);
Cxy_2_mat = zeros(length(subjectNo),1001);
Cxy_all = zeros(4,1001);
Cxy_2_all = zeros(4,1001);

[b_f_high,a_f_high] = butter(4,[6,15]/(Fs/2),'bandpass');
[b_f_low,a_f_low] = butter(4,20/(Fs/2),'low');

angles = -pi:pi/20:pi;

meanCoh = zeros(1,length(angles)-1);
meanForce_low= zeros(1,length(angles)-1);

meanCoh_total = zeros(length(subjectNo),length(angles)-1);
meanForce_low_total = zeros(length(subjectNo),length(angles)-1);

meanCoh_sum = zeros(1,length(angles)-1);

meanCor_alpha_total = zeros(length(subjectNo),2001);
meanCor_theta_total = zeros(length(subjectNo),2001);

%mean_pCoh_original_total = zeros(length(subjectNo),1025);
%mean_pCoh_residual_total = zeros(length(subjectNo),1025);

count = 1;

for j = 1:2
    for k = 2:2:4
        for i = 1:length(subjectNo)
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
            
            cd (dataDirectory)
            load ([condition '_Data'])
            Data_temp = Data;
            cd (codeDirectory)
            
            Force = Data_temp(:,end);
            CoV_Force(count,i) = std(Force)/mean(Force);
            Force = Force - mean(Force);
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1 = EMG_1-mean(EMG_1);
%             EMG_1_env = conv(EMG_1,hann(0.05*Fs));
%             EMG_1_env = EMG_1_env(1:length(Force));
            EMG_1_env = filtfilt(b_f_low,a_f_low,EMG_1);
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2 = EMG_2-mean(EMG_2);
%             EMG_2_env = conv(EMG_2,hann(0.05*Fs));
%             EMG_2_env = EMG_2_env(1:length(Force));
            EMG_2_env = filtfilt(b_f_low,a_f_low,EMG_2);
            
            [original residual frequencies L] = fullpcoh_test(zscore(Force),zscore(EMG_1),zscore(EMG_2),hann(1024*4),0.5,Fs);
            mean_pCoh_original_total(i,:) = original;
            mean_pCoh_residual_total(i,:) = residual;
            
            [corr,lags] = xcorr(EMG_1_env,EMG_2_env,1000,'coeff');
            corr_total(i,:) = corr;
            
            [corr_EMG1_Force,lags] = xcorr(EMG_1_env,Force,1000,'coeff');
            corr_EMG1_Force_total(i,:) = corr_EMG1_Force;
            
            [corr_EMG2_Force,lags] = xcorr(EMG_2_env,Force,1000,'coeff');
            corr_EMG2_Force_total(i,:) = corr_EMG2_Force;
            
            mean_coh(count,i) = mean(original(34:63));
            max_corr(count,i) = max(corr(900:1100));
            
            max_corr_EMG(j,i) = max(corr_EMG1_Force(500:1000));
            
        end
        
        count = count + 1;
    end
    
    figure(j)
    plot(frequencies,mean(mean_pCoh_original_total),'LineWidth',1)
    hold on
    plot(frequencies,mean(mean_pCoh_residual_total),'LineWidth',1)
    xlabel('Frequency (Hz)','FontSize',14)
    ylabel('Coherence','FontSize',14)
    legend('Coherence','Partial Coherence w/ Force')
    xlim([0 50])
    ylim([0 0.35])
    hold on
    
    figure(j+2)
    plot(lags,mean(corr_total),'LineWidth',1)
    hold on
            
    
end

max_corr_vec = reshape(max_corr,[size(max_corr,1)*size(max_corr,2),1]);
mean_coh_vec = reshape(mean_coh,[size(mean_coh,1)*size(mean_coh,2),1]);
CoV_Force_vec = reshape(CoV_Force,[size(CoV_Force,1)*size(CoV_Force,2),1]);
[f1,gof] = fit(max_corr_vec,mean_coh_vec,'poly1');

coeff = coeffvalues(f1);

figure(5)
plot(max_corr',mean_coh','o')
xlabel('Peak Cross-Correlation','FontSize',14)
ylabel('Average Coherence between 8-15 Hz','FontSize',14)
legend('Flexor High Gain','Flexor Low Gain','Extensor High Gain','Extensor Low Gain')
set(gca,'TickDir','out')
hold on 
plot([0:0.01:0.4],coeff(1)*[0:0.01:0.4]+coeff(2),'k','LineWidth',1)


figure(6)
plot(mean_coh',CoV_Force'*100,'o')
xlabel('Average Coherence between 8-15 Hz','FontSize',14)
ylabel('CoV of Force (%)','FontSize',14)
legend('Flexor High Gain','Flexor Low Gain','Extensor High Gain','Extensor Low Gain')
set(gca,'TickDir','out')
%hold on 
%plot([0:0.01:0.4],coeff(1)*[0:0.01:0.4]+coeff(2),'k','LineWidth',1)

figure(7)
plot(max_corr',CoV_Force'*100,'o')
xlabel('Average Coherence between 8-15 Hz','FontSize',14)
ylabel('CoV of Force (%)','FontSize',14)
legend('Flexor High Gain','Flexor Low Gain','Extensor High Gain','Extensor Low Gain')
set(gca,'TickDir','out')

%% 
diff_CoV = [CoV_Force(1,:)-CoV_Force(2,:) CoV_Force(4,:)-CoV_Force(3,:)];
mean_coh_vec_pre = [mean_coh(1,:) mean_coh(3,:)];
figure(7)
plot(mean_coh_vec_pre',diff_CoV','o')






