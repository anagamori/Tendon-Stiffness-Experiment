%--------------------------------------------------------------------------
% Analysis code for tendon stiffness (single subject)
% Last update:2/10/18
% Function: Analyze individual subjects
% Note: Study No. 200
%       Run AnalysisCode_1 before this
%       Run this code before AnalysisCode_3.m to combine data
%--------------------------------------------------------------------------

close all
clear all
clc

Fs = 1000;
[b_f_high,a_f_high] = butter(4,[5,15]/(Fs/2),'bandpass');
[b_f_low,a_f_low] = butter(4,1/(Fs/2),'low');

pxxAll = zeros(4,201);
endTime = 50*Fs;
t = [1:50*Fs]./Fs;


for i = 11
    i
    if i < 10
        subjectID = ['20' num2str(i)];
    else
        subjectID = ['2' num2str(i)];
    end
    dataDirectory = ['/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment/Subject' subjectID '/'];
    codeDirectory = '/Users/akiranagamori/Documents/GitHub/Tendon-Stiffness-Experiment';
    
    for j = 1:2
        for k = 1:4
            
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
%             Force_high_temp = conv(Force_high_temp,gausswin(0.1*Fs));
%             Force_high_temp = Force_high_temp(1:endTime);
            Force_high = abs(Force_high);
            Force_high = conv(Force_high,gausswin(0.1*Fs));
            Force_high = Force_high(1:endTime);
            
            Force_low = filtfilt(b_f_low,a_f_low,Data(1:endTime,end));
            Force_low = Force_low-mean(Force_low);
            
            Force_phase = hilbert(Force_low);
            Force_anngle = angle(Force_phase);
            angles = -pi:pi/20:pi;    
            for n = 1:length(angles)-1
                index = find(Force_anngle>=angles(n)&Force_anngle<=angles(n+1));
                meanAmp_low(n) = mean(Force_low(index));
                meanAmp(n) = mean(Force_high(index));
            end
            [r,lags] = xcorr(Force_low,Force_high_temp,1000,'coeff');
            
            figure(j+10)
            plot(lags,r)
            hold on
            
            figure(j)
            subplot(2,1,1)
            plot(meanAmp_low)
            subplot(2,1,2)
            plot(meanAmp)
            hold on
                        
        end
        
        
    end
end

legend('High','Medim High','Medium Low','Low')
    
