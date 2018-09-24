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
[b_f_low,a_f_low] = butter(4,5/(Fs/2),'low');

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


for j = 1
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
            EMG_1_env = conv(EMG_1,hann(0.1*Fs));
            EMG_1_env = EMG_1_env(1:length(Force));
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2 = EMG_2-mean(EMG_2);
            EMG_2_env = conv(EMG_2,hann(0.1*Fs));
            EMG_2_env = EMG_2_env(1:length(Force));
            
            
            [corr,lags] = xcorr(EMG_1_env,EMG_2_env,1000,'coeff');
            corr_total(i,:) = corr;
            
            [corr_EMG1_Force,lags] = xcorr(EMG_1_env,Force,1000,'coeff');
            corr_EMG1_Force_total(i,:) = corr_EMG1_Force;
            
            [corr_EMG2_Force,lags] = xcorr(EMG_2_env,Force,1000,'coeff');
            corr_EMG2_Force_total(i,:) = corr_EMG2_Force;
            
           
            max_corr(count,i) = max(corr(900:1100));
            
            max_corr_EMG(count,i) = max(corr_EMG1_Force(500:1000));
            
        end
        
        
        figure(count+2)
        plot(lags,mean(corr_total),'LineWidth',1)
        hold on
        
        count = count+1;
        
        figure(10)
        plot(lags,mean(corr_total),'LineWidth',1)
        xlabel('Frequency (Hz)','FontSize',14)
        ylabel('Coherence','FontSize',14)
        %xlim([0 50])
        hold on
        set(gca,'TickDir','out')
    end    
     
    
end

figure(10)
legend('High Gain','Low Gain')
% figure(5)
% plot(max_corr,mean_coh,'-o')
