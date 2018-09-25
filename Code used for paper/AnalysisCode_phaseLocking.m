%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 9/21/2018
% Descriptions:
%   
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
            dataDirectory = ['/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
            codeDirectory = '/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Code used for paper';
            
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
            Force_phase = hilbert(Force_low-mean(Force_low)); % apply hilbert transform
            Force_amp = abs(Force_phase); % calculate amplitude
            Force_amp = Force_amp - mean(Force_amp);  % remove mean
            Force_amp_mat = segmentation(Force_amp,windowSize,overlap); %semgent the signal
           
            
            [time,freqs,Coh] = waveletCoherence(EMG_1,EMG_2,Fs,0.5:0.5:100,5);
            
            Coh_alpha = mean(atanh(sqrt(Coh(16:30,:)))); % average coherence between 8-15 Hz
            Coh_alpha = Coh_alpha - mean(Coh_alpha); % remove mean      
            Coh_alpha_phase = hilbert(Coh_alpha); % apply hilbert transform
            Coh_alpha_amp = abs(Coh_alpha_phase); % calculate amplitude
            Coh_alpha_amp = Coh_alpha_amp - mean(Coh_alpha_amp); % remove mean
            Coh_alpha_amp_mat = segmentation(Coh_alpha_amp,windowSize,overlap); %semgent the signal
            
            for n = 1:size(Coh_alpha_amp_mat,1)
                phaseLocking_vec(n) = (1/length(Force_amp_mat(n,:))) ...
                    *abs(sum(exp(1i*(angle(Force_amp_mat(n,:))-angle(Coh_alpha_amp_mat(n,:))))));
            end
            phaseLocking_vec_mean = mean(atanh(phaseLocking_vec));
            phaseLocking_amp(count,i) = phaseLocking_vec_mean;
        end
        count = count + 1;
    end
    
      
   
end

PhaseLocking_plot = [phaseLocking_amp(2,:); phaseLocking_amp(1,:); phaseLocking_amp(4,:); phaseLocking_amp(3,:)];


figure(1)
boxplot(PhaseLocking_plot')
ylabel('Phase-locking value','FontSize',14)
set(gca,'TickDir','out')
set(gca,'TickDir','out')
set(gca, 'FontName', 'Arial')
set(gca,'LineWidth',1)
box off



