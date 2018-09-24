%--------------------------------------------------------------------------
% Analysis code for tendon stiffness
%   cross-frequency coupling between low and high-frequency force
%   variability
% Last update:2/15/18
% Note: Study No. 200
%       Run AnalysisCode_1 before this
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;
[b_f_high,a_f_high] = butter(4,[6,15]/(Fs/2),'bandpass');
[b_f_low,a_f_low] = butter(4,2/(Fs/2),'low');

pxxAll = zeros(4,201);
endTime = 50*Fs;
t = [1:50*Fs]./Fs;

angles = -pi:pi/50:pi;
dataAll_low = zeros(4,length(angles)-1);
dataAll_high = zeros(4,length(angles)-1);

dataAll_r = zeros(4,1001);
dataAll_r_high = zeros(4,1001);

subjectNo = 1:12;
for j = 2
    for k = 1:4
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
            else
                condition = ['Ex_' num2str(k)];
            end
            
            cd (dataDirectory)
            load ([condition '_Data'])
            cd (codeDirectory)
            
            Force_high = filtfilt(b_f_high,a_f_high,Data(1:endTime,end));
            Force_high_temp = Force_high;
            Force_high = Force_high.^2;
            Force_high = conv(Force_high,gausswin(0.1*Fs));
            Force_high = Force_high(1:endTime); %./sum(Force_high);
            
            Force_low = filtfilt(b_f_low,a_f_low,Data(1:endTime,end));
            Force_low = Force_low-mean(Force_low);
            
            Force_phase = hilbert(Force_low);
            Force_angle = angle(Force_phase);
            
            for n = 1:length(angles)-1
                index = find(Force_angle>=angles(n)&Force_angle<=angles(n+1));
                meanAmp_low(n) = mean(Force_low(index));
                meanAmp(n) = mean(Force_high(index));              
            end
            p2p = max(meanAmp_low)-min(meanAmp_low);
            Amp_low_mat(i,:) = meanAmp_low;
            Amp_high_mat(i,:) = meanAmp./p2p;
            
            
            figure(j)
            subplot(2,1,1)
            plot(meanAmp_low)
            hold on
            subplot(2,1,2)
            plot(meanAmp)
            hold on
        end
        save(['Amp_low_' num2str(j) '_' num2str(k)],'Amp_low_mat')
        save(['Amp_high_' num2str(j) '_' num2str(k)],'Amp_high_mat')
        dataAll_low(k,:) = mean(Amp_low_mat);
        dataAll_high(k,:) =  mean(Amp_high_mat);
        
    end
    
end

figure(3)
subplot(2,1,1)
plot(dataAll_low'./length(subjectNo))
subplot(2,1,2)
plot(dataAll_high'./length(subjectNo))
legend('High','Medim High','Medium Low','Low')

%%
close all
j = 2;
condition_1 = 1;
condition_2 = 4;
load(['Amp_low_' num2str(j) '_' num2str(condition_1)])
load(['Amp_high_' num2str(j) '_' num2str(condition_1)])
Amp_low_mat_1 = Amp_low_mat;
Amp_high_mat_1 = Amp_high_mat;
load(['Amp_low_' num2str(j) '_' num2str(condition_2)])
load(['Amp_high_' num2str(j) '_' num2str(condition_2)])
Amp_low_mat_2 = Amp_low_mat;
Amp_high_mat_2 = Amp_high_mat;

for f = 1:length(angles)-1
    [h,p_low(f)] = ttest(Amp_low_mat_1(:,f),Amp_low_mat_2(:,f));  
    [h,p_high(f)] = ttest(Amp_high_mat_1(:,f),Amp_high_mat_2(:,f));  
    if p_low(f) > 0.2
        p_low(f) = 0.2;
    end
    if p_high(f) > 0.2
        p_high(f) = 0.2;
    end
   
end

figure(5)
subplot(2,1,1)
plot(mean(Amp_low_mat_1))
hold on 
plot(mean(Amp_low_mat_2))
legend('High Gain','Low Gain')
subplot(2,1,2)
plot(p_low)

figure(6)
subplot(2,1,1)
plot(mean(Amp_high_mat_1))
hold on 
plot(mean(Amp_high_mat_2))
legend('High Gain','Low Gain')
subplot(2,1,2)
plot(p_high)



