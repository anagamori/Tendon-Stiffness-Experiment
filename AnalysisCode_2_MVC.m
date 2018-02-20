%--------------------------------------------------------------------------
% Analysis code for tendon stiffness
%   MVC vs. CoV
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

load('MVC')

CoV_all = [];
MVC_all = MVC(:);
%MVC_all = [repelem(MVC(:,1),4);repelem(MVC(:,2),4)];
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
            else
                condition = ['Ex_' num2str(k)];            
            end
            cd (dataDirectory)            
            load ([condition '_Data'])
            cd (codeDirectory)
            
            Force = Data(1:endTime,end);
            CoV(i) = std(Force)/mean(Force);                                                      
        end 
        
    end
    CoV_all = [CoV_all CoV];
    
end

[R,P] = corrcoef(MVC_all,CoV_all')
[p,S] = polyfit(MVC_all,CoV_all',1);
f = polyval(p,MVC_all); 


figure(1)
plot(MVC_all,CoV_all,'o',MVC_all,f,'-')
