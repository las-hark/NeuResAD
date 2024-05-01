function varargout = FP_gui_20220110(varargin)
% FP_GUI_20220110 MATLAB code for FP_gui_20220110.fig
%      FP_GUI_20220110, by itself, creates a new FP_GUI_20220110 or raises the existing
%      singleton*.
%
%      H = FP_GUI_20220110 returns the handle to a new FP_GUI_20220110 or the handle to
%      the existing singleton*.
%
%      FP_GUI_20220110('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FP_GUI_20220110.M with the given input arguments.
%
%      FP_GUI_20220110('Property','Value',...) creates a new FP_GUI_20220110 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FP_gui_20220110_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FP_gui_20220110_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FP_gui_20220110

% Last Modified by GUIDE v2.5 26-Mar-2019 19:31:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FP_gui_20220110_OpeningFcn, ...
                   'gui_OutputFcn',  @FP_gui_20220110_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before FP_gui_20220110 is made visible.
function FP_gui_20220110_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FP_gui_20220110 (see VARARGIN)

% Choose default command line output for FP_gui_20220110
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FP_gui_20220110 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FP_gui_20220110_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}...
,'File Selector');%鑾峰彇mat鏍煎紡鐨勬枃浠惰矾寰勪互鍙婂悕绉�
load(filename);
signal=FP11(:,1);
t=FP11(:,2);
len = length(signal);
fs=1000; %閲囨牱棰戠巼
figure(1)
plot(t,signal);
xlim([t(1,1) t(len,1)]);xlabel('Time(s)');ylabel('mV');title('original signal');
handles.signal = signal;
handles.len = len;
handles.t = t;
handles.fs = fs;
handles.filename2 = filename;
handles.pathname2 = pathname;
guidata(hObject,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal;
t = handles.t;
[signal_baseline,residual]=remove_baseline(t,signal);
figure(2)
plot(t,signal_baseline,t,residual); 
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('move-baseline signal');
handles.signal = signal;
guidata(hObject,handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal;
t = handles.t;
fs = handles.fs;
bandpass=[0.5 300];
signal_pass=bandpass_butter(signal,bandpass,fs);
figure(3)
plot(t,signal_pass);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title(' bandpass-filter signal');
handles.signal = signal_pass;
guidata(hObject,handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal;
t = handles.t;
fs = handles.fs;
signal_notch=notch_iirnotch(signal,fs);
figure(4)
plot(t,signal_notch); 
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('50Hz-notch signal');
handles.signal_notch = signal_notch;
guidata(hObject,handles);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal_notch = handles.signal_notch;
t = handles.t;
fs = handles.fs;
delta_fre=[2 4];
theta_fre=[5 10];
delta = bandpass_butter(signal_notch,delta_fre,fs);
theta = bandpass_butter(signal_notch,theta_fre,fs);
figure(7)
subplot(2,1,1);plot(t,delta);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('delta');
subplot(2,1,2);plot(t,theta);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('theta');
handles.delta = delta;
handles.theta = theta;
guidata(hObject,handles);


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
theta = handles.theta;
delta = handles.delta;
fs = handles.fs;
len = handles.len;
t = handles.t;
filename = handles.filename2;
pathname = handles.pathname2;
N = length(theta);
window = 2000;    %绐楀彛澶у皬 2s
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
set(handles.uitable1,'Data',theta_period);
savename = strcat(pathname, get(handles.edit1,'String'), '-data.xlsx');
Title = {'璧峰鏃堕棿/s','缁撴潫鏃堕棿/s'};
xlswrite(savename, Title, 1, 'A1');
xlswrite(savename, theta_period, 1, 'A2');




function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal_filter = handles.signal_notch;
t=handles.t;
number_time = str2double(get(handles.edit16,'String')); 
S_T=str2double(get(handles.edit2,'String'));
E_T=str2double(get(handles.edit3,'String'));
signal_filter=signal_filter(S_T*1000:E_T*1000,1);
t_during=t(S_T*1000:E_T*1000,1);
len = length(signal_filter);
figure(8)
plot(t_during,signal_filter);
xlim([t_during(1,1) t_during(length(t_during),1)]);xlabel('Time(s)');ylabel('mV');title('Filtered signal');
handles.signal_filter = signal_filter;
handles.t_during = t_during;
handles.number_time = number_time;
guidata(hObject,handles);


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal_filter;
fs = handles.fs;
number_time = handles.number_time;
filename = handles.filename2;
pathname = handles.pathname2;
[signal_psd f]=psd(signal,fs);
figure(9)
plot(f,signal_psd);  %缁樺埗鍔熺巼璋卞瘑搴�
xlim([0 300]);xlabel('Frequency(Hz)');ylabel('Power spectral density(mV^2/Hz)');title('Power spectral densities');
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '-Power spectral densities');
title_TF = strcat(title_TF, '.png');
saveas(figure(9),title_TF);
p = bandpower(signal_psd,f,'psd');  %璁＄畻骞冲潎鍔熺巼
text = strcat( num2str(p), 'mv^2');
set(handles.text6,'string', text);
Aname = strcat(pathname, get(handles.edit1,'String'), '-data.xlsx');
Bname = strcat(get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '-PSD');
xlswrite(Aname, {Bname}, number_time, 'C1');
xlswrite(Aname, signal_psd, number_time, 'C2');
Title_PSD_f = {'PSD-f/Hz'};
xlswrite(Aname, Title_PSD_f, number_time, 'D1');
xlswrite(Aname, f', number_time, 'D2');
Title_all_power = {'all power/mV^2'};
xlswrite(Aname, Title_all_power, number_time, 'E1');
xlswrite(Aname, p, number_time, 'E2');


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal_filter;
fs = handles.fs;
t = handles.t_during;
number_time = handles.number_time;
filename = handles.filename2;
pathname = handles.pathname2;
theta_fre=[4 12];
gammal_fre=[30 50];
gammam_fre=[50 100];
gammah_fre=[100 150];
gammal_30_80_fre=[30 80];
gamma_30_100_fre=[30 100];
gamma_80_150_fre=[80 150];
theta_filter = bandpass_butter(signal,theta_fre,fs);
gammal_filter = bandpass_butter(signal,gammal_fre,fs);
gammam_filter = bandpass_butter(signal,gammam_fre,fs);
gammah_filter = bandpass_butter(signal,gammah_fre,fs);
gammal_30_80_filter = bandpass_butter(signal,gammal_30_80_fre,fs);
gamma_30_100_filter = bandpass_butter(signal,gamma_30_100_fre,fs);
gamma_80_150_filter = bandpass_butter(signal,gamma_80_150_fre,fs);
figure(11)
subplot(7,1,1);plot(t,theta_filter);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('theta');
subplot(7,1,2);plot(t,gammal_filter);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('gamma[30 50]');
subplot(7,1,3);plot(t,gammam_filter);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('gamma[50 100]');
subplot(7,1,4);plot(t,gammah_filter);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('gamma[100 150]');
subplot(7,1,5);plot(t,gammal_30_80_filter);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('gamma[30 80]');
subplot(7,1,6);plot(t,gamma_30_100_filter);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('gamma[30 100]');
subplot(7,1,7);plot(t,gamma_80_150_filter);
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('gamma[80 150]');
[theta_psd f]=psd(theta_filter,fs);
[gammal_psd f]=psd(gammal_filter,fs);
[gammam_psd f]=psd(gammam_filter,fs);
[gammah_psd f]=psd(gammah_filter,fs);
[gammal_30_80_psd f]=psd(gammal_30_80_filter,fs);
[gamma_30_100_psd f]=psd(gamma_30_100_filter,fs);
[gamma_80_150_psd f]=psd(gamma_80_150_filter,fs);
power=[];
power(1,1) = bandpower(theta_psd,f,'psd'); 
power(2,1) = bandpower(gammal_psd,f,'psd'); 
power(3,1) = bandpower(gammam_psd,f,'psd'); 
power(4,1) = bandpower(gammah_psd,f,'psd'); 
power(5,1) = bandpower(gammal_30_80_psd,f,'psd'); 
power(6,1) = bandpower(gamma_30_100_psd,f,'psd'); 
power(7,1) = bandpower(gamma_80_150_psd,f,'psd'); 
set(handles.uitable2,'Data',power);
Aname = strcat(pathname, get(handles.edit1,'String'), '-data.xlsx');
Bname = strcat(get(handles.edit2,'String'),'-',get(handles.edit3,'String'), 's-power');
TitleF1 = {'rhythm'};
TitleF2 = {'theta[4 12]', 'gamma[30 50]', 'gamma[50 100]', 'gamma[100 150]','gamma[30 80]','gamma[30 100]','gamma[80 150]'};
xlswrite(Aname, TitleF1, number_time, 'F1');
xlswrite(Aname, TitleF2', number_time, 'F2');
xlswrite(Aname, {Bname}, number_time, 'G1');
xlswrite(Aname, power, number_time, 'G2');



% --- Executes when entered data in editable cell(s) in uitable2.
function uitable2_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uitable2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename1, pathname1] = uigetfile({'*.mp4';'*.avi';'*.*'}...
,'File Selector');%鑾峰彇MP4鎴栬�匒vi鏍煎紡鐨勮棰戞枃浠惰矾寰勪互鍙婂悕绉�
V=VideoReader([pathname1,filename1]);%璇诲彇瑙嗛
Framerate=V.FrameRate;%鑾峰彇瑙嗛甯х巼
frame = read(V,150);% 鑾峰彇瑙嗛绗�0甯�
frame = rgb2gray(frame);%鎶婂僵鑹茬殑鍥惧儚杞崲涓虹伆搴﹀浘
figure (19)
imshow(frame);
rec=imrect(gca,[ V.Width/2 V.Height/2 15 20]);%鐢熸垚涓�涓彲鎷変几鐨勭煩褰�
handles.x = V;
handles.y = Framerate;
handles.z = rec;
handles.pathname = pathname1;
handles.filename = filename1;
guidata(hObject,handles);



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = handles.filename2;
pathname = handles.pathname2;
pathname1 = handles.pathname;
filename1 = strcat(handles.filename(1:end-4));
number_time = handles.number_time;
V = handles.x;
Framerate = handles.y;
rec = handles.z;
     A_name = strcat(pathname, get(handles.edit1,'String'), '-data.xlsx');
     B_name = strcat(get(handles.edit7,'String'),'-',get(handles.edit8,'String'),'s', '-speed锛坈m/s锛�');
     title_I1= {'time'};
     xlswrite(A_name, title_I1, number_time, 'I1');
     xlswrite(A_name, {B_name}, number_time, 'J1');     
p=ceil(getPosition(rec));%鑾峰彇鎷変几鍚庣煩闃电殑鍧愭爣

Threshold=50;%璁剧疆闃堝��  锛堝鏋滃懆鍥磋繕鏈変寒鐐癸紝鍙互灏嗛槇鍊艰缃殑鏇村皬涓�浜涳紝濡�)
Speed=[];
Cent_all=[];
Box_all=[];
S_T=str2double(get(handles.edit7,'String'));%璁剧疆寮�濮嬫椂闂�
E_T=str2double(get(handles.edit8,'String'));%璁剧疆缁撴潫鏃堕棿
if E_T>V.Duration
    E_T=V.Duration;
end
frame_need=round(S_T*Framerate)+1:round(E_T*Framerate);%璁惧畾闇�瑕佺殑鏃堕棿鑼冨洿鍐呯殑甯ф暟
aa=(E_T-S_T)/length(frame_need);
speed_time = [];
time_speed = [];
figure
for k = 1 : length(frame_need)% 璇诲彇鎵�鏈夊抚
     frame = read(V,frame_need(k));    
     frame=frame(p(2):p(2)+p(4),p(1):p(1)+p(3),:);     
     frame_1=rgb2gray(frame);     
     frame_1=frame_1<Threshold;%杩涜閫昏緫鍒ゆ柇锛屼寒搴﹀皬浜庨槇鍊�1锛屽惁鑰呬负=0     
     frame_1=bwareaopen(frame_1,5000);% 鍙栧浘鍍廔鍐呰繛閫氬尯鍩熷ぇ浜�0鐨勫尯鍩�
     ROI=regionprops(frame_1);%娴嬮噺鍥惧儚鍐呭尯鍩熺殑鐗瑰緛 
     S=size(ROI);
     if S(1)==0 %鑰侀紶娌℃湁琚瘑鍒嚭鏉�
        Cent_all(k,:)=NaN;%鑰侀紶璐ㄥ績涓虹┖
        Box_all(k,:)=NaN;
     end
     subplot('position',[0.05 0.4 0.4 0.4]),imshow(frame);
     if S(1)==1  %鑰侀紶琚瘑鍒嚭鏉�    
     cent=ROI.Centroid;
     Cent_all(k,:)=cent;%璁板綍姣忎竴甯ц�侀紶璐ㄥ績
     Box_all(k,:)=ROI.BoundingBox;
     hold on;
     scatter(Cent_all(:,1),Cent_all(:,2),5,'MarkerEdgeColor'...
     ,'none','MarkerFaceColor',[1 0 0],'LineWidth',0.1);
     rectangle('Position',ROI.BoundingBox,'EdgeColor','b');
     title('浣庨�熻嚜鐢辫繍鍔ㄤ笅鐨勫皬榧�');
     hold off
     end
     if k==1
     Speed(k)=0;
     else
        %Speed(k)=sqrt((Cent_all(k,1)-Cent_all(k-1,1))^2+(Cent_all(k,2)-Cent_all(k-1,2))^2);%閫熷害,鐜板湪鏄儚绱�/绉掞紝濡備綍鎹㈡垚cm/s
         Speed(k)=((sqrt((Cent_all(k,1)-Cent_all(k-1,1))^2+(Cent_all(k,2)-Cent_all(k-1,2))^2))*33)/size(frame_1,1);%閫熷害锛屾崲鎴恈m/s,(绠卞瓙30cm锛屽妗嗕竴鐐圭害33cm)
     end
     subplot('position',[0.5 0.4 0.4 0.4])
     plot([1:k]*aa+S_T,Speed);
     time_speed = [1:k]*aa+S_T;
     speed_time = Speed;
     xlabel('鏃堕棿 (s)','FontSize',10);
     ylabel('閫熷害 (cm/s)','FontSize',10);
     xlim([S_T E_T]);
     ylim([0 5]);
     set(gca,'Box','off')
     title('灏忛紶杩愬姩閫熷害')
     F=getframe(gcf);
     im=frame2im(F);
     [I,map]=rgb2ind(im,256);%杞垚gif鍥剧墖,鍙兘鐢�6鑹�
     if k==1
     imwrite(I,map,strcat(pathname,filename1,'-',get(handles.edit7,'String'),'-',get(handles.edit8,'String'),'s','.gif'),'gif','Loopcount',inf,'DelayTime',aa);
     else
     imwrite(I,map,strcat(pathname,filename1,'-',get(handles.edit7,'String'),'-',get(handles.edit8,'String'),'s','.gif'),'gif','WriteMode','Append','DelayTime',aa);
     end
     ROI=[];
end
     xlswrite(A_name,time_speed', number_time, 'I2');
     xlswrite(A_name,speed_time', number_time, 'J2');
     Data = [];
     Data(:,1) = time_speed';
     Data(:,2) = speed_time';
     set(handles.uitable5,'Data',Data);



% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal_filter;
srate = handles.fs;  %閲囨牱棰戠巼
filename = handles.filename2;
pathname = handles.pathname2;
t=handles.t;
lfp=signal';
t=t';
data_length = length(lfp);

% Define the amplitude- and phase-frequencies
PhaseFreq_BandWidth=0.25;     %浣庨鐩镐綅甯﹀
AmpFreq_BandWidth=10;      %楂橀骞呭�煎甫瀹�
PhaseFreqVector=4-PhaseFreq_BandWidth/2:PhaseFreq_BandWidth:12-PhaseFreq_BandWidth/2;    %浣庨鐩镐綅鑼冨洿
AmpFreqVector=30-AmpFreq_BandWidth/2:AmpFreq_BandWidth:150-AmpFreq_BandWidth/2;    %楂橀骞呭�艰寖鍥�

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

% Obtaining the 楂橀 骞呭�� time-series
for ii=1:length(AmpFreqVector)
    Af1 = AmpFreqVector(ii); % selecting frequency (low cut)
    Af2=Af1+AmpFreq_BandWidth; % selecting frequency (high cut) 
    AmpFreq=eegfilt(lfp,srate,Af1,Af2); % filtering
    AmpFreqTransformed(ii, :) = abs(hilbert(AmpFreq)); % getting the amplitude envelope
end

% Obtaining the 浣庨 鐩镐綅 time-series
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
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '-Comodulogram plot');
title_TF = strcat(title_TF, '.png');
saveas(figure(12),title_TF);
handles.position = position;
guidata(hObject,handles);


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal_filter;
srate = handles.fs;  %閲囨牱棰戠巼
number_time = handles.number_time;
MI_position = handles.position;
filename = handles.filename2;
pathname = handles.pathname2;
t=handles.t;
lfp=signal';
t=t';
data_length = length(lfp);
%  Use the routine below to look at specific pairs of frequency ranges:
% Pf1 and Pf2 define the frequency range (in Hz) investigated as the
% "phase-modulating" (for example, for theta take Pf1=6 and Pf2=12)
% Af1 and Af2 define the frequency range investigated as the "amplitude
% modulated" by the phase frequency (e.g., low gamma would be Af1=30 Af2=55)
[MI_gammal,MeanAmp_gammal] = ModIndex_v1(lfp,srate,4,12,30,50,MI_position);
[MI_gammam,MeanAmp_gammam] = ModIndex_v1(lfp,srate,4,12,50,100,MI_position);
[MI_gammah,MeanAmp_gammah] = ModIndex_v1(lfp,srate,4,12,100,150,MI_position);
[MI_gamma_30_80,MeanAmp_gamma_30_80] = ModIndex_v1(lfp,srate,4,12,30,80,MI_position);
[MI_gamma_30_100,MeanAmp_gamma_30_100] = ModIndex_v1(lfp,srate,4,12,30,100,MI_position);
[MI_gamma_80_150,MeanAmp_gamma_80_150] = ModIndex_v1(lfp,srate,4,12,80,150,MI_position);
figure(13)
bar(10:20:720,[MeanAmp_gammal,MeanAmp_gammal]/sum(MeanAmp_gammal),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[30-50]-Modulation index = ' num2str(MI_gammal)]);
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '[30-50]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(13),title_TF);
figure(14)
bar(10:20:720,[MeanAmp_gammam,MeanAmp_gammam]/sum(MeanAmp_gammam),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[50-100]-Modulation index = ' num2str(MI_gammam)]);
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '[50-100]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(14),title_TF);
figure(15)
bar(10:20:720,[MeanAmp_gammah,MeanAmp_gammah]/sum(MeanAmp_gammah),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[100-150]-Modulation index = ' num2str(MI_gammah)]);
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '[100-150]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(15),title_TF);
figure(16)
bar(10:20:720,[MeanAmp_gamma_30_80,MeanAmp_gamma_30_80]/sum(MeanAmp_gamma_30_80),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[30-80]-Modulation index = ' num2str(MI_gamma_30_80)]);
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '[30-80]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(16),title_TF);
figure(17)
bar(10:20:720,[MeanAmp_gamma_80_150,MeanAmp_gamma_80_150]/sum(MeanAmp_gamma_80_150),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[30-100]-Modulation index = ' num2str(MI_gamma_30_100)]);
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '[30-100]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(17),title_TF);
figure(18)
bar(10:20:720,[MeanAmp_gamma_30_100,MeanAmp_gamma_30_100]/sum(MeanAmp_gamma_30_100),'k')
xlim([0 720]);ylim([0 0.09]);set(gca,'xtick',0:360:720);xlabel('Phase degree');ylabel('Amplitude');
title(['[80-150]-Modulation index = ' num2str(MI_gamma_80_150)]);
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '[80-150]-Modulation index');
title_TF = strcat(title_TF, '.png');
saveas(figure(18),title_TF);
MI = [MI_gammal MI_gammam MI_gammah MI_gamma_30_80 MI_gamma_30_100 MI_gamma_80_150]';
set(handles.uitable4,'Data',MI);
Aname = strcat(pathname, get(handles.edit1,'String'), '-data.xlsx');
Title_MI = {'MI'};
xlswrite(Aname, Title_MI, number_time, 'H1');
xlswrite(Aname,MI, number_time, 'H3');


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal_notch;
t = handles.t;
fs = handles.fs; 
Fnotch = 100; % Notch Frequency
BW     = 1;   % Bandwidth
Apass  = 1;   % Bandwidth Attenuation
[b, a] = iirnotch(Fnotch/(fs/2), BW/(fs/2), Apass);
signal_notch=filtfilt(b,a,signal);
figure(5)
plot(t,signal_notch); 
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('100Hz-notch signal');
handles.signal_notch = signal_notch;
guidata(hObject,handles);

% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal_notch;
t = handles.t;
fs = handles.fs; 
Fnotch = 150; % Notch Frequency
BW     = 1;   % Bandwidth
Apass  = 1;   % Bandwidth Attenuation
[b, a] = iirnotch(Fnotch/(fs/2), BW/(fs/2), Apass);
signal_notch=filtfilt(b,a,signal);
figure(6)
plot(t,signal_notch); 
xlim([t(1,1) t(length(t),1)]);xlabel('Time(s)');ylabel('mV');title('150Hz-notch signal');
handles.signal_notch = signal_notch;
guidata(hObject,handles);


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
signal = handles.signal_notch;
fs = handles.fs;
filename = handles.filename2;
pathname = handles.pathname2;
S_T=str2double(get(handles.edit2,'String'));
E_T=str2double(get(handles.edit3,'String'));
signal_filter=signal((S_T-1.5)*1000:(E_T+1.5)*1000,1);
low_fre=str2double(get(handles.edit4,'String'));
high_fre=str2double(get(handles.edit5,'String'));
movingwin=[3 0.05]; 
params.Fs=fs; 
params.pad=2;
params.tapers=[3 5];
params.fpass=[low_fre high_fre];
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
title_TF = strcat(pathname,get(handles.edit2,'String'),'-',get(handles.edit3,'String'),'s', '-Time frequency analysis');
title_TF = strcat(title_TF, '.png');
saveas(figure(10),title_TF);

function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
