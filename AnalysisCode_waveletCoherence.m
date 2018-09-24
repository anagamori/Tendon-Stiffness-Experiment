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

angles = -pi:pi/10:pi;

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
            Force = Force - mean(Force);
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1 = EMG_1-mean(EMG_1);
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2 = EMG_2-mean(EMG_2);
            
            Force_low = filtfilt(b_f_low,a_f_low,Force);
            Force_phase = hilbert(Force_low-mean(Force_low));
            Force_angle = angle(Force_phase);
            
            [time,freqs,Coh] = waveletCoherence(EMG_1,EMG_2,Fs,0.5:0.5:100,5);
            
            meanCoh = mean(Coh(16:30,:));
            meanCoh = meanCoh - mean(meanCoh);
            %meanCoh = filtfilt(b_f_low,a_f_low,meanCoh);
            meanCoh_phase = hilbert(meanCoh);
            
            rho(count,i) = corr(Force_low,meanCoh');
            PhaseLocking_amp(count,i) = (1/length(Force_phase))*abs(sum(exp(1i*(angle(Force_phase)-angle(meanCoh_phase')))));
            rayleighZ(count,i) = PhaseLocking_amp(count,i)^2*length(Force_phase);
            p_val(count,i) = exp(-rayleighZ(count,i));
%            PhaseLocking_phase(i,:) = angle(exp(1i*(angle(Force_phase)-angle(meanCoh_phase'))));
%             alpha_Coh = mean(Coh(16:30,:));
%             alpha_Coh_z = zscore(alpha_Coh);
%             alpha_Coh_z = filtfilt(b_f_low,a_f_low,alpha_Coh_z);
                       
            
        end
        count = count + 1;
    end
    
      
   
end

PhaseLocking_plot = [PhaseLocking_amp(2,:); PhaseLocking_amp(1,:); PhaseLocking_amp(4,:); PhaseLocking_amp(3,:)];
rho_plot = [rho(2,:); rho(1,:); rho(4,:); rho(3,:)];

figure(1)
boxplot(PhaseLocking_plot')
ylabel('Phase-locking value','FontSize',14)
legend('High Gain','Low Gain')
set(gca,'TickDir','out')

figure(2)
boxplot(rho_plot')
ylabel('Correlation Coefficient','FontSize',14)
legend('High Gain','Low Gain')
set(gca,'TickDir','out')


