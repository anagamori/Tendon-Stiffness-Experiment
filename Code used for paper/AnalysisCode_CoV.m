%--------------------------------------------------------------------------
% Author: Akira Nagamori
% Last update: 8/23/2018
% Description: 
%   Calculate coefficient of variation for force
%   Generate boxplot for CoV for force
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;

[b_low,a_low] = butter(4,0.1/(Fs/2),'high');

pxxAll = zeros(4,201);
startTime = 10*Fs+1;
t = [1:10*Fs]./Fs;

CoV_mat = zeros(12,4);
CoV_mat_2 = zeros(12,4);
rms_mat = zeros(12,4);
windowSize = 5*Fs;
count = 1;

subjectNo = 1:12;
for j = 1:2  
    for k = 1:3:4        
        for i = 1:length(subjectNo)
            index_Sub = subjectNo(i);
            if index_Sub < 10
                subjectID = ['20' num2str(index_Sub)];
            else
                subjectID = ['2' num2str(index_Sub)];
            end
            dataDirectory = ['/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
            codeDirectory = '/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Code used for paper/';
                                            
            if j == 1
                condition = ['Fl_' num2str(k)];
            else
                condition = ['Ex_' num2str(k)];
            end
            
            cd (dataDirectory)
            load ([condition '_Data'])
            cd (codeDirectory)
            
            Force = Data(startTime:end,end);
            CoV_mat(i,count) = std(Force)/mean(Force);
            %meanForce = mean(Force);
            %Force = filtfilt(b_low,a_low,Force);
            %CoV_mat(i,count) = std(Force)/meanForce;
            
            
            [CoV] = movingCoV(Force,windowSize,0);
            CoV_mat_2(i,count) = min(CoV);

        end      
        count = count + 1;
    end    
end

CoV_mat = CoV_mat*100;
CoV_plot = [CoV_mat(:,2) CoV_mat(:,1) CoV_mat(:,4) CoV_mat(:,3)];

figure(1)
boxplot(CoV_plot)
ylabel('CoV (%)','FontSize',14)
hold on 
plot([1.25 1.75 3.25 3.75],CoV_plot,'o')
plot([1.25 1.75],CoV_plot(:,1:2))
plot([3.25 3.75],CoV_plot(:,3:4))

commandwindow
[h,p_flexer] = ttest(CoV_mat(:,1),CoV_mat(:,2))
[h,p_extensor] = ttest(CoV_mat(:,3),CoV_mat(:,4))



