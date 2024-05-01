clear;clc;close all;
[FileName,PathName] = uigetfile('*.mat','选择待处理文件');%弹窗获取处理文件位置
addpath(PathName);%添加路径
dir_file=dir(fullfile(PathName,'*.mat'));%列出该文件夹下所有.mat文件
for i=1:22 %改数目
mkdir([dir_file(i).name(1:end-4),'-10']);
end