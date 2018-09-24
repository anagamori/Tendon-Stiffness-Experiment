%partial coherence  final version use this for everything it is correct
function [original residual frequencies L] = fullpcoh_test(full_predictor,full_data1,full_data2,taper,FractionOverlap,Fs)
%[original residual frequencies L] = fullpcoh_test(full_predictor,full_data1,full_data2,taper,FractionOverlap,Fs)
%assume data1 data2 and predictor are x y and z

%note seglen is now samples

seglen=length(taper);
overlp=round(FractionOverlap*seglen);

[pgram1,frequencies,T] = spectrogram(full_data1,taper,overlp,seglen,Fs); 
[pgram2,frequencies,T] = spectrogram(full_data2,taper,overlp,seglen,Fs); 
[pgram3,frequencies,T] = spectrogram(full_predictor,taper,overlp,seglen,Fs); 

for i=1:size(pgram1,1)
    predictor=[];data1=[];data2=[];
    predictor=pgram3(i,:);
    data1=pgram1(i,:);
    data2=pgram2(i,:);


predictor=predictor(:);
data1=data1(:);
data2=data2(:);
%cross spectra
xy=mean(data1.*conj(data2));
%yx=mean(data2.*conj(data1));
xz=mean(data1.*conj(predictor));
zx=mean(predictor.*conj(data1));
yz=mean(data2.*conj(predictor));
zy=mean(predictor.*conj(data2));

%auto spectra
xx=mean(data1.*conj(data1));
yy=mean(data2.*conj(data2));
zz=mean(predictor.*conj(predictor));

%partial cross spectra
xy_z=xy-(xz*zy)/zz;
%partial auto spectra
xx_z=xx-(xz*zx)/zz;
yy_z=yy-(yz*zy)/zz;

%coherence between x and y
cohxy=(abs(xy)^2)/(xx*yy);

%partial coherence between x and y removing z
cohxy_z=(abs(xy_z)^2)/(xx_z*yy_z);



if isnan(cohxy_z) || cohxy_z==inf
    display('make sure signals are unique, NaN returned')
end
residual(i)=cohxy_z;
original(i)=cohxy;
end%for each freq
L=round(length(full_data1)/(seglen));
end %function



%predict a single signal X based on 2 predictors, P1 and P2:
%CohX_P1P2 = CohXP2 + [ CohXP1_P2*( 1 - CohXP2 ) ] 
%PcohXY_ab = xy-[xa xb][aa ab;ba bb]^-1[ay;by], if you assume a and b are
%independent from each other, xy- [ xa*ay/aa + xb*by/bb ] which is
%essentially just combining two partial cross spectra... so xy_a would be
%so for input 1 and 2 influencing signals 4 and 3,
%f43_12 = f43 - [f41  f42] [f11 f12;f21 f22] [f13 f23];
%and for inputs a,b,and c influencing the correlation between 4 and 3,
%so if it was f43_abc = f43- [f4a f4b f4c][faa fab fac;fba fbb fbc;fca fcb fcc][fa3;fb3;fc3];





