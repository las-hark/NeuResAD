function [sigal_baseline,residual]= remove_baseline(t,data)
%多项式去基线漂移
n=4;%多项式拟合的次数
[p,~,mu] = polyfit(t,data,n);   %获得多项式系数向量p
residual=polyval(p,t,[],mu);   %拟合基线
sigal_baseline=data-residual;  %去除基线后信号

% 去除基线-变分模态分解 https://zhuanlan.zhihu.com/p/336228933
% [imf,residual] = vmd(data,'NumIMF',3);

% t1 = tiledlayout(3,3,'TileSpacing','compact','Padding','compact');
% for n = 1:9
%     ax(n) = nexttile(t1);
%     plot(t,imf(:,n)')
%     xlim([t(1) t(end)])
%     txt = ['IMF',num2str(n)];
%     title(txt)
%     xlabel('Time (s)')
% end
% title(t1,'Variational Mode Decomposition')

% sigal_baseline = sum(imf(:,2:2),2);

% figure;
% plot(t,residual);  %residual残差信号
% hold on
% plot(t,sigal_baseline) 
% hold off
end

