%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update:9/25/2018
% Descriptions:
%   cross-frequency coupling between low-frequency force variability and
%   alpha-band cohernece
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;
[b_f_high,a_f_high] = butter(4,[6,15]/(Fs/2),'bandpass');
[b_f_low,a_f_low] = butter(4,5/(Fs/2),'low');

pxxAll = zeros(4,201);
endTime = 50*Fs;
t = [1:50*Fs]./Fs;

angles = -pi:pi/20:pi; % phase bins
dataAll_low = zeros(4,length(angles)-1);
dataAll_high = zeros(4,length(angles)-1);

dataAll_r = zeros(4,1001);
dataAll_r_high = zeros(4,1001);

nboostrap = 2000;
count = 1;

subjectNo = 1:12;
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
            codeDirectory = '/Users/akira/Documents/GitHub/Tendon-Stiffness-Experiment/Code used for paper';
            
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
            
            % Compute phase angle of low-frequency component of force
            Force_low = filtfilt(b_f_low,a_f_low,Data_temp(:,end)); % apply low-pass filter
            Force_low = Force_low-mean(Force_low); % remove mean
            Force_analytical = hilbert(Force_low); % apply Hilbert transform to obtain analytical signal
            Force_angle = angle(Force_analytical); % calculate phase angle
            
            Force_low_fake = flipud(Force_low);
            Force_analytical_fake = hilbert(Force_low_fake); % apply Hilbert transform to obtain analytical signal
            Force_angle_fake = angle(Force_analytical_fake); % calculate phase angle
            % Compute wavelet coherence between muscles
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1 = EMG_1-mean(EMG_1);
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2 = EMG_2-mean(EMG_2);
            [time,freqs,Coh] = waveletCoherence(EMG_1,EMG_2,Fs,0.5:0.5:100,5);
            Coh_alpha = mean(atanh(sqrt(Coh(16:30,:)))); % average coherence between 8-15 Hz
            Coh_alpha = Coh_alpha - mean(Coh_alpha); % remove mean
            Coh_alpha_analytical = hilbert(Coh_alpha); % apply hilbert transform
            Coh_alpha_amp = abs(Coh_alpha_analytical);
            
            % Compute average coherence across samples that corresponds to
            % a give phase bin for force
            for n = 1:length(angles)-1
                index = find(Force_angle>=angles(n)&Force_angle<=angles(n+1)); % obtain index in samples that corresponds to a given phase bin
                amp_Force(n) = mean(Force_low(index));
                amp_Coh_alpha(n) = mean(Coh_alpha_amp(index));
                
                index_fake = find(Force_angle_fake>=angles(n)&Force_angle_fake<=angles(n+1));
                amp_Coh_alpha_fake(n) = mean(Coh_alpha_amp(index_fake));
                std_Coh_alpha_fake(n) = std(Coh_alpha_amp(index_fake));
            end
            
            amp_Coh_alpha_z_mat(i,:) = (amp_Coh_alpha - amp_Coh_alpha_fake)./std_Coh_alpha_fake;
            amp_Force_mat(i,:) = amp_Force;
            amp_Coh_alpha_mat(i,:) = amp_Coh_alpha;
            
        end
        mean_Force_mat(count,:) = mean(amp_Force_mat);
        mean_Coh_alpha_z_mat(count,:) = mean(amp_Coh_alpha_z_mat);
        count  = count+1;
    end
    
end

%%
figure()
subplot(2,1,1)
plot(angles(1:end-1),mean_Force_mat,'LineWidth',1)
xlim([-pi-0.05 pi+0.05])
ylim([-6e-3 6e-3])
xlabel('Phase (radian)','FontSize',14)
ylabel('Amplitude of low-frequency force variability','FontSize',14)
set(gca,'TickDir','out')
set(gca,'TickDir','out')
set(gca, 'FontName', 'Arial')
set(gca,'LineWidth',1)
box off
subplot(2,1,2)
plot(angles(1:end-1),mean_Coh_alpha_z_mat,'LineWidth',1)
xlim([-pi-0.05 pi+0.05])
ylim([-0.4 0.4])
xlabel('Phase (radian)','FontSize',14)
ylabel('Amplitude of alpha-band coherence','FontSize',14)
set(gca,'TickDir','out')
set(gca,'TickDir','out')
set(gca, 'FontName', 'Arial')
set(gca,'LineWidth',1)
box off



