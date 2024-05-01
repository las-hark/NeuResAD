tfi=imread('171-176s-Time frequency analysis.png');%读入时频图
%imshow(img);
tfib=tfi(:,:,3);%提取b通道，功率谱密度高、在图上为红橙黄的部分b通道分量为0
tfpiece=tfib(320:450,110:699);%提取6~10hz部分进行识别
%imshow(tfpiece);
k=find(tfpiece<5);%选择5作为阈值
Nhigh=length(k);%频带内黑色即高能量像素数
%测试后发现能用的时频图点数至少9k，基本上w，不能用的普遍在5k以下
if Nhigh>9000  %筛选杂带
    other=tfib([58:319,451:575],[110:699]);%提取图片其他频带部分
    Nother=length(find(other<5));%筛选杂带
    if Nother>3000 %宽松一点可以定到5000
        RIGHT=0;
    else RIGHT=1; %无杂带进入下一步
    end
end
%筛选耦合热点图
if RIGHT==1
    cgi=imread('145-150s-Comodulogram plot.png');%读入耦合热点图
    cgib=cgi(:,:,3);
    %imshow(cgib)
    cgib=imcomplement(imbinarize(cgib,0.2));%二值化只保留红橙黄并黑白反转
    cgpiece=cgib(290:410,110:690);%分割70~90左右
    %figure(1);imshow(cgi);figure(2);imshow(cgib);figure(3);imshow(cgpiece);
    stahigh=regionprops(cgpiece);%搜索连通区域即目标
    ncgh=length(stahigh);%目标数
    higharea=0;
    for i=1:ncgh %统计目标像素
        higharea=higharea+stahigh(i).Area;
    end
    if 0<ncgh && ncgh<3 && higharea>3000  %判断条件：1.在70`90的目标在2个以内；2.区域像素数之和大于3k（高标准5k）
        cgother=cgib([58:289,411:575],[110:690]);
        staother=regionprops(cgother);
        ncgother=length(staother);
        otherarea=0;
        for i=1:ncgother %统计目标像素
            otherarea=otherarea+staother(i).Area;
        end
        if (ncgother>2 && otherarea>4000)||otherarea>5000 %其他区域杂带多或耦合高不符合要求
            RIGHT=0;
        else RIGHT=1; %此时两张图都符合要求
        end
    else RIGHT=0;%70~90内目标不符合要求
    end  
end
