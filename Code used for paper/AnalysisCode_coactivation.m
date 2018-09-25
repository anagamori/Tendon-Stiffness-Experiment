close all
clear all
clc

Fs = 1000;

endTime = 50*Fs;
t = [1:50*Fs]./Fs;

subjectNo = 1:12;

[b,a] = butter(4,5/(Fs/2),'low');


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
            dataDirectory = ['/Users/akira/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
            codeDirectory = '/Users/akira/Documents/GitHub/Tendon-Stiffness-Experiment/Code used for paper';
            
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
            cd (codeDirectory)
            
            
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1_z = zscore(EMG_1);
            EMG_1_env = filtfilt(b,a,EMG_1_z);
            EMG_1_env = EMG_1_env-mean(EMG_1_env);   
            
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2_z = zscore(EMG_2);
            EMG_2_env = filtfilt(b,a,EMG_2_z);
            EMG_2_env = EMG_2_env-mean(EMG_2_env);   
            
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
%ylim([-1 1])

%legend('High Gain','Low Gain')
