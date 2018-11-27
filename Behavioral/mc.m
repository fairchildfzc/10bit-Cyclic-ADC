clear all;
clc;
Num = 100;    %????????
Lum = 0;      %?????????
M = 2; N = 11; % ??M,N????????????????????
M = M*1000; N = N*1000; % ???????????M,N????
d_len = N+1; % ???????????????????????????????????????????????
Np = d_len/M; %?????????????????d_len???????????
adout(d_len) = 0; %???????????
% ?????CYCLIC ADC??????????????????????????????????OTA?GBW?
%????????????????????????????????GBW?????????
%?????????????????????
%???????????????????OTA???????????????????
global Vref; Vref = 1; %??????????????
global Cs1;global Cf1;global Cp1;global Com_os1a;global Com_os1b;global Adc1;global Ota_os1;%???????????
global Cs2;global Cf2;global Cp2;global Com_os2a;global Com_os2b;global Adc2;global Ota_os2;%???????????
global Com_os3a; global Com_os3b; global Com_os3c;                             %???2-bit ADC?????
C_val = 0.5e-12; del_C = 0.0008*C_val;       %??????????????????
del_Comos = 0;  del_Otaos = 0;  %????????OTA??????? 
global del_Comvn; global del_Otavn;%???????????????ADC???????????????????
del_Comvn = 0;  del_Otavn = 0;  %?????????OTA????????????OTA??????????????
%????Num????????????
for j=1:Num
    Cs1 = C_val+del_C*randn(1,1); Cf1 = C_val+del_C*randn(1,1); %???????????????
    Com_os1a = del_Comos*randn(1,1); Com_os1b = del_Comos*randn(1,1); %?????????????
    Ota_os1 = del_Otaos*randn(1,1); Adc1 = 1e4; Cp1= 0.1e-12;%????????OTA????Cp1???????
    Cs2 = C_val+del_C*randn(1,1); Cf2 = C_val+del_C*randn(1,1);
    Com_os2a = del_Comos*randn(1,1); Com_os2b = del_Comos*randn(1,1);
    Ota_os2 = del_Otaos*randn(1,1); Adc2 = 1e4; Cp2= 0.1e-12;%????????OTA????Cp2???????
    Com_os3a = del_Comos*randn(1,1); Com_os3b = del_Comos*randn(1,1);
    Com_os3c = del_Comos*randn(1,1);                %????2bit ADC?????????
%*****************for adc conversion*********************
    for i = 1:d_len                      %
        vi = 0.99*sin(i*2*pi/Np);  % ????????????????cyclic adc?????????????????adout?
        adout(i) = cyc_adc(vi);          %
    end
    
    %**************** ?SNDR?SFDR**********************
    %?????????�??????????�????????
    %******************** ????? *************************
    % ???0~1023???????????????????????????????????
    % ?????????????
    adout = adout - mean(adout);
    %******************** add hanning window *************************
    %adout = adout.*rot90(hanning(d_len)); % ??????????????????????????????????
    %******************** FFT?????? ****************************
    pow_spec = fft(adout).*conj(fft(adout)); %??????fft?????
    pow_spec = pow_spec/max(pow_spec);   %??????
    d_len2 = floor(d_len/2);
    pow_spec = pow_spec(1:d_len2); %??????????????????????
    %***************** ????? *****************************************
    xz = 0:1/d_len:(d_len2-1)/d_len;     %???xz???X?????????????????????xz??X????
%     plot(xz,10*log10(pow_spec)) %??????Y??????
%     title('ADC Output Spectrum')
%     xlabel('fi/fs')
%     ylabel('Power (dB)')
%     axis([0,0.5,-120,0])
%     grid
    %***************** ?SNDR *****************************************
    for i = 1:d_len2         % ?????????pow_spec????????????
        if pow_spec(i) > 0.95  %??????????????????1???????????0.95??
            i_max = i;          %??????????i_max
        end
    end
    widm = 0;                   %????????????=2*widm+1????????????widm=0??
    ps = sum(pow_spec(i_max-widm:i_max+widm));        %????????????????
    sndr = 10*log10(ps/(sum(pow_spec)-ps));  %?SNDR
    %***************** ?SFDR *****************************************
    pow_spec(i_max-widm:i_max+widm) = 0;    %???????0
    sfdr = -10*log10(max(pow_spec));   %??SFDR??????????
    if sndr > 60 && sfdr > 65
        Lum = Lum+1; %?????????????????????????????????
    end
end
Yield = Lum/Num; %?????????????/??????