function [sigal_baseline,residual]= remove_baseline(t,data)
%����ʽȥ����Ư��
n=4;%����ʽ��ϵĴ���
[p,~,mu] = polyfit(t,data,n);   %��ö���ʽϵ������p
residual=polyval(p,t,[],mu);   %��ϻ���
sigal_baseline=data-residual;  %ȥ�����ߺ��ź�

% ȥ������-���ģ̬�ֽ� https://zhuanlan.zhihu.com/p/336228933
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
% plot(t,residual);  %residual�в��ź�
% hold on
% plot(t,sigal_baseline) 
% hold off
end

