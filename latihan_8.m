function varargout = latihan_8(varargin)
% LATIHAN_8 MATLAB code for latihan_8.fig
%      LATIHAN_8, by itself, creates a new LATIHAN_8 or raises the existing
%      singleton*.
%
%      H = LATIHAN_8 returns the handle to a new LATIHAN_8 or the handle to
%      the existing singleton*.
%
%      LATIHAN_8('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LATIHAN_8.M with the given input arguments.
%
%      LATIHAN_8('Property','Value',...) creates a new LATIHAN_8 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before latihan_8_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to latihan_8_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help latihan_8

% Last Modified by GUIDE v2.5 28-Oct-2021 20:10:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @latihan_8_OpeningFcn, ...
                   'gui_OutputFcn',  @latihan_8_OutputFcn, ...
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


% --- Executes just before latihan_8 is made visible.
function latihan_8_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to latihan_8 (see VARARGIN)

% Choose default command line output for latihan_8
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes latihan_8 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = latihan_8_OutputFcn(hObject, eventdata, handles) 
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
 

%mencari nilai centroid menggunakan function subclust
options = [q accept_ratio reject_ratio 1];
cntr = subclust(N,[r r r r r r r],'Options',options);
[jmlklaster,z] = size(cntr);
%findcluster;

%Mengembalikan centroid dari bentuk yang sudah dinormalisasi ke bentuk semula 
for i = 1:m
    cntr_baru(:,i)=(cntr(:,i)*(max_data(i)-min_data(i)))+min_data(i);
end

%Menghitung nilai sigma cluster (nilai parameter fungsi keanggotaan Gauss)
sigmascluster = (r .* (max_data - min_data)) / sqrt(8);
sb_temp = sigmascluster.^2;
sb = 2.*sb_temp;

%derajat keanggotaan tiap data pada tiap klaster
for i = 1:n
    for j = 1:m
        for k = 1:jmlklaster
            hasil(i,j,k)=(((data_awal(i,j)-cntr_baru(k,j)).^2)./sb(j));
            %sumd(i,k) = sumd(i,k)+hasil(i,k);
        end
    end
end
su = sum(hasil,2);
sq = squeeze(su);
drjt = exp(-sq);

%menentukan tiap data masuk pada cluster mana
[val,idx] = max(drjt,[],2);
n_idx = array2table(idx);
hasil_var = [n_idx datareal];
hasil_var = table2cell(hasil_var);
assignin('base','hasil_var',hasil_var)
set(handles.uitable1,'data',hasil_var,'ColumnName',judul,'RowName',nom);

figure
[s,h]=silhouette(N,idx,'Euclidean');
rata = mean(s);
assignin('base','rata',rata)
w = [0.1; 0.2; 0.1; 0.2; 0.1; 0.2; 0.1]; % Set arbitrary weights for illustration
chiSqrDist = @(x,Z,w)sqrt((bsxfun(@minus,x,Z).^2)*w);
hsl1 = silhouette(N,idx,chiSqrDist,w);
w2 = [1; 1; 1; 1; 1; 1; 1];
hsl2 = silhouette(N,idx,chiSqrDist,w2);
eq = isequal(hsl2,s);

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
