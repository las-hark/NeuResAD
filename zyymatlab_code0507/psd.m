function [signal_psd f1]=psd(data,fs);
% Nfft=2048;       %����Ҷ�任����
% nw=3;            %Ϊʱ������
% [Pxx1,f]=pmtm(data,nw,Nfft,fs); %�öര�ڷ����ƹ�����
% % signal_psd=10*log10(Pxx1);    %ylabel('PSD(dB/Hz)');
% signal_psd=Pxx1;   

% mtspectrumpt�������ܶ�  �öര�ڷ����ƹ�����
params.Fs=fs; 
params.pad=2; %����Ҷ�任����2048
params.tapers=[3 5];  %Ϊʱ������
params.fpass=[0 500];
[signal_psd,f1]=mtspectrumc(data,params);
% figure
% plot_vector(S,f1); 
% % plot(f1,S);
% xlabel('frequency(Hz)');ylabel('PSD(dB/Hz)');
% title('Multitaper PSD (mtspectrumpt)');
end

