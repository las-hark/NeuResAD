function sigal_pass= bandpass_butter(data,bandpass,fs)
order=3;
[b,a] = butter(order,bandpass/(fs/2), 'bandpass');
% sigal_pass=filter(b,a,data); 
sigal_pass=filtfilt(b,a,data); 
end

% %% »æÖÆÂË²¨Æ÷ÌØĞÔ
% input_length = length(data);
% NFFT = 2^nextpow2(input_length);
% [H,w]=freqz(b,a,NFFT);
% figure;
% plot(w*fs/(2*pi), abs(H));
