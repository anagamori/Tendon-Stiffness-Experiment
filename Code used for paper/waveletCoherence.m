function [time,freqs,waveletCoherence] = waveletCoherence(input1,input2,Fs,freqs,ncycle)
time = 0:1/Fs:(length(input1)-1)/Fs;
%time = time;
complexTFR1 = complex(zeros(length(freqs),length(input1)));
complexTFR2 = complex(zeros(length(freqs),length(input1)));
waveletCoherence = zeros(length(freqs),length(input1));

for f = 1:length(freqs)
    % Create a time vector for wavelet at a given frequency
    timeWavelet = [1:round(ncycle*Fs./freqs(f))]./Fs;
    % Create taper with gaussian window
    taper = hann(length(timeWavelet));
    % Normalize the taper with sum of the elements
    taper = taper./sum(taper);
    
    % Create a complex sinusoid for a given freqeuncy with the specified
    % length
    sinewave = exp(2*sqrt(-1)*pi*freqs(f).*timeWavelet);
    % Taper the sinewave
    kernel = sinewave.*taper';
    % Compute wavelet transform of the input signal
    
    complexTFR1(f,:) = 2*conv(input1,kernel,'same');
    complexTFR2(f,:) = 2*conv(input2,kernel,'same');
    PhaseLocking = exp(1i*(angle(complexTFR1(f,:))-angle(complexTFR2(f,:))));
    amp1 = abs(complexTFR1(f,:));
    amp2 = abs(complexTFR2(f,:));
    
    taper2 = rectwin(length(timeWavelet));
    taper2 = taper2./sum(taper2);
    numerator = abs(conv(amp1.*amp2.*PhaseLocking,taper2,'same')).^2;
    % numerator = abs(conv(complexTFR1(f,:).*conj(complexTFR2(f,:)),taper,'same')).^2;
    % denominator = conv(abs(complexTFR1(f,:)).^2.*abs(complexTFR2(f,:)).^2,taper,'same');
    denominator = conv(amp1.^2,taper2,'same').*conv(amp2.^2,taper2,'same');
    
    % denominator = sum(amp1.^2).*sum(amp2.^2);
    waveletCoherence(f,:) = numerator./denominator;
end

% figure()
% imagesc(time,freqs,waveletCoherence)
% xlabel('time (s)')
% ylabel('Frequency (Hz)')
% colorbar

end