function signal_notch=notch_iirnotch(data,fs);
Fnotch = 50;  % Notch Frequency
BW     = 1;   % Bandwidth
Apass  = 1;   % Bandwidth Attenuation
[b, a] = iirnotch(Fnotch/(fs/2), BW/(fs/2), Apass);
signal_notch=filtfilt(b,a,data);
end


% figure
% freqz(b,a,2048,fs);%œ›≤®∆˜Ãÿ–‘œ‘ æ