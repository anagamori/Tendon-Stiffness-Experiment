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
                MVC_trial = ['Fl_MVC_Data'];
                muscle = 1:2;
                muscle_ant = 3:4;
            else
                condition = ['Ex_' num2str(k)];
                MVC_trial = ['Ex_MVC_Data'];
                muscle = 3:4;
                muscle_ant = 1:2;
            end
            
            cd (dataDirectory)           
            load ([condition '_Data'])
            Data_temp = Data;
            load (MVC_trial)
            Data_MVC = Data;
            cd (codeDirectory)
            
            EMG_1_MVC = Data_MVC(:,muscle(1));
            EMG_1_env = conv(EMG_1_MVC,hann(0.1*Fs));
            EMG_1_MVC_max = max(EMG_1_env);
            EMG_2_MVC = Data_MVC(:,muscle(2));
            EMG_2_env = conv(EMG_2_MVC,hann(0.1*Fs));
            EMG_2_MVC_max = max(EMG_2_env);
            
            Force = Data_temp(:,end);
            CoV_Force(count,i) = std(Force)/mean(Force);
            Force = Force - mean(Force);
            EMG_1 = Data_temp(:,muscle(1))./EMG_1_MVC_max;
            EMG_1 = EMG_1-mean(EMG_1);
            EMG_1_env = conv(EMG_1,hann(0.1*Fs));
            EMG_1_env = EMG_1_env(1:length(Force));
            EMG_2 = Data_temp(:,muscle(2))./EMG_2_MVC_max;
            EMG_2 = EMG_2-mean(EMG_2);
            EMG_2_env = conv(EMG_2,hann(0.1*Fs));
            EMG_2_env = EMG_2_env(1:length(Force));
            
            temp = EMG_1_env./EMG_2_env;
            temp(isnan(temp)) = 0;
            ratio(count,i) = mean(temp);
            
            co_index_temp = min(EMG_1_env,EMG_2_env)./max(EMG_1_env,EMG_2_env).*(EMG_1_env+EMG_2_env);
            co_index_temp(isnan(co_index_temp)) = 0;         
            co_index(count,i) = mean(co_index_temp);
        end
        count =  count +1;
    end    
     
    
end
% 
% figure(1)
% boxplot(ratio')

figure(2)
boxplot(co_index')
xlabel('Condition')
ylabel('Co-activation Index','FontSize',14)
set(gca,'TickDir','out')
ylim([-1 1])

%legend('High Gain','Low Gain')
