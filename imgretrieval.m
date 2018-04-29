function varargout = imgretrieval(varargin)
% IMGRETRIEVAL MATLAB code for imgretrieval.fig
%      IMGRETRIEVAL, by itself, creates a new IMGRETRIEVAL or raises the existing
%      singleton*.
%
%      H = IMGRETRIEVAL returns the handle to a new IMGRETRIEVAL or the handle to
%      the existing singleton*.
%
%      IMGRETRIEVAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMGRETRIEVAL.M with the given input arguments.
%
%      IMGRETRIEVAL('Property','Value',...) creates a new IMGRETRIEVAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imgretrieval_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imgretrieval_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imgretrieval

% Last Modified by GUIDE v2.5 05-May-2015 21:04:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imgretrieval_OpeningFcn, ...
                   'gui_OutputFcn',  @imgretrieval_OutputFcn, ...
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


% --- Executes just before imgretrieval is made visible.
function imgretrieval_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imgretrieval (see VARARGIN)

% Choose default command line output for imgretrieval
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imgretrieval wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imgretrieval_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in retrieval.
function retrieval_Callback(hObject, eventdata, handles)
% hObject    handle to retrieval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% 添加检索代码
imgpath = getappdata(handles.selectimg,'imgpath');
if isempty(imgpath)
    set(handles.hint,'String','请先选择一幅图片...');
    return;
end
set(handles.hint,'String','正在检索...');

ind=str2num(imgpath.fname(1:end-4));
% id=imgre(ind);
num=12;
%% core
% step0 生成参数
param=par_init();
% step1 图片稠密取样的sift特征
if ~exist('sift.mat','file') && ~exist('sift','var')       % 不存在 计算并保存
    if param.parallel
        if matlabpool('size')<=0
            matlabpool open local;
        end
        parfor i=1:param.nimgs
            imgpath=[param.imgdir num2str(i) '.jpg'];
            sift{i,1}=single(densesift_liy(imgpath,param));
        end
        matlabpool close;
    else
        for i=1:param.nimgs
            imgpath=[param.imgdir num2str(i) '.jpg'];
            sift{i,1}=densesift_liy(imgpath,param);
        end
    end
    save('sift.mat','sift');
else
    sift=load('sift.mat');
    sift=sift.sift;
end

% step2 BOF模型，采用kmeans聚类
if ~exist('cens.mat','file') && ~exist('cens','var')        % 不存在 计算并保存
    [~,cens,~] = kmeans_liy(double(cell2mat(sift)),param.kmeansK);
    save('cens.mat','cens');
else
    cens=load('cens.mat');
    cens=cens.cens;
end

% step3 sparse coding
if ~exist('histimg.mat','file') && ~exist('histimg','var')       % 不存在 计算并保存
    if param.parallel
        if matlabpool('size')<=0
            matlabpool open local;
        end
        parfor i=1:param.nimgs
            histimg(i,:)=featurehist_liy(sift{i,1},cens,param.scmode);
        end
        matlabpool close;
    else
        for i=1:param.nimgs
            histimg(i,:)=featurehist_liy(sift{i,1},cens,param.scmode);
        end
    end
    save('histimg.mat','histimg');
else
    histimg=load('histimg.mat');
    histimg=histimg.histimg;
end

[~,id]=pdist2(histimg,histimg(ind,:),'euclidean','Smallest',num+1);
id=id(2:end);
% core end
%% show images
for i=1:num
    imgname=[imgpath.fpath num2str(id(i,1)) '.jpg'];
    set(eval(['handles.axes' num2str(i)]),'Visible','on');
    axes(eval(['handles.axes' num2str(i)]));
    imshow(imread(imgname));
end
set(handles.hint,'String','检索完毕，请选择图片重新检索...');

%% --- Executes on button press in selectimg.
function selectimg_Callback(hObject, eventdata, handles) 
% hObject    handle to selectimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 选择图像
[fname,fpath]=uigetfile('*.jpg','选择待匹配的图像');
img=imread([fpath fname]);
set(handles.oimg,'Visible','on');
set(handles.showimg,'Visible','on');

axes(handles.showimg);

imshow(img);

set(handles.hint,'String','请按检索按钮检索图片...');

imginfo.fpath=fpath;
imginfo.fname=fname;

setappdata(handles.selectimg,'imgpath',imginfo);

function hint_Callback(hObject, eventdata, handles)
% hObject    handle to hint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hint as text
%        str2double(get(hObject,'String')) returns contents of hint as a double


% --- Executes during object creation, after setting all properties.
function hint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function showimg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to showimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate showimg


% --- Executes on mouse press over axes background.
function showimg_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to showimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
