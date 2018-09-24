%--------------------------------------------------------------------------
% Analysis code
%   EMG-Force Coherence
% Last update:
% Note: Study No. 200
%       Run AnalysisCode_1 before this
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;

subjectNo = 1:12;

Cxy_mat = zeros(length(subjectNo),1001);
Cxy_2_mat = zeros(length(subjectNo),1001);
Cxy_all = zeros(4,1001);
Cxy_2_all = zeros(4,1001);

for j = 1:2
    for k = 2
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
            
            Force = Data_temp(:,end);
            Force = Force - mean(Force);
            EMG_1 = Data_temp(:,muscle(1));
            EMG_1 = EMG_1-mean(EMG_1);
            EMG_2 = Data_temp(:,muscle(2));
            EMG_2 = EMG_2-mean(EMG_2);
            
            [Cxy,freq] = mscohere(Force,EMG_1,gausswin(5*Fs),2.5*Fs,0:0.1:100,Fs);
            [Cxy_2,freq] = mscohere(Force,EMG_2,gausswin(5*Fs),2.5*Fs,0:0.1:100,Fs);
            Cxy_mat(i,:) = smooth(Cxy,10); 
            Cxy_2_mat(i,:) = smooth(Cxy_2,10);      
%             save(['Cxy_Force_' num2str(j) '_' num2str(k)],'Cxy_mat')
%             save(['Cxy_Force_2_' num2str(j) '_' num2str(k)],'Cxy_2_mat')
        end
        Cxy_all(k,:) = smooth(mean(atanh(Cxy_mat)),10);           
        Cxy_2_all(k,:) = smooth(mean(atanh(Cxy_2_mat)),10);           
    end
    figure(1)
plot(freq,tanh(Cxy_all))
title('Force - Muscle 1')
hold on

figure(2)
plot(freq,tanh(Cxy_2_all))
title('Force - Muscle 2')
hold on
end

% figure(1)
% plot(freq,tanh(Cxy_all))
% title('Force - Muscle 1')
% 
% figure(2)
% plot(freq,tanh(Cxy_2_all))
% title('Force - Muscle 2')

%%
close all
j = 1;
load(['Cxy_Force_' num2str(j) '_' num2str(2)])
Cxy_mat_1 = Cxy_mat;
load(['Cxy_Force_'  num2str(2) '_' num2str(2)])
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

