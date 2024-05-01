clear;clc;close all;
%% 获取名字地址
[fileName,pathName] = uigetfile('*.mat','选择待处理文件');%弹窗获取处理文件位置
addpath(pathName);%添加路径
dir_file=dir(fullfile(pathName,'*.mat'));%列出该文件夹下所有.mat文件
num=length(dir_file);
% micechannel=[
%         '60510';'60610';'60711';'60810';'60911';'61209';'61510';'61610';
%         '66810';'66909';'67009';'67109';'67210';'67310';'67411';'67509'];%AD
% micechannel=['62710';'63710','63810';'64210';'64310','64610';'64711';'64910';
%           '65009';'65111';'54709'];%WT
micechannel=['63301';'65508';'65606';'65902';'66101';'66302';'66408';'35008']; %ADT    

temnum=length(micechannel);
%% 数据处理 %%
for yi=103:num
    filename=dir_file(yi).name(1:end-4);%文件名
    pathname=[dir_file(yi).folder,'\'];%路径名
    savename=strcat(pathname,filename,'-psd.xlsx');
    xlswrite(savename,{"thetabegintime"},1,'A1');
    xlswrite(savename,{"thetaendtime"},1,'B1');
    xlswrite(savename,{"allpsd"},1,'C1');
    xlswrite(savename,{"thetapsd"},1,'D1');
    xlswrite(savename,{"ripplebegintime"},2,'A1');
    xlswrite(savename,{"rippleendtime"},2,'B1');
    xlswrite(savename,{"allpsd"},2,'C1');
    xlswrite(savename,{"ripplepsd"},2,'D1');
    load([dir_file(yi).folder,'\',dir_file(yi).name]);%载入文件
   if  dir_file(yi).name(1:2)=='WU'
            channel='FP08';
   else
       for za=1:temnum
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
    [mt,nt]=size(k);
    if nt==5 
        thetaap=1;
    end
    if  thetaap==1
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
        thetatimes=length(theta_period(:,1));
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
    end
    thetaap=0;
    %% 判断ripple
    ripple_fre=[100 250];
    ripple = bandpass_butter(signal_notch,ripple_fre,fs);
    Nr = length(ripple);
    %窗口大小 10ms
    kr=[];
    for i=1:floor(len/10)
        epb=(i-1)*10+1;epr=i*10;
        temp_ripple = ripple(epb:epr,1);
        temp_signal = signal_notch(epb:epr,1);
        ripple_RMS=MSR(temp_ripple,1);%10ms窗口均方差
        signal_RMS=MSR(temp_signal,1);
        kr(i,1) = ripple_RMS;
        kr(i,2) = signal_RMS;
        kr(i,3) = t(epb,1);
    end
    signal_mean=mean(kr(:,2));%背景均方根均值
    signal_sd=std(kr(:,2));%标准差
    target=signal_mean+2*signal_sd;%阈值
    steps=length(kr(:,1));
    for i=1:steps
         kr(i,4)=kr(i,1)-target;
         if kr(i,4)>0
            kr(i,5)=1;
         end
    end
    
    ripple_period=[];
    m=0;
    n=0;
    [mr,nr]=size(kr);
    if nr==4 
        continue;
    end
    if kr(1,5)==1
        m=m+1;
        ripple_period(m,1)=kr(1,3);
        for i=2:steps-1
            if kr(i,5)==1 && kr(i+1,5)==0
                 n=n+1;
                ripple_period(n,2)=kr(i,3)+0.01;%结束时间
            end
            if kr(i,5)==0 && kr(i+1,5)==1
                m=m+1;
                ripple_period(m,1)=kr(i,3);%起始时间
            end
        end
     else  
         for i=1:steps-1
            if kr(i,5)==0 && kr(i+1,5)==1
                m=m+1;
                ripple_period(m,1)=kr(i,3);
            end
            if kr(i,5)==1 && kr(i+1,5)==0
               n=n+1;
               ripple_period(n,2)=kr(i,3)+0.01;
            end  
         end
    end
    %求功率
    rippleperiodpoint=uint32(ripple_period*1000);
    rippletimes=length(ripple_period(:,1));
    for i=1:rippletimes
         pointstart=rippleperiodpoint(i,1);
         pointend=rippleperiodpoint(i,2);
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
         strtemp=num2str(i+1);
         nameA=strcat('A',strtemp);
         nameB=strcat('B',strtemp);
         nameC=strcat('C',strtemp);
         nameD=strcat('D',strtemp);
         xlswrite(savename,ripple_period(i,1),2,nameA)
         xlswrite(savename,ripple_period(i,2),2,nameB)
         xlswrite(savename,power2(1,1),2,nameC)
         xlswrite(savename,power2(2,1),2,nameD)
    end
end
