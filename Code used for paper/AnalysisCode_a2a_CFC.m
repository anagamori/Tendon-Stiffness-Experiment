%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 9/23/2018
% Descriptions:
%   Amplitude-to-amplitude cross-frequency coupling
%   Method adopted from Bruns & Eckhorn (2004)
%--------------------------------------------------------------------------


close all
clear all
clc

Fs = 1000;

endTime = 50*Fs;
t = [1:50*Fs]./Fs;

subjectNo = 1:12;


[b_f_low,a_f_low] = butter(4,5/(Fs/2),'low');

windowSize = 5*Fs;
overlap = 0;
nboostrap = 2000;
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
            dataDirectory = ['/Users/akira/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
            codeDirectory = '/Users/akira/Documents/Github/Tendon-Stiffness-Experiment/Code used for paper';
            
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
            
            % Data processing for force signal 
            Force_low = filtfilt(b_f_low,a_f_low,Force); % apply low-pass filter at 5Hz
            Force_phase = hilbert(Force_low-mean(Force_low)); % apply hilbert transform to obtain analytical signal
            Force_amp = abs(Force_phase); % calculate amplitude
            Force_amp = Force_amp - mean(Force_amp);  % remove mean
            Force_amp_mat = segmentation(Force_amp,windowSize,overlap); %semgent the signal
            % Data processing for alpha-band coherence
            [time,freqs,Coh] = waveletCoherence(EMG_1,EMG_2,Fs,0.5:0.5:100,5); % wavelet coherence
            
            Coh_alpha = mean(atanh(sqrt(Coh(16:30,:)))); % average coherence between 8-15 Hz
            Coh_alpha = Coh_alpha - mean(Coh_alpha); % remove mean      
            Coh_alpha_phase = hilbert(Coh_alpha); % apply hilbert transform to obtain analytical signal
            Coh_alpha_amp = abs(Coh_alpha_phase); % calculate amplitude
            Coh_alpha_amp = Coh_alpha_amp - mean(Coh_alpha_amp); % remove mean
            Coh_alpha_amp_mat = segmentation(Coh_alpha_amp,windowSize,overlap); %semgent the signal
            
            % Compute correlation coefficient between two signals for a
            % given segment
            for n = 1:size(Coh_alpha_amp_mat,1)
                rho_vec(n) = corr(Force_amp_mat(n,:)',Coh_alpha_amp_mat(n,:)');
            end
            rho_vec_mean = mean(atanh(rho_vec));
            
            % Create a shuffled data set to create a null distribution
            index_1 = datasample(1:size(Coh_alpha_amp_mat,1),nboostrap);
            index_2 = datasample(1:size(Coh_alpha_amp_mat,1),nboostrap);
            for m = 1:nboostrap
                rho_shuffle_vec(m) = corr(Force_amp_mat(index_1(m),:)',Coh_alpha_amp_mat(index_2(m),:)');
            end
            rho_shuffle_vec_mean = mean(atanh(rho_shuffle_vec));
            rho_shuffle_vec_std = std(atanh(rho_shuffle_vec));
            rho_z(count,i) = (rho_vec_mean - rho_shuffle_vec_mean)/rho_shuffle_vec_std; %rho_vec_mean
            rho_shuffle_z(count,i) = rho_shuffle_vec_mean;
            % amplitude-to-amplitude cross-freqeuncy coupling
            [rho(count,i),pval(count,i)] = corr(Force_amp,Coh_alpha_amp'); % pearson's correlation coefficient                   
            %[r(i,:),lag] = xcorr(Force_amp,amp_Coh_alpha',1000,'coeff');
            
        end
        count = count + 1;
    end
    
      
   
end

%%
rho_plot = [rho(2,:); rho(1,:)];%; rho(4,:); rho(3,:)];
rho_z_plot = [tanh(rho_z(2,:)); tanh(rho_z(1,:))]; % rho_z(4,:); rho_z(3,:)];
%%
figure(1)
boxplot(rho_plot')
ylabel('Amplitude-amplitude CFC','FontSize',14)
set(gca,'TickDir','out')
set(gca,'TickDir','out')
set(gca, 'FontName', 'Arial')
set(gca,'LineWidth',1)
box off

figure(2)
%bar([length(find(pval(2,:)<0.05)) length(find(pval(1,:)<0.05)) length(find(pval(4,:)<0.05)) length(find(pval(3,:)<0.05))])
boxplot(rho_z_plot')
ylabel('Z-score amplitude-amplitude CFC','FontSize',14)
set(gca,'TickDir','out')
set(gca,'TickDir','out')
set(gca, 'FontName', 'Arial')
set(gca,'LineWidth',1)
box off



