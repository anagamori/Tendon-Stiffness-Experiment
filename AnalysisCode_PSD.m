%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 8/23/2018
% Description: 
%   Calculate power spectrum of force 
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;

subjectNo = 1:12;

pxx_mat = zeros(length(subjectNo),201);
pxx_all = zeros(4,201);

for j = 1
    for k = 1:4
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
            else
                condition = ['Ex_' num2str(k)];
            end
            
            cd (dataDirectory)
            load ([condition '_Data'])
            cd (codeDirectory)
            
            Force = Data(1:endTime,end);
            %Force = filtfilt(b_low,a_low,Force);
            Force = Force - mean(Force);
            
            [pxx,freq] = pwelch(Force,gausswin(5*Fs),2.5*Fs,0:0.1:20,Fs,'power');
            pxx = pxx;
            CD_low(i) = mean(pxx(21:51));
            CD_high(i) = mean(pxx(31:61));
            PT(i) = mean(pxx(81:151));
            
            pxx_mat(i,:) = pxx; 
            
            
        end
        save(['pxx_' num2str(j) '_' num2str(k)],'pxx_mat')
        pxx_all(k,:) = mean(pxx_mat);
        CD_low_all(:,k) = CD_low;
        CD_high_all(:,k) = CD_high;
        PT_all(:,k) = PT;
        pxx_mat = zeros(length(subjectNo),201);
    end
    
end

figure(1)
plot(freq,pxx_all)
xlabel('Frequency (Hz)')
ylabel('Power')
legend('High','Medim High','Medium Low','Low')

figure(2)
boxplot(CD_low_all)
title('0.5 - 5 Hz')

figure(3)
boxplot(CD_high_all)
title('3 - 6 Hz')

figure(4)
boxplot(PT_all)
title('6 - 15 Hz')

%%
% close all
% clear all
% clc
j = 2;
load(['pxx_' num2str(j) '_' num2str(2)])
pxx_mat_1 = pxx_mat;
load(['pxx_'  num2str(j) '_' num2str(4)])
pxx_mat_2 = pxx_mat;
freq = 0:0.1:20;
for f = 1:length(freq)
    [h,p(f)] = ttest(pxx_mat_1(:,f),pxx_mat_2(:,f));  
    if p(f) > 0.2
        p(f) = 0.2;
    end
end

figure(5)
subplot(2,1,1)
plot(freq,mean(pxx_mat_1),'LineWidth',1)
hold on 
plot(freq,mean(pxx_mat_2),'LineWidth',1)
ylabel('Power (%MVC^2)','FontSize',14)
legend('High Gain','Low Gain')
xlim([4 20])
set(gca,'TickDir','out')

%plot(freq,mean(pxx_mat_1-pxx_mat_2))
subplot(2,1,2)
plot(freq,p,'LineWidth',1)
xlabel('Frequency (Hz)','FontSize',14)
ylabel('p-value','FontSize',14)
set(gca,'TickDir','out')
%xlim([5 20])
