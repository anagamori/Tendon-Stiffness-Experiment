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
subjectNo = 1:12; % Subject ID
count = 1; % counter to track the number of iterations in for-loop

startTime = 10*Fs+1;

windowSize = 2*Fs;
L = (50*Fs+1-startTime)/windowSize;

for j = 1
    for k = 2 %:2:4
        % loop through subjects
        for i = 4 %1:length(subjectNo)
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
            
            % Load data
            cd (dataDirectory)
            load ([condition '_Data'])
            Data_temp = Data;
            cd (codeDirectory)
                       
            EMG_1 = Data_temp(startTime:end,muscle(1));
            EMG_1 = EMG_1-mean(EMG_1);            
            EMG_2 = Data_temp(startTime:end,muscle(2));
            EMG_2 = EMG_2-mean(EMG_2);
                      
            [Coh,frequencies] = mscohere(EMG_1,EMG_2,rectwin(windowSize),0,0:0.5:500,Fs);
            %[Coh,frequencies] = mscohere(EMG_1,EMG_2,hann(windowSize),0.5*windowSize,0:0.5:500,Fs);
            Coh_all(i,:) = Coh;
            Fz = atanh(sqrt(Coh));
            Z = Fz/(sqrt(1/(2*L)));
            Z = Z - mean(Z(201:end));
            Coh_Z_all(i,:) = Z;
                                  
            mean_Coh(count,i) = mean(Coh(17:31));
            mean_Coh_Z(count,i) = mean(Z(17:31));
            max_Coh_Z(count,i) = max(Z(17:31));
            %mean_Coh(count,i) = mean(Coh(81:151));
                       
        end
        
        for f = 1:length(frequencies)
            nSub(count,f) = length(find(Coh_Z_all(:,f)>1.65));
        end
        
        count = count+1;
        
        figure(1)
        plot(frequencies,mean(Coh_Z_all),'LineWidth',1)
        %plot(frequencies,Coh_Z_all,'LineWidth',1)
        xlabel('Frequency (Hz)','FontSize',14)
        ylabel('Z-Score','FontSize',14)
        xlim([0 100])
        %ylim([0 0.4])
        hold on
        set(gca,'TickDir','out')
        set(gca, 'FontName', 'Arial')
        set(gca,'LineWidth',1)
        box off
    
    end    
     
    
end

%alpha = 1-(1-0.05)^(1/(L-1));
figure(1)
plot([0 100],[1.65 1.65],'k','LineWidth',1)
legend('Wrist Flexors','Wrist Extensors')

Fz_mean = atanh(sqrt(mean_Coh));
[h,p] = ttest(Fz_mean(1,:),Fz_mean(2,:));

%%
figure(2)
boxplot(mean_Coh')
hold on 
plot([1.25 1.75],mean_Coh','o')
plot([1.25 1.75],mean_Coh')
%plot([1 2],[1.65 1.65],'k','LineWidth',1)
ylabel('Average Coherence between 8-15 Hz','FontSize',14)
set(gca,'TickDir','out')
set(gca, 'FontName', 'Arial')
set(gca,'LineWidth',1)
box off
% ax = gca;
% ax.XAxis.FontSize = 10;
% ax.YAxis.FontSize = 10;


%%
figure(3)
boxplot(max_Coh_Z')
hold on 
plot(1:2,max_Coh_Z','o')
plot([1 2],[2.72 2.72],'k','LineWidth',1)
ylabel('Peak Z-score Coherence between 8-15 Hz','FontSize',14)
set(gca,'TickDir','out')
