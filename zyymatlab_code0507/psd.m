function [signal_psd f1]=psd(data,fs);
% Nfft=2048;       %傅里叶变换点数
% nw=3;            %为时间带宽积
% [Pxx1,f]=pmtm(data,nw,Nfft,fs); %用多窗口法估计功率谱
% % signal_psd=10*log10(Pxx1);    %ylabel('PSD(dB/Hz)');
% signal_psd=Pxx1;   

% mtspectrumpt功率谱密度  用多窗口法估计功率谱
params.Fs=fs; 
params.pad=2; %傅里叶变换点数2048
params.tapers=[3 5];  %为时间带宽积
params.fpass=[0 500];
[signal_psd,f1]=mtspectrumc(data,params);
% figure
% plot_vector(S,f1); 
% % plot(f1,S);
% xlabel('frequency(Hz)');ylabel('PSD(dB/Hz)');
% title('Multitaper PSD (mtspectrumpt)');
end

