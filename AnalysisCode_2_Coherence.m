%--------------------------------------------------------------------------
% Analysis code for tendon stiffness
%   Coherence
% Last update:2/17/18
% Note: Study No. 200
%       Run AnalysisCode_1 before this
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;

endTime = 50*Fs;
t = [1:50*Fs]./Fs;

subjectNo = 1:12;

Cxy_mat = zeros(length(subjectNo),1001);
Cxy_all = zeros(4,1001);

for j = 1:2
    for k = 1
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
                                   
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1 = EMG_1-mean(EMG_1);
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2 = EMG_2-mean(EMG_2);
            
            [Cxy,freq] = mscohere(EMG_1,EMG_2,gausswin(2*Fs),1*Fs,0:0.1:100,Fs);
            Cxy_mat(i,:) = smooth(Cxy,10);          
            save(['Cxy_' num2str(j) '_' num2str(k)],'Cxy_mat')
        end
        Cxy_all(k,:) = smooth(mean(atanh(Cxy_mat)),10);                       
    end
    figure(1)
    plot(freq,tanh(Cxy_all))
    hold on
end



%%
j = 1;
load(['Cxy_' num2str(j) '_' num2str(1)])
Cxy_mat_1 = Cxy_mat;
load(['Cxy_'  num2str(j) '_' num2str(4)])
Cxy_mat_2 = Cxy_mat;

for f = 1:length(freq)
    [h,p(f)] = ttest(Cxy_mat_1(:,f),Cxy_mat_2(:,f));  
    if p(f) > 0.2
        p(f) = 0.2;
    end
end

figure(5)
subplot(2,1,1)
plot(freq,mean(Cxy_mat_1))
hold on 
plot(freq,mean(Cxy_mat_2))
subplot(2,1,2)
plot(freq,p)

