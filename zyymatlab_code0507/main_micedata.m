clear;clc;close all;
%% ��ȡ���ֵ�ַ���½��ļ���
[fileName,pathName] = uigetfile('*.mat','ѡ��������ļ�');%������ȡ�����ļ�λ��
addpath(pathName);%���·��
dir_file=dir(fullfile(pathName,'*.mat'));%�г����ļ���������.mat�ļ�
num=length(dir_file);
for yi=1:num
mkdir([dir_file(yi).folder,'\',dir_file(yi).name(1:end-4),'-09']); %�������ļ���
newdir=[dir_file(yi).folder,'\',dir_file(yi).name(1:end-4),'-09'];%���ļ��е�ַ

filename=dir_file(yi).name;
pathname=[newdir,'\'];
load([dir_file(yi).folder,'\',dir_file(yi).name]);

signal=FP09(:,1);
t=FP09(:,2);
result_=1;%������
name1 = filename(1:4);
name1_12 = filename(1:12);
name2 = 0;
number = 1;
RIGHT = 0;
len = length(signal);
fs=1000; %����Ƶ��
% figure(1)
% plot(t,signal);
% xlim([t(1,1) t(len,1)]);xlabel('Time(s)');ylabel('mV');title('original signal');

%% % ȥ����
[signal_baseline,residual]=remove_baseline(t,signal);
% figure(2)
% plot(t,signal_baseline,t,residual); 
% xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('move-baseline signal');

%% 0.5-300Hz��ͨ�˲�
bandpass=[0.5 300];
signal_pass=bandpass_butter(signal_baseline,bandpass,fs);
% figure(3)
% plot(t,signal_pass);
% xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title(' bandpass-filter signal');

%% 50Hz�ݲ�
signal_notch=notch_iirnotch(signal_pass,fs);
% figure(4)
% plot(t,signal_notch); 
% xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('50Hz-notch signal');

%% �ж�theta

delta_fre=[2 4];
theta_fre=[5 10];
delta = bandpass_butter(signal_notch,delta_fre,fs);
theta = bandpass_butter(signal_notch,theta_fre,fs);

N = length(theta);
window = 2000;    %���ڴ�С 2s
k=[];
for i=1:floor(len/2000)
        temp_theta1 = theta((i-1)*window+1:i*window,1);
        temp_delta1 = delta((i-1)*window+1:i*window,1);
        [signal_psd f]=psd(temp_theta1,fs);
        p1 = bandpower(signal_psd,f,'psd'); 
        [signal_psd f]=psd(temp_delta1,fs);
        p2 = bandpower(signal_psd,f,'psd'); 
        k(i,1) = p1;   
        k(i,2) = p2;  
        k(i,3) = p1/p2;  
        k(i,4) = t((i-1)*window+1,1);   
end
steps=length( k(:,3));
for i=3:steps
        if k(i,3)>4 && k(i-1,3)>4 && k(i-2,3)>4
            k(i,5)=1;
            k(i-1,5)=1;
            k(i-2,5)=1;
        end
end

theta_period=[];
m=0;
n=0;
if k(1,5)==1
    m=m+1;
    theta_period(m,1)=k(1,4);
    for i=2:steps-1
        if k(i,5)==1 && k(i+1,5)==0
             n=n+1;
            theta_period(n,2)=k(i,4);
        end
        if k(i,5)==0 && k(i+1,5)==1
            m=m+1;
            theta_period(m,1)=k(i,4);
        end
    end
 else  
     for i=1:steps-1
        if k(i,5)==0 && k(i+1,5)==1
            m=m+1;
            theta_period(m,1)=k(i,4);
        end
        if k(i,5)==1 && k(i+1,5)==0
          n=n+1;
            theta_period(n,2)=k(i,4);
        end  
     end
end

%%
fg=1;
for rane_i=1:1:length(theta_period(:,1))%��
    if fg==11 break;end
    if theta_period(1,1) < 1.5
        theta_period(1,1) = 2;
    end
for S_T=theta_period(rane_i,1):1:floor(len/1000-6) %line_j,rane_i
    if fg==16 break;end
    E_T=S_T+5;
    
%% ʱƵͼ
signal_filter=signal_notch((S_T-1.5)*1000:(E_T+1.5)*1000,1);
movingwin=[3 0.05]; 
params.Fs=fs; 
params.pad=2;
params.tapers=[3 5];
params.fpass=[0 20];
[S1,t1,f]=mtspecgramc(signal_filter,movingwin,params);
figure(10)
% imagesc(t,f,[10*log10(S1)]') %Plot spectrogrm    /dB
colormap(jet) 
imagesc(t1-1.5,f,(S1)') %Plot spectrogrm    /mV2
axis xy; 
h=colorbar;
h.Label.String = 'Power spectral density(mV^2/Hz)';
h.Label.FontSize = 11;
title('Time frequency analysis');
xlabel('Time(s)'); ylabel('Frequency(Hz)');
title_TF_time_fre = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '-Time frequency analysis');
title_TF_time_fre = strcat(title_TF_time_fre, '.png');
saveas(figure(10),title_TF_time_fre);
  

%% ���ͼ
signal_filter_A_F=signal_notch(S_T*1000:E_T*1000,1);
lfp=signal_filter_A_F';
srate = 1000;
data_length = length(lfp);

% Define the amplitude- and phase-frequencies
PhaseFreq_BandWidth=0.25;     %��Ƶ��λ����
AmpFreq_BandWidth=10;      %��Ƶ��ֵ����
PhaseFreqVector=4-PhaseFreq_BandWidth/2:PhaseFreq_BandWidth:12-PhaseFreq_BandWidth/2;    %��Ƶ��λ��Χ
AmpFreqVector=30-AmpFreq_BandWidth/2:AmpFreq_BandWidth:150-AmpFreq_BandWidth/2;    %��Ƶ��ֵ��Χ

% Define phase bins
nbin = 18; % number of phase bins
position=zeros(1,nbin); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbin;
for j=1:nbin 
    position(j) = -pi+(j-1)*winsize; 
end

% Pre-allocating 
Comodulogram=single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
AmpFreqTransformed = zeros(length(AmpFreqVector), data_length);
PhaseFreqTransformed = zeros(length(PhaseFreqVector), data_length);

% Obtaining the ��Ƶ ��ֵ time-series
for ii=1:length(AmpFreqVector)
    Af1 = AmpFreqVector(ii); % selecting frequency (low cut)
    Af2=Af1+AmpFreq_BandWidth; % selecting frequency (high cut) 
    AmpFreq=eegfilt(lfp,srate,Af1,Af2); % filtering
    AmpFreqTransformed(ii, :) = abs(hilbert(AmpFreq)); % getting the amplitude envelope
end

% Obtaining the ��Ƶ ��λ time-series
for jj=1:length(PhaseFreqVector)
    Pf1 = PhaseFreqVector(jj); % selecting frequency (low cut)
    Pf2 = Pf1 + PhaseFreq_BandWidth; % selecting frequency (high cut)
    PhaseFreq=eegfilt(lfp,srate,Pf1,Pf2); % filtering 
    PhaseFreqTransformed(jj, :) = angle(hilbert(PhaseFreq)); % getting the phase time series
end

% Compute MI and comodulogram
counter1=0;
for ii=1:length(PhaseFreqVector)
counter1=counter1+1;

    Pf1 = PhaseFreqVector(ii);
    Pf2 = Pf1+PhaseFreq_BandWidth;
    
    counter2=0;
    for jj=1:length(AmpFreqVector)
    counter2=counter2+1;
    
        Af1 = AmpFreqVector(jj);
        Af2 = Af1+AmpFreq_BandWidth;
        [MI,MeanAmp]=ModIndex_v2(PhaseFreqTransformed(ii, :), AmpFreqTransformed(jj, :), position);
        Comodulogram(counter1,counter2)=MI;
    end
end

% Plot comodulogram
figure(12)
colormap(jet) 
contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Comodulogram',30,'lines','none')
% set(gca,'fontsize',14)
ylabel('Amplitude frequency(Hz)')
xlabel('Phase frequency(Hz)')
title('Comodulogram plot')
h=colorbar;
h.Label.String = 'Modulation index';
h.Label.FontSize = 11;
title_TF_A_F = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '-Comodulogram plot');
title_TF_A_F = strcat(title_TF_A_F, '.png');
saveas(figure(12),title_TF_A_F);

%% �жϲ���������
tfi=imread(title_TF_time_fre);%����ʱƵͼ
%imshow(img);
tfib=tfi(:,:,3);%��ȡbͨ�����������ܶȸߡ���ͼ��Ϊ��ȻƵĲ���bͨ������Ϊ0
tfpiece=tfib(320:450,110:699);%��ȡ6~10hz���ֽ���ʶ��
%imshow(tfpiece);
k=find(tfpiece<5);%ѡ��5��Ϊ��ֵ
Nhigh=length(k);%Ƶ���ں�ɫ��������������
%���Ժ������õ�ʱƵͼ��������9k��������w�������õ��ձ���5k����
if Nhigh>9000  %ɸѡ�Ӵ�
    other=tfib([58:319,451:575],[110:699]);%��ȡͼƬ����Ƶ������
    Nother=length(find(other<5));%ɸѡ�Ӵ�
    if Nother>3000 %����һ����Զ���5000
        RIGHT=0;
    else RIGHT=1; %���Ӵ�������һ��
    end
end
%ɸѡ����ȵ�ͼ
if RIGHT==1
    cgi=imread(title_TF_A_F);%��������ȵ�ͼ
    cgib=cgi(:,:,3);
    %imshow(cgib)
    cgib=imcomplement(imbinarize(cgib,0.2));%��ֵ��ֻ������ȻƲ��ڰ׷�ת
    cgib=cgib(58:575,110:690)
% cgpiece=cgib(290:410,110:690);%�ָ�70~90����
    %figure(1);imshow(cgi);figure(2);imshow(cgib);figure(3);imshow(cgpiece);
    stahigh=regionprops(cgib);%������ͨ����Ŀ��
    ncgh=length(stahigh);%Ŀ����
    higharea=0;
    for i=1:ncgh %ͳ��Ŀ������
        higharea=higharea+stahigh(i).Area;
    end
    
    if 0<ncgh && ncgh<3 && higharea>5000  %�ж�������1.��70`90��Ŀ����2�����ڣ�2.����������֮�ʹ���3k���߱�׼5k��
%         cgother=cgib([58:289,411:575],[110:690]);
%         staother=regionprops(cgother);
%         ncgother=length(staother);
%         otherarea=0;
%         for i=1:ncgother %ͳ��Ŀ������
%             otherarea=otherarea+staother(i).Area;
%         end
%         if (ncgother>2 && otherarea>4000)||otherarea>5000 %���������Ӵ������ϸ߲�����Ҫ��
            RIGHT=1;
%         else RIGHT=0; %��ʱ����ͼ������Ҫ��
%         end
    else RIGHT=0;%70~90��Ŀ�겻����Ҫ��
    end  
    
end

if RIGHT == 0
      delete(title_TF_time_fre);
      delete(title_TF_A_F);
else
    %����PSD
    [signal_psd f]=psd(signal_filter_A_F,fs);
    figure(9)
    plot(f,signal_psd);  %���ƹ������ܶ�
    xlim([0 300]);xlabel('Frequency(Hz)');ylabel('Power spectral density(mV^2/Hz)');title('Power spectral densities');
    title_TF_PSD = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '-Power spectral densities');
    title_TF_PSD = strcat(title_TF_PSD, '.png');
    saveas(figure(9),title_TF_PSD);
    power=[];
    power(1,1) = bandpower(signal_psd,f,'psd');  %����ƽ������
    %�����Ƶ����
theta_fre=[4 12];
gammal_fre=[30 50];
gammam_fre=[50 100];
gammah_fre=[100 150];
gammal_30_80_fre=[30 80];
gamma_30_100_fre=[30 100];
gamma_80_150_fre=[80 150];
theta_filter = bandpass_butter(signal_filter_A_F,theta_fre,fs);
gammal_filter = bandpass_butter(signal_filter_A_F,gammal_fre,fs);
gammam_filter = bandpass_butter(signal_filter_A_F,gammam_fre,fs);
gammah_filter = bandpass_butter(signal_filter_A_F,gammah_fre,fs);
gammal_30_80_filter = bandpass_butter(signal_filter_A_F,gammal_30_80_fre,fs);
gamma_30_100_filter = bandpass_butter(signal_filter_A_F,gamma_30_100_fre,fs);
gamma_80_150_filter = bandpass_butter(signal_filter_A_F,gamma_80_150_fre,fs);
[theta_psd f]=psd(theta_filter,fs);
[gammal_psd f]=psd(gammal_filter,fs);
[gammam_psd f]=psd(gammam_filter,fs);
[gammah_psd f]=psd(gammah_filter,fs);
[gammal_30_80_psd f]=psd(gammal_30_80_filter,fs);
[gamma_30_100_psd f]=psd(gamma_30_100_filter,fs);
[gamma_80_150_psd f]=psd(gamma_80_150_filter,fs);
power(2,1) = bandpower(theta_psd,f,'psd'); 
power(3,1) = bandpower(gammal_psd,f,'psd'); 
power(4,1) = bandpower(gammam_psd,f,'psd'); 
power(5,1) = bandpower(gammah_psd,f,'psd'); 
power(6,1) = bandpower(gammal_30_80_psd,f,'psd'); 
power(7,1) = bandpower(gamma_30_100_psd,f,'psd'); 
power(8,1) = bandpower(gamma_80_150_psd,f,'psd'); 
%����MI
[MI_gammal,MeanAmp_gammal] = ModIndex_v1(lfp,srate,4,12,30,50,position);
[MI_gammam,MeanAmp_gammam] = ModIndex_v1(lfp,srate,4,12,50,100,position);
[MI_gammah,MeanAmp_gammah] = ModIndex_v1(lfp,srate,4,12,100,150,position);
[MI_gamma_30_80,MeanAmp_gamma_30_80] = ModIndex_v1(lfp,srate,4,12,30,80,position);
[MI_gamma_30_100,MeanAmp_gamma_30_100] = ModIndex_v1(lfp,srate,4,12,30,100,position);
[MI_gamma_80_150,MeanAmp_gamma_80_150] = ModIndex_v1(lfp,srate,4,12,80,150,position);
figure(13)
bar(10:20:720,[MeanAmp_gammal,MeanAmp_gammal]/sum(MeanAmp_gammal),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[30-50]-Modulation index = ' num2str(MI_gammal)]);
title_TF = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '[30-50]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(13),title_TF);
figure(14)
bar(10:20:720,[MeanAmp_gammam,MeanAmp_gammam]/sum(MeanAmp_gammam),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[50-100]-Modulation index = ' num2str(MI_gammam)]);
title_TF = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '[50-100]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(14),title_TF);
figure(15)
bar(10:20:720,[MeanAmp_gammah,MeanAmp_gammah]/sum(MeanAmp_gammah),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[100-150]-Modulation index = ' num2str(MI_gammah)]);
title_TF = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '[100-150]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(15),title_TF);
figure(16)
bar(10:20:720,[MeanAmp_gamma_30_80,MeanAmp_gamma_30_80]/sum(MeanAmp_gamma_30_80),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[30-80]-Modulation index = ' num2str(MI_gamma_30_80)]);
title_TF = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '[30-80]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(16),title_TF);
figure(17)
bar(10:20:720,[MeanAmp_gamma_80_150,MeanAmp_gamma_80_150]/sum(MeanAmp_gamma_80_150),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[30-100]-Modulation index = ' num2str(MI_gamma_30_100)]);
title_TF = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '[30-100]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(17),title_TF);
figure(18)
bar(10:20:720,[MeanAmp_gamma_30_100,MeanAmp_gamma_30_100]/sum(MeanAmp_gamma_30_100),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[80-150]-Modulation index = ' num2str(MI_gamma_80_150)]);
title_TF = strcat(pathname,num2str(name1_12),'-',num2str(S_T),'-',num2str(E_T),'s', '[80-150]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(18),title_TF);
MI = [MI_gammal MI_gammam MI_gammah MI_gamma_30_80 MI_gamma_30_100 MI_gamma_80_150]';
%���ݱ���
mice_name = strcat(pathname,num2str(name1),'-data.xlsx');
Title_A = {'name_' 'time' 'all power/mV^2' 'theta[4 12]' 'gamma[30 50]' 'gamma[50 100]' 'gamma[100 150]' 'gamma[30 80]' 'gamma[30 100]' 'gamma[80 150]' 'gamma[30 50]' 'gamma[50 100]' 'gamma[100 150]' 'gamma[30 80]' 'gamma[30 100]' 'gamma[80 150]'};
mice_Bname = strcat(num2str(S_T),'-',num2str(E_T),'s-power');
str_name=['A',num2str(1+result_)];
str_time=['B',num2str(1+result_)];
str_all_power=['C',num2str(1+result_)];
str_MI=['K',num2str(1+result_)];
xlswrite(mice_name, Title_A, 1, 'A1');
xlswrite(mice_name, {filename},1, str_name);
xlswrite(mice_name, {mice_Bname}, 1, str_time);
xlswrite(mice_name, power',1, str_all_power);
xlswrite(mice_name, MI',1, str_MI);
name2 = num2str(filename(1:12));
if name2 ~= name2
    number = 1;
end
PSD_name = strcat(pathname,name2,'-PSD-data.xlsx');
PSD_Bname = strcat(num2str(S_T),'-',num2str(E_T),'s', '-PSD');
xlswrite(PSD_name, {PSD_Bname}, number, 'A1');
xlswrite(PSD_name, signal_psd, number, 'A2');
Title_PSD_f = {'PSD-f/Hz'};
xlswrite(PSD_name, Title_PSD_f, number, 'B1');
xlswrite(PSD_name, f', number, 'B2');
result_= result_ + 1;
number = number + 1;
fg=fg+1;
end
end
end
end