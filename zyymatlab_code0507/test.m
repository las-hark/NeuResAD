clear;clc;close all;
%% 获取名字地址
[fileName,pathName] = uigetfile('*.mat','选择待处理文件');%弹窗获取处理文件位置
addpath(pathName);%添加路径
dir_file=dir(fullfile(pathName,'*.mat'));%列出该文件夹下所有.mat文件
num=length(dir_file);
 micechannel=[
        '63710';'63810';'64210';'64310';'64610';'64910';'65009';
        '66810';'66909';'67009';'67109';'67210';'67310';'67510';
        '63301';'65508';'65606';'66101';'66408';'35008'];


for yi=1:num
%     mkdir([dir_file(yi).folder,'\',dir_file(yi).name(1:end-4)]); %创建新文件夹
%     newdir=[dir_file(yi).folder,'\',dir_file(yi).name(1:end-4)];%新文件夹地址
    filename=dir_file(yi).name(1:end-4);%文件名
    pathname=[dir_file(yi).folder,'\'];%路径名
    savename=strcat(pathname,filename,'-psd.xlsx');
    xlswrite(savename,{"thetabegintime"},1,'A1');
    xlswrite(savename,{"thetaendtime"},1,'B1');
    xlswrite(savename,{"allpsd"},1,'C1');
    xlswrite(savename,{"thetapsd"},1,'D1');
    load([dir_file(yi).folder,'\',dir_file(yi).name]);%载入文件
   if  dir_file(yi).name(1:2)=='WU'
            channel='FP08';
   else
    for za=1:20
        zancunming=micechannel(za,1:3);
        if zancunming==dir_file(yi).name(2:4)
            chan=micechannel(za,4:5);
            channel=strcat('FP',chan);
        end
    end
   end
    FP=eval(channel);
    signal=FP(:,1);
    fs=1000; %采样频率
    ts=1/fs;
    t=ts:ts:length(FP)/1000;
    t=t';
    result_=1;%更换行
    name1 = filename(1:4);
    name1_12 = filename(1:12);
    name2 = 0;
    number = 1;
    RIGHT = 0;
    len = length(signal);
    
    % figure(1)
    % plot(t,signal);
    % xlim([t(1,1) t(len,1)]);xlabel('Time(s)');ylabel('mV');title('original signal');

    %% 去基线
    [signal_baseline,residual]=remove_baseline(t,signal);
    % figure(2)
    % plot(t,signal_baseline,t,residual); 
    % xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('move-baseline signal');

    %% 0.5-250Hz带通滤波
    bandpass=[0.5 250];
    signal_pass=bandpass_butter(signal_baseline,bandpass,fs);
    % figure(3)
    % plot(t,signal_pass);
    % xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title(' bandpass-filter signal');

    %% 50Hz陷波
    signal_notch=notch_iirnotch(signal_pass,fs);
    % figure(4)
    % plot(t,signal_notch); 
    % xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('50Hz-notch signal');

    %% 判断theta
    delta_fre=[2 4];
    theta_fre=[5 10];
    delta = bandpass_butter(signal_notch,delta_fre,fs);
    theta = bandpass_butter(signal_notch,theta_fre,fs);
    N = length(theta);
    window = 2000;    %窗口大小 2s
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
    %判断连续三个时间窗口大4
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
    % 求功率
    thetaperiodpoint=theta_period*1000;
    thetatimes=length(theta_period);
    for i=1:thetatimes
         pointstart=thetaperiodpoint(i,1);
         pointend=thetaperiodpoint(i,2);
         pointstart=uint32(pointstart);
         pointend=uint32(pointend);
         if pointend<=pointstart 
             break;
         end
         signal_filter_af=signal_notch(pointstart:pointend,1);
         %计算PSD
         [signal_psd f]=psd(signal_filter_af,fs);
         power=[];
         power(1,1) = bandpower(signal_psd,f,'psd');  %计算平均功率
         %计算分频功率
         theta_fre=[4 12];
         theta_filter = bandpass_butter(signal_filter_af,theta_fre,fs);
         [theta_psd f]=psd(theta_filter,fs);
         power(2,1)=bandpower(theta_psd,f,'psd'); %计算theta功率
         %保存
         strtemp=num2str(i+1);
         nameA=strcat('A',strtemp);
         nameB=strcat('B',strtemp);
         nameC=strcat('C',strtemp);
         nameD=strcat('D',strtemp);
         xlswrite(savename,theta_period(i,1),1,nameA)
         xlswrite(savename,theta_period(i,2),1,nameB)
         xlswrite(savename,power(1,1),1,nameC)
         xlswrite(savename,power(2,1),1,nameD)
    end
    %% 判断ripple
        %% 判断ripple
    ripple_fre=[100 250];
    ripple = bandpass_butter(signal_notch,ripple_fre,fs);
    Nr = length(ripple);
    %窗口大小 1ms
    kr=[];
%     for i=1:floor(len/10)
%         epb=(i-1)*10+1;epr=i*10;
%         temp_ripple = ripple(epb:epr,1);
%         temp_signal = signal_notch(epb:epr,1);
%         ripple_RMS=MSR(temp_ripple,1);%1ms步长下10个窗口均方差
%         signal_RMS=MSR(temp_signal,1);
% % %         signal_mean=mean(temp_signal);%背景平均幅值
% % %         signal_SD=std(temp_signal);%背景标准差
% % %         target=signal_mean+2*signal_SD;%阈值，背景平均幅度加2个标准差
%         kr(i,1) = ripple_RMS;
%         kr(i,2) = signal_RMS;
%         kr(i,3) = t(epb,1);
% % %         kr(i,2) = target;
% % %         kr(i,3) = ripple_RMS-target;%判段指标
% % %         kr(i,4) = t(epb,1);  %窗口对应时间
%     end
    for i=1:len-9
        epb=i;epr=i+9;
        temp_ripple = ripple(epb:epr,1);
        temp_signal = signal_notch(epb:epr,1);
        ripple_RMS=MSR(temp_ripple,10);%1ms步长下10个窗口均方差
        signal_RMS=MSR(temp_signal,10);
        kr(i,1) = ripple_RMS;
        kr(i,2) = signal_RMS;
        kr(i,3) = t(epb,1);
    end
    signal_mean=mean(kr(:,2));%背景均方根均值
    signal_sd=std(kr(:,2));%标准差
    target=signal_mean+5*signal_sd;%阈值
    target1=signal_mean+2*signal_sd;
    steps=length(kr(:,1));
    kr(:,6)=zeros(steps,1);kr(:,7)=zeros(steps,1);
    for i=1:steps
         kr(i,4)=kr(i,1)-target;
         kr(i,5)=kr(i,1)-target1;
         if kr(i,4)>0
            kr(i,6)=1;
         end
         if kr(i,5)>0
            kr(i,7)=1;
         end
    end
    
    ripple_period=[];
    m=0;
    n=0;
    
%     [mr,nr]=size(kr);
%     if nr==4 
%         continue;
%     end
    
    if kr(1,6)==1
        m=m+1;
        ripple_period(m,1)=kr(1,3);
        for i=2:steps-1
            if kr(i,7)==1 && kr(i+1,7)==0
                 n=n+1;
                ripple_period(n,2)=kr(i,3)+0.01;%结束时间
            end
            if kr(i,7)==0 && kr(i+1,7)==1
                m=m+1;
                ripple_period(m,1)=kr(i,3);%起始时间
            end
        end
     else  
         for i=1:steps-1
            if kr(i,7)==0 && kr(i+1,7)==1
                m=m+1;
                ripple_period(m,1)=kr(i,3);
            end
            if kr(i,7)==1 && kr(i+1,7)==0
               n=n+1;
               ripple_period(n,2)=kr(i,3)+0.01;
            end  
         end
    end
%     %找2sd起始终止位点
%     ripple5_point=uint32(ripple_period*1000);
%     ripple5times=length(ripple_period(:,1));
%     ripple_event=[];
%     for i=1:ripple5times
%          pointstart5=ripple5_point(i,1);
%          pointend5=ripple5_point(i,2);
%          if pointend5<=pointstart5 
%              break;
%          end
%          %begintime
%          for j=pointstart5:-1:2
%              if j==2
%                 ripple_event(i,1)=kr(1,3);break;
%              end
%              if kr(j,7)==1 && kr(j-1,7)==0
%                 ripple_event(i,1)=kr(j,3); break;
%              end
%          end
%          %endtime
%          for j=pointend5:1:step-1
%               if j==step-1
%                 ripple_event(i,1)=kr(step-1,3);break;
%              end
%              if kr(j,7)==1 && kr(j+1,7)==0
%                 ripple_event(i,2)=kr(j,3); break;
%              end
%          end
%          
%     end
%     

    %% 求功率
    rippleperiodpoint=ripple_period*1000;
    rippletimes=length(ripple_period(:,1));
    for i=1:rippletimes
         pointstart=rippleperiodpoint(i,1);
         pointend=rippleperiodpoint(i,2);
         pointstart=uint32(pointstart);
         pointend=uint32(pointend);
         if pointend<=pointstart 
             break;
         end
         signal_filter_af=signal_notch(pointstart:pointend,1);
         %计算PSD
         [signal_psd f]=psd(signal_filter_af,fs);
         power2=[];
         power2(1,1) = bandpower(signal_psd,f,'psd');  %计算平均功率
         %计算分频功率
         ripple_filter = ripple(pointstart:pointend,1);
         [ripple_psd f]=psd(ripple_filter,fs);
         power2(2,1)=bandpower(ripple_psd,f,'psd'); %计算功率
         %保存
%          strtemp=num2str(i+1);
%          nameA=strcat('A',strtemp);
%          nameB=strcat('B',strtemp);
%          nameC=strcat('C',strtemp);
%          nameD=strcat('D',strtemp);
%          xlswrite(savename,ripple_period(i,1),2,nameA)
%          xlswrite(savename,ripple_period(i,2),2,nameB)
%          xlswrite(savename,power2(1,1),2,nameC)
%          xlswrite(savename,power2(2,1),2,nameD)
    end
end
