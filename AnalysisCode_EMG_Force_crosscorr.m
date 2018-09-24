%--------------------------------------------------------------------------
% Analysis code for tendon stiffness
%   EMG
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

windowSize = 0.1*Fs;
subjectNo = 1:12;

pxx_mat = zeros(length(subjectNo),201);
pxx_all = zeros(4,201);

for j = 1
    for k = 2:2:4
        for i = 4 %:length(subjectNo)
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
                MVC_file = 'Fl_MVC';
                MVC_ant_file = 'Ex_MVC';
                muscle = 1:2;
                muscle_ant = 3:4;
            else
                condition = ['Ex_' num2str(k)];
                MVC_file = 'Ex_MVC';
                MVC_ant_file = 'Fl_MVC';
                muscle = 3:4;
                muscle_ant = 1:2;
            end
            
            cd (dataDirectory)            
            load ([condition '_Data'])
            Data_temp = Data;
            load ([MVC_file '_Data'])
            Data_MVC_temp = Data;
            load ([MVC_ant_file '_Data'])
            Data_MVC_ant_temp = Data;
            cd (codeDirectory)
            
            MVC_1 = Data_MVC_temp(:,muscle(1));
            MVC_1_conv = conv(MVC_1,gausswin(windowSize));
            peak_MVC = max(MVC_1_conv(10:length(MVC_1)));
            
            EMG_1 = Data_temp(1:endTime,muscle(1));
            EMG_1_conv = conv(EMG_1,gausswin(windowSize));
            EMG_1_amp = EMG_1_conv(1:length(EMG_1));
            EMG_1_amp = EMG_1_amp./peak_MVC;
            
            Force = Data_temp(1:endTime,end);
            
            
            MVC_2 = Data_MVC_temp(:,muscle(2));
            MVC_2_conv = conv(MVC_2,gausswin(windowSize));
            peak_MVC = max(MVC_2_conv(10:length(MVC_2)));
            
            EMG_2 = Data_temp(1:endTime,muscle(2));
            EMG_2_conv = conv(EMG_2,gausswin(windowSize));
            EMG_2_amp = EMG_2_conv(1:length(EMG_2));                      
         
        end
        
        [x,lag] = xcorr(EMG_1_amp-mean(EMG_1_amp),Force-mean(Force),5000,'coeff');
        
        figure(1)
        plot(lag,x)
        hold on
    end
    
end
