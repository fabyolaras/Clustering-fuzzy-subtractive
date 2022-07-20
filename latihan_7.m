function varargout = latihan_7(varargin)
% LATIHAN_7 MATLAB code for latihan_7.fig
%      LATIHAN_7, by itself, creates a new LATIHAN_7 or raises the existing
%      singleton*.
%
%      H = LATIHAN_7 returns the handle to a new LATIHAN_7 or the handle to
%      the existing singleton*.
%
%      LATIHAN_7('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LATIHAN_7.M with the given input arguments.
%
%      LATIHAN_7('Property','Value',...) creates a new LATIHAN_7 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before latihan_7_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to latihan_7_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help latihan_7

% Last Modified by GUIDE v2.5 13-Sep-2021 16:59:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @latihan_7_OpeningFcn, ...
                   'gui_OutputFcn',  @latihan_7_OutputFcn, ...
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


% --- Executes just before latihan_7 is made visible.
function latihan_7_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to latihan_7 (see VARARGIN)

% Choose default command line output for latihan_7
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes latihan_7 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = latihan_7_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
formku = guidata(gcbo);
[namafile,direktori] = uigetfile('*xlsx','Load Data File');
alamatfile=fullfile(direktori,namafile);

[a b c] = xlsread(alamatfile);
bar=size(c,1);
col=size(c,2);
judul=c(1,1:col);
datareal=c(2:bar,2:col);
nom=linspace(1,bar-1,bar-1);

datareal = cell2table(datareal);
assignin('base','datareal',datareal);
handles.judul = judul;
handles.nom = nom;
handles.datareal = datareal;
guidata(hObject,handles);
set(formku.pushbutton1,'Userdata',datareal);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datareal = handles.datareal;
judul = handles.judul;
nom = handles.nom;
S = vartype('double');
data_awal = table2array(datareal(:,S));
data_k=datareal(:,1);
[n,m] = size(data_awal);

r = str2double(get(handles.edit1,'string'));
accept_ratio = str2double(get(handles.edit2,'string'));
reject_ratio = str2double(get(handles.edit3,'string'));
q = str2double(get(handles.edit4,'string'));

%melakukan normalisasi data
 max_data = max(data_awal);
 min_data = min(data_awal);
 N = zeros(n,m);
 for y = 1:m
     N(:,y) = (data_awal(:,y)-min_data(y))./(max_data(y)-min_data(y));
 end
 assignin('base','N',N)
 
%faktor untuk mencari nilai potensi
pengali_1 = 1.0 ./ r;
pengali_2 = 1.0 ./ (q*r);

%potensi awal tiap data
potensi = zeros(1,n);
pengali_1baru = pengali_1(ones(1,n),:);

for i = 1:n
    nilaidata = N(i,:);
    nilaidata = nilaidata(ones(1,n),:);
    dx = (nilaidata - N) .* pengali_1baru;
    if m == 1
        potensi(i) = sum(exp(-4*dx.^2));
    else
        potensi(i) = sum(exp(-4*sum(dx.^2,2)));
    end
end

%menetapkan potensi tertinggi sebagai nilai referensi rasio
[refpotensi,maxPotIndex] = max(potensi);
maxpotensi = refpotensi;

%menetapkan center kluster
cntr = [];
jmlklaster = 0;
kondisi = 1;

while kondisi & maxpotensi
    kondisi = 0;
    maxnilai = N(maxPotIndex,:);
    rasio = maxpotensi/refpotensi;
    
    if rasio >= accept_ratio
        kondisi = 1;
    elseif rasio > reject_ratio
        minDistSq = -1;
        
        for i = 1 : jmlklaster
            dx = (maxnilai - cntr(i,:)).*pengali_1;
            dxSq = dx*dx';
            
            if minDistSq < 0 | dxSq < minDistSq
                minDistSq = dxSq;
            end
        end
        
        minDist = sqrt(minDistSq);
        condition = minDist+rasio;
        if condition >= 1
            kondisi = 1;

        else
            kondisi = 2;
        end
    end
    
    if kondisi == 1
        %menambahkan data sebagai pusat kluster baru
        cntr = [cntr ; maxnilai];
        jmlklaster = jmlklaster + 1;
        
        %perbarui potensi tetangga
        pengalibaru2 = pengali_2(ones(1,n),:);
        tmp = maxnilai(ones(1,n),:);
        dx = (tmp - N).*pengalibaru2;
        if m == 1
            pengurangan = maxpotensi*exp(-4*dx.^2);
        else
            pengurangan = maxpotensi*exp(-4*sum(dx.^2,2));
        end
        potensi = potensi - pengurangan';
        potensi(potensi<0)=0;
        [maxpotensi,matPotIndex]=max(potensi);
        fprintf('Iterasi ke-%d\nNilai Rasio = %d\n',jmlklaster,rasio);
    elseif kondisi == 2
        potensi(maxPotIndex) = 0;
        [maxpotensi,maxPotIndex] = max(potensi);
    end
end

%mengembalikan nilai pusat klaster ke data awal
for i = 1:m
    cntr_baru(:,i)=(cntr(:,i)*(max_data(i)-min_data(i)))+min_data(i);
end
assignin('base','cntr_baru',cntr_baru)

%menghitung sigma klaster
sigmascluster = (r .* (max_data - min_data)) / sqrt(8);
sb_temp = sigmascluster.^2;
sb = 2.*sb_temp;
%sumd = zeros(n,jmlklaster);

%derajat keanggotaan tiap data pada tiap klaster
for i = 1:n
    for j = 1:m
        for k = 1:jmlklaster
            hasil(i,j,k)=(((data_awal(i,j)-cntr_baru(k,j)).^2)./sb(j));
        end
    end
end
su = sum(hasil,2);
sq = squeeze(su);
drjt = exp(-sq);
assignin('base','drjt',drjt)

%menentukan tiap data masuk pada cluster mana
[val,idx] = max(drjt,[],2)
n_idx = array2table(idx);
hasil_var = [n_idx datareal];
hasil_var = table2cell(hasil_var);
assignin('base','hasil_var',hasil_var)
set(handles.uitable1,'data',hasil_var,'ColumnName',judul,'RowName',nom);

%menghitung nilai silhouette
figure
[s,h]=silhouette(N,idx,'Euclidean');
rata = mean(s);
assignin('base','silhouette',rata)
%w = [0.1; 0.2; 0.1; 0.2; 0.1; 0.2; 0.1]; % Set arbitrary weights for illustration
%chiSqrDist = @(x,Z,w)sqrt((bsxfun(@minus,x,Z).^2)*w);
%hsl1 = silhouette(N,idx,chiSqrDist,w);
%w2 = [1; 1; 1; 1; 1; 1; 1];
%hsl2 = silhouette(N,idx,chiSqrDist,w2);
%eq = isequal(hsl2,s);
title('Hasil Silhouette Coefficient')

%menampilkan nama kelurahan sesuai clusternya
G = jmlklaster ;   % number of cluster 
ind = cell(G,1) ; 
C = cell(G,1) ; 
for i = 1:G
    ind{i} = idx == i;
    C_norm{i}=N(idx==i,:); %menampilkan data normalisasi sesuai cluster
    C{i} = datareal(idx==i,:);  %menampilkan nama kelurahan sesuai clusternya
    CA{i} = data_awal(idx==i,:) ;
    C_stat{i} = stat(CA{i}); %menampilkan stat setiap cluster
    cSSE{i} = hitung_sse(C_norm,cntr,i);
    cMAE{i} = hitung_mae(C_norm,cntr,i);
end

sumSSE = sum(cell2mat(cSSE(:)),2);
SSE = sum(sumSSE);
sumMAE = (sum(cell2mat(cMAE(:)),2))./G;
MAE = sum(sumMAE);
assignin('base','jmlklaster',jmlklaster)
assignin('base','C',C)
assignin('base','C_stat',C_stat)
assignin('base','SSE',SSE)
assignin('base','MAE',MAE)

handles.data_awal = data_awal;
handles.cntr_baru = cntr_baru;
handles.idx = idx;
guidata(hObject,handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data_awal = handles.data_awal;
cntr_baru = handles.cntr_baru;
idx = handles.idx;

var1 = get(handles.popupmenu1, 'value');
var2 = get(handles.popupmenu2, 'value');
var3 = get(handles.popupmenu3, 'value');

data1 = data_awal(:,var1);
data2 = data_awal(:,var2);
data3 = data_awal(:,var3);
cntr1 = cntr_baru(:,var1);
cntr2 = cntr_baru(:,var2);
cntr3 = cntr_baru(:,var3);

if var1 == 1
    label1 = ('Kematian');
elseif var1 == 2
    label1 = ('Gizi Kurang');
elseif var1 == 3
    label1 = ('Gizi Kurus');
elseif var1 == 4
    label1 = ('Pendek');
elseif var1 == 5
    label1 = ('BBLR');
elseif var1 == 6
    label1 = ('Pneumonia');
elseif var1 == 7
    label1 = ('Diare');
end

if var2 == 1
    label2 = ('Kematian');
elseif var2 == 2
    label2 = ('Gizi Kurang');
elseif var2 == 3
    label2 = ('Gizi Kurus');
elseif var2 == 4
    label2 = ('Pendek');
elseif var2 == 5
    label2 = ('BBLR');
elseif var2 == 6
    label2 = ('Pneumonia');
elseif var2 == 7
    label2 = ('Diare');
end

if var3 == 1
    label3 = ('Kematian');
elseif var3 == 2
    label3 = ('Gizi Kurang');
elseif var3 == 3
    label3 = ('Gizi Kurus');
elseif var3 == 4
    label3 = ('Pendek');
elseif var3 == 5
    label3 = ('BBLR');
elseif var3 == 6
    label3 = ('Pneumonia');
elseif var3 == 7
    label3 = ('Diare');
end

figure
scatter3(data1, data2, data3,15,idx,'filled')
hold on
scatter3(cntr1,cntr2,cntr3)
xlabel(label1); ylabel(label2); zlabel(label3);
title('Visualisasi Custer Terhadap 3 Variabel')


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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
