function ChooseWells(fname, opts, pname)
%CHOOSEWELLS User interface for DoAnis to choose wells in image

aa=get(0,'Diary'); if strcmpi(aa,'on'), diary off; end %just in case
if nargin<3, pname=''; end
if nargin<2 || isempty(opts), opts=DoAnisOpts; end
if nargin<1, fname=''; end
inst=ImReadS(fname, opts, pname);
if isempty(inst), return; end %user cancelled
boxlist=[1]; wellslimit=opts.wellslimit; fullimage=opts.fullimage;
slidermax=0.2; slidermin=0.02; %defaults if old DoAnisOpts
if isfield(opts,'wellslimitmax'), slidermax=opts.wellslimitmax; end
if isfield(opts,'wellslimitmin'), slidermin=opts.wellslimitmin; end
if wellslimit>slidermax, wellslimit=slidermax; end
if wellslimit<slidermin, wellslimit=slidermin; end

f=figure(1); clf;
set(f,'Visible','off','Position',[360,500,450,300]);
hFull = uicontrol('Style','radio','String','Full frame (ignore wells)',...
	'HorizontalAlignment','left','Position',[275,235,153,17],...
	'Value',fullimage,'Callback', @FullFr_CallBack);
hWLabel = uicontrol('Style','text','String','Threshold for Wells:',...
	'HorizontalAlignment','left','Position',[275,210,108,17]);
hWLabel2 = uicontrol('Style','text','String',num2str(opts.wellslimit,4),...
	'HorizontalAlignment','left','Position',[385,210,35,17]);
hWThresh = uicontrol('Style','slider','Max',slidermax,'Min',slidermin,...
	'Value',wellslimit,...
	'Position',[275,197,120,15],'Callback', @Thresh_CallBack);
hWGo = uicontrol('Style','pushbutton','String','ReCalc Wells',...
	'Position',[300,169,70,25],'Callback', @WGo_CallBack);
hBLabel = uicontrol('Style','text','String','Edit this WellID list for DoAnis',...
	'HorizontalAlignment','left','Position',[275,145,153,17]);
hBoxes = uicontrol('Style','edit','String',int2str(boxlist),...
	'HorizontalAlignment','left','Position',[275,119,153,25],...
	'Callback', @Boxes_CallBack);
hGo = uicontrol('Style','pushbutton','String','Go DoAnis',...
	'Position',[300,86,70,25],'Callback', @Go_CallBack);
hHelp = uicontrol('Style','pushbutton','String','Show Help (AnisTable)',...
	'Position',[275,40,125,25],'Callback', @Help_CallBack);

hUIWells=[hWThresh,hWGo,hBoxes];
hUIText=[hFull, hWLabel, hWLabel2, hWGo, hBLabel, hBoxes, hGo];
set(hUIText, 'FontName','Helvetica','FontSize',8);
set(f,'MenuBar','none','ToolBar','none');
hUIAll=[hFull, hWLabel, hWLabel2, hWThresh, hWGo, hBLabel, hBoxes, hGo, hHelp];
ha=axes('Units','pixels','Position',[50,65,200,185]);
FindDrawImWells(1);
boxlist=1:numel(wbb.s);
UpdateControls();

%set([f hUIAll],'Units','normalized');
set(f,'Name','Choose Wells for DoAnis'); movegui(f,'center');
set(f,'Visible','on');

function Go_CallBack(hObject,eventdata)
	%display(['Analyzing "' inst.fname '" boxes:' int2str(boxlist)]);
	set(hGo,'Enable','off'); drawnow; %prevent multi-clicks
	DoAnis(inst,opts,'',boxlist);
end

function Help_CallBack(hObject,eventdata)
	AnisTable('','',1);
end

function Boxes_CallBack(hObject,eventdata)
	boxlist=str2num(get(hObject,'string'));
	a=max(boxlist);
	if a>numel(wbb.s),
		errordlg('Not that many Wells!');
	end
end

function FullFr_CallBack(hObject,eventdata)
	fullimage=get(hObject,'Value');
	opts.fullimage=fullimage;
	UpdateControls();
end

function Thresh_CallBack(hObject,eventdata)
	wellslimit=get(hObject,'Value');
	set(hWLabel2,'String',num2str(wellslimit));
	UpdateControls();
end

function WGo_CallBack(hObject,eventdata)
	if wellslimit==opts.wellslimit, return; end
	opts.wellslimit=wellslimit;
	cla; drawnow;
	FindDrawImWells(1);
	boxlist=1:numel(wbb.s);
	UpdateControls();
end

function FindDrawImWells(findwells)
	if findwells,
		wbb=FindWells(inst.wellsim,opts.wellslimit); end
	imagesc(inst.wellsim); axis ij; axis equal; axis tight;
	%title([strrep(inst.fname,'_','\_') '; wellslim=' num2str(opts.wellslimit)]);
	title([strrep(inst.fname,'_','\_') ]);
	ShowBoxes(wbb);
	xlb=['Image has ' int2str(inst.imnum) ' channel'];
	if inst.imnum~=1, xlb=[xlb 's.'];
		else xlb=[xlb '.']; end
	xlabel(xlb);
end

function UpdateControls
	hUIWells=[hWThresh,hWGo,hBoxes];
	if fullimage,
		set(hUIWells,'Enable','off');
	else
		set(hUIWells,'Enable','on');
		if abs(wellslimit-opts.wellslimit)<5e-5,
			set(hWLabel2,'ForegroundColor',[0 0 0]);
			set(hWGo,'ForegroundColor',[0 0 0]);
		else set(hWLabel2,'ForegroundColor',[1 0 0]);
			set(hWGo,'ForegroundColor',[1 0 0]); end
		set(hBoxes,'String',int2str(boxlist));
	end
end

end


function ShowBoxes(wbb)
hold on;
nbb=numel(wbb.s);
for i=1:nbb,
	bb=wbb.s(i).BoundingBox;
	bb=round(bb); %edges sometimes 0.5! round up to use as index and reduce widths by 1
	vx=[bb(1) bb(1) bb(1)+bb(3) bb(1)+bb(3) bb(1)];
	vy=[bb(2) bb(2)+bb(4) bb(2)+bb(4) bb(2) bb(2)];
	plot(vx, vy, 'y-');
	cn=wbb.s(i).Centroid;
	text(cn(1),cn(2),int2str(i),'FontSize',14, 'FontWeight','bold', ...
		'HorizontalAlignment','center','BackgroundColor',[.7 .7 0]);
	eb=wbb.B{i}; plot(eb(:,2), eb(:,1), 'm');
end
hold off
end
