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


CoV_mat = zeros(12,4);
rms_mat = zeros(12,4);

count = 1;

subjectNo = 1:12;
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
            else
                condition = ['Ex_' num2str(k)];
            end
            
            cd (dataDirectory)
            load ([condition '_Data'])
            cd (codeDirectory)
            
            Force = Data(1:endTime,end);
                    
            CoV_mat(i,count) = std(Force)/mean(Force);
        end      
        count = count + 1;
    end    
end

CoV_mat = CoV_mat*100;
CoV_plot = [CoV_mat(:,2) CoV_mat(:,1) CoV_mat(:,4) CoV_mat(:,3)];
%
%save('CoV_all','CoV_plot')


figure(1)
boxplot(CoV_plot)
ylabel('CoV (%)','FontSize',14)



