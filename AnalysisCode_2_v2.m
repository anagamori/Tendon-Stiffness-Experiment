%--------------------------------------------------------------------------
% Analysis code for tendon stiffness
%   CoV 
% Last update:2/15/18
% Note: Study No. 200
%       Run AnalysisCode_1 before this
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;
[b_f_high,a_f_high] = butter(4,[5,15]/(Fs/2),'bandpass');
[b_f_low,a_f_low] = butter(4,3/(Fs/2),'low');

pxxAll = zeros(4,201);
endTime = 50*Fs;
t = [1:50*Fs]./Fs;

timeWindow = 2*Fs;
timeVector = 1:timeWindow:length(t);

CoV_mat = zeros(4,length(timeVector)-1);
rms_mat = zeros(4,length(timeVector)-1);

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
            
            Force = Data(1:endTime,end);
            
            CoV(i) = std(Force)/mean(Force);
            RMS(i) = rms(Force-mean(Force));
            
            for t = 1:length(timeVector)-1
                meanForce = mean(Force(timeVector(t):timeVector(t+1)));
                SDForce = std(Force(timeVector(t):timeVector(t+1)));
                CoV_vec(t) = SDForce/meanForce;
                rms_vec(t) = rms(Force(timeVector(t):timeVector(t+1))-meanForce);
            end
            CoV_mat(i,:) = CoV_vec;
            rms_mat(i,:) = rms_vec;
            
        end
        

        CoV_cond(:,k) = mean(CoV_mat,2);
        rms_cond(:,k) = mean(rms_mat,2);
        
        CoV_all(:,k) = CoV;
        RMS_all(:,k) = RMS;
    end
    
end

save('CoV_all_Ex','CoV_all')
save('RMS_all','RMS_all')

figure(2)
boxplot(CoV_cond)
figure(3)
boxplot(CoV_all)
figure(4)
boxplot(RMS_all)




