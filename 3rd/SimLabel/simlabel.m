function simlabel
%
%(Pour windows et linux)
% sorte de table de mixage pour simuler des spectres enregistres a 
% temperature ambiante ou basse temperature. Autant d'especes que souhaitees avec 1 ou 2 couplages
% hyperfins (spin nucleaire au choix - axes tenseur hyperfin paralleles aux 
% axes de g). Visualisation en direct (sur le spectre experimental ou pas): 
% Simulation et fit avec easyspin. 
%  EE version apr2015 
% version 3.0 :duplicate component + 1 composante weighted :changer
% bug nouveau real time corrige
% mimilrescale +afficher weight quand norm weighted sur le max
%3.1: table pour spectres experimentaux + valeur par defaut = vraies
%valeurs



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% 14 April 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


warning('off','MATLAB:oldPfileVersion') % eviter warning: pcode file ...
warning('off','MATLAB:hg:uicontrol:ParameterValuesMustBeValid') %eviter warning slider out of range

path4doc = mfilename('fullpath');%chemin de la derniere function lancee
path4doc=path4doc(1:end-9); %chemin pour ouvrir la doc



% au lancement, fermeture de la fenetre SimLabel prealablement ouverte 
closeSimLabel();

clc; %clear command window
evalin('base','clear'); %clear workspace de base

%% SimLabel_main
ftsz=11;%fontsize en pixels

% if isempty(findobj('type','figure'))
%     hSimLabelmain=figure(1);
% else
%    hSimLabelmain=figure(max(findobj('type','figure'))+1); %pour ne pas superposer des figures
% end;
hSimLabelmain=figure();
%taille ecran  taille fenetre
scrszpix = get(0,'ScreenSize'); %taille ecran [left, bottom, width, height] en pixels
%scrszcm=scrszpix/get(0,'screenpixelsperinch')*2.54; %1inch=2.54cm  taille ecran en cm

set(hSimLabelmain,'Units','pixels','Outerposition',...    
    [scrszpix(3)/7 0.1*scrszpix(4) 700 scrszpix(4)*0.8],...
    'Name','SimLabel_main','Menubar', 'none', 'Toolbar', 'figure',...%'resize','off',...
    'NumberTitle','off','DoubleBuffer','on','CloseRequestFcn',@closeSimLabel,...
    'color',get(0,'DefaultUicontrolBackgroundColor'));


%%% panel bas %%%
hpanelmain = uipanel(...
        'Parent',hSimLabelmain,...
        'Title','',...
        'Position',[0 0 1 0.25]);
%%% delta B %%%
hdeltaB1=uicontrol('Style','text','Units','Normalized','pos',[0.12 0.78 0.10 0.17],...
    'parent',hpanelmain,'String',{'deltaB =';'(real-read)'},'HorizontalAlignment','center',...
    'fontunits','pixels','fontsize',ftsz,'enable','off','TooltipString','Experimental offset of magnetic field');
hdeltaBval=uicontrol('Style','edit','Units','Normalized','pos',[0.21 0.84 0.05 0.1],'BackgroundColor','w',...
    'parent',hpanelmain,'String',num2str(0,'%3.2f'),'Callback', @defdeltaB,'fontunits','pixels','fontsize',ftsz,...
    'enable','off','TooltipString','Experimental offset of magnetic field');
hdeltaBslid=uicontrol('Style','slider','Units','Normalized','pos',[0.26 0.84 0.02 0.1],'BackgroundColor',[0.9 0.9 0.9],...
    'parent',hpanelmain,'String',num2str(0,'%3.2f'),'Callback', @sliddeltaB,'fontunits','pixels','fontsize',ftsz,...
    'Min',-20,'Max',+20,'Value',0,'SliderStep',[0.01/40 1/40],'enable','off','TooltipString','Experimental offset of magnetic field');

hdeltaB2=uicontrol('Style','text','Units','Normalized','pos',[0.28 0.82 0.03 0.1],...
    'parent',hpanelmain,'String','mT','HorizontalAlignment','center','fontunits','pixels',...
    'fontsize',ftsz,'enable','off','TooltipString','Experimental offset of magnetic field');

%%% push buttons %%%
haddcomp=uicontrol('Style','pushbutton','String','+','Units','Normalized',...
    'pos',[0.01 0.41 0.09 0.15],'parent',hpanelmain,'Callback', @addcomponent,...
    'TooltipString','Add new component','fontunits','pixels','fontsize',ftsz*1.2);
hdefaultpar=uicontrol('Style','pushbutton','String','init.','Units','Normalized',...
    'pos',[0.1 0.41 0.03 0.15],'parent',hpanelmain,'Callback', @reinitcomponent,...
    'TooltipString','Set default values for next components','fontunits','pixels','fontsize',ftsz);

uicontrol('Style','pushbutton','String','Load Exp.','Units','Normalized',...
    'pos',[0.01 0.82 0.12 0.15],'parent',hpanelmain,'Callback', @loadexpcllbck,...
    'TooltipString',sprintf('Load new experimental spectrum\n*.DSC or *.SPC'),'fontunits','pixels','fontsize',ftsz);
uicontrol('Style','pushbutton','String','Load Sim.','Units','Normalized',...
    'pos',[0.01 0.59 0.12 0.15],'parent',hpanelmain,'Callback', @loadparam,...
    'TooltipString','Load previous simulation','fontunits','pixels','fontsize',ftsz);

hrealtime=uicontrol('Style','checkbox','String','Real Time','Units','Normalized',...
    'fontunits','pixels','fontsize',1.1*ftsz,... %largeur simul anisotrope
    'pos',[0.01 0.215 0.15 0.18],'parent',hpanelmain,'Callback',@chkrealtime,...
    'TooltipString',sprintf('Simulation calculated in real time.\nA first "Run Simul." is needed,\nonly one component is calculated.'),...
    'value',0,'fontweight','bold');
hrunsimul=uicontrol('Style','pushbutton','String','Run Simul.','Units','Normalized',...
    'pos',[0.01 0.01 0.12 0.18],'parent',hpanelmain,'Callback', @runsimulcllbck,...
    'fontunits','pixels','fontsize',ftsz,'enable','on',...
    'TooltipString',sprintf('Run simulation with EasySpin (chili or pepper function).\nAll components are calculated.'));%,'interruptible','off');

hsavesimul=uicontrol('Style','pushbutton','String','Save Sim.','Units','Normalized',...
    'pos',[0.135 0.59 0.12 0.15],'parent',hpanelmain,'Callback', @savesimul,'enable','off',...
    'fontunits','pixels','fontsize',ftsz,'TooltipString',sprintf('Save current simulation\n(only included components are saved)'));
hcurrentsimul=uicontrol('Style','pushbutton','String','Buffer','Units','Normalized',...
    'pos',[0.135 0.41 0.12 0.15],'parent',hpanelmain,'Callback', @currentsimul,'enable','off',...
    'fontunits','pixels','fontsize',ftsz,'TooltipString','Display last simulation (not saved)');

simultype={'Slow Motion';'Frozen Solution'};
hsimultype=uicontrol(...
        'Parent',hpanelmain,...
        'FontUnits','pixels',...
        'FontSize',ftsz,...
        'BackgroundColor','w',...
        'Units','normalized',...
        'Callback',@func4easyspin,...
        'Position',[0.135 0.21 0.15 0.15],...
        'String',simultype,...
        'Style','popupmenu',...
        'TooltipString',sprintf('Select the simulation type,\nrelated to the choice of EasySpin function (chili or pepper)'),...
        'Value',1);

hesfit=uicontrol('Style','pushbutton','String','Fit','Units','Normalized',...
    'pos',[0.135 0.01 0.12 0.18],'parent',hpanelmain,'Callback', @openesfit,'enable','on',...
    'fontunits','pixels','fontsize',ftsz,'TooltipString','Open "esfit" panel (fitting with EasySpin)');

% hquitesfit=uicontrol('Style','pushbutton','String','Quit "esfit"','Units','Normalized',...
%     'pos',[0.35 0.05 0.08 0.15],'parent',hpanelmain,'Callback', @quitesfit,'enable','on','visible', 'off',...
%     'fontunits','pixels','fontsize',ftsz,'TooltipString','Import data from "esfit" (fitting with EasySpin)');

%%% list exp%%%
hlistexp=uicontrol('Style','listbox','Units','Normalized','pos',[0.32 0.03 0.3 0.88],...
    'parent',hpanelmain,'max',2,'min',0,'enable','off','Callback',@reloadexp,'fontunits','pixels','fontsize',ftsz,...
    'TooltipString','Experiments: select one or more...','backgroundcolor','w');
hsuprfromlistexp=uicontrol('Style','pushbutton','String','X','Units','Normalized','HorizontalAlignment','center',...
    'pos',[0.62 0.84 0.03 0.08],'parent',hpanelmain,'Callback', @suprfromlistexp,'enable','off',...
    'TooltipString','Remove higlighted Exp. from list','fontunits','pixels','fontsize',ftsz);
hlistexptxt=uicontrol('Style','text','Units','Normalized','pos',[0.32 0.91 0.3 0.08],...
    'parent',hpanelmain,'String','Experiments','HorizontalAlignment','center','fontunits','pixels',...
    'fontsize',1.1*ftsz,'fontweight','bold','TooltipString','Table of experimental spectra');


%%% list simul%%%
hlist=uicontrol('Style','listbox','Units','Normalized','pos',[0.665 0.03 0.3 0.88],...
    'parent',hpanelmain,'max',2,'min',0,'enable','off','Callback',@reload,'fontunits','pixels','fontsize',ftsz,...
    'TooltipString','Simulations: select one or more...','backgroundcolor','w');
hsuprfromlist=uicontrol('Style','pushbutton','String','X','Units','Normalized','HorizontalAlignment','center',...
    'pos',[0.965 0.84 0.03 0.08],'parent',hpanelmain,'Callback', @suprfromlist,'enable','off',...
    'TooltipString','Remove higlighted simul. from list','fontunits','pixels','fontsize',ftsz);
hexpfromlist=uicontrol('Style','pushbutton','String',char(94),'Units','Normalized','HorizontalAlignment','center',...
    'pos',[0.965 0.75 0.03 0.08],'parent',hpanelmain,'Callback', @expfromlist,'enable','off',...
    'TooltipString',sprintf(['Export higlighted simul. in .txt with parameters in .par.\nIf displaid, exp. spec is included.']),'fontunits','pixels','fontsize',ftsz);
hlisttxt=uicontrol('Style','text','Units','Normalized','pos',[0.665 0.91 0.3 0.08],...
    'parent',hpanelmain,'String','Saved Simulations','HorizontalAlignment','center','fontunits','pixels',...
    'fontsize',1.1*ftsz,'fontweight','bold','TooltipString','Table of saved simulations');

%%% graphes %%%
hspecaxes=axes('parent',hSimLabelmain,'OuterPosition',[0 0.25 1 0.75],'Position',[0.05 0.30 0.9 0.65],...
                'Ytick',NaN,'Box','on','Xtick',NaN,'ButtonDownFcn',@MouseleftclickaxeCllbck);
hold all
xlabel(hspecaxes,'Magnetic Field [mT]');   

hsuprexp=uicontrol('Style','pushbutton','String','X','Units','Normalized','HorizontalAlignment','center',...
    'pos',[0.96 0.93 0.03 0.02],'parent',hSimLabelmain,'Callback', @suprexp,'enable','off',...
    'TooltipString','Remove experimental spectrum','fontunits','pixels','fontsize',ftsz);

hsuprsimul=uicontrol('Style','pushbutton','String','X','Units','Normalized','HorizontalAlignment','center',...
    'pos',[0.96 0.90 0.03 0.02],'parent',hSimLabelmain,'Callback', @suprsimul,'enable','off',...
    'TooltipString','Remove simulated spectrum','fontunits','pixels','fontsize',ftsz,'ForegroundColor','m');

hsavefig=uicontrol('Style','pushbutton','String','Save fig.','Units','Normalized','fontunits','pixels','fontsize',ftsz,...
            'pos',[0.01 0.96 0.10 0.03],'parent',hSimLabelmain,'Callback', @savefig,...
            'TooltipString','Save figure in .fig or .bmp with parameters in .par','enable','on');
        
hfs=uicontrol('Style','pushbutton','String','FS','Units','Normalized','fontunits','pixels','fontsize',ftsz,...
            'pos',[0.13 0.96 0.05 0.03],'parent',hSimLabelmain,'Callback', @cllbckfs,...
            'TooltipString',sprintf('Full scale of\n-exp. (first click)\n-simul. (second click)'),'enable','on');
        
hfreq=uicontrol('Style','text','Units','Normalized','pos',[0.3 0.955 0.5 0.02],...[0.43 0.96 0.42 0.02],...
    'parent',hSimLabelmain,'HorizontalAlignment','center',...
    'fontunits','pixels','fontsize',ftsz,'visible','on');%,'backgroundcolor','w');

hexpname=uicontrol('Style','text','Units','Normalized','pos',[0.30 0.98 0.5 0.02],...[0.20 0.96 0.22 0.02]
    'parent',hSimLabelmain,'HorizontalAlignment','center',...
    'fontunits','pixels','fontsize',ftsz,'visible','off');%,'backgroundcolor','w');

hfitindicator=uicontrol('Style','text','Units','Normalized','pos',[0.84 0.965 0.14 0.02],...
    'parent',hSimLabelmain,'HorizontalAlignment','center','visible','off',...
    'fontunits','pixels','fontsize',ftsz*1.2,'TooltipString',sprintf('Fit indicator:\nderivative/absorption spectra\n(best fit: fit = 0 / 0)'));

hexpx=uicontrol('Style','pushbutton','String','<x>','Units','Normalized','fontunits','pixels','fontsize',ftsz,...
            'pos',[0.05 0.255 0.04 0.03],'parent',hSimLabelmain,'Callback', @cllbckexpandx,...
            'TooltipString','Expand x axes (x2)');
hsetB=uicontrol('Style','pushbutton','String','Set','Units','Normalized','fontunits','pixels','fontsize',ftsz,...
            'pos',[0.09 0.255 0.04 0.03],'parent',hSimLabelmain,'Callback', @cllbcksetB,...
            'TooltipString','Set magnetic field range');        

hexpy=uicontrol('Style','pushbutton','String','<y>','Units','Normalized','fontunits','pixels','fontsize',ftsz,...
            'pos',[0.005 0.32 0.04 0.03],'parent',hSimLabelmain,'Callback', @cllbckexpandy,...
            'TooltipString','Expand y axes (x2)');

hnormpanel=uibuttongroup(...
        'Parent',hSimLabelmain,...
        'BorderType','line',...'none'
        'BorderWidth',3,...
        'HighlightColor','k',...
        'Title','',...
        'Position',[0.96 0.30 0.03 0.1],...[0.96 0.70 0.03 0.15],...
        'SelectedObject',[],...
        'SelectionChangeFcn',@normradiocllbck,...
        'OldSelectedObject',[]);        
hnormI = uicontrol(...
        'Parent',hnormpanel,...
        'Style','radiobutton',...
        'Units','normalized',...
        'Position',[0 0.55 0.9 0.4],...[0 0.6 1 0.4],...
        'String','',...
        'FontUnits','pixels',...
        'FontSize',ftsz,...
        'TooltipString','Normalization to integrated intensity',...
        'value',0,...
        'Tag','intensity'); 
hnormminmax = uicontrol(...
        'Parent',hnormpanel,...
        'Style','radiobutton',...
        'Units','normalized',...
        'Position',[0 0.05 0.9 0.4],...[0 0.3 1 0.4],...
        'String','',...
        'FontUnits','pixels',...
        'FontSize',ftsz,...
        'TooltipString',sprintf('Normalisation to amplitude\nexp.: [max-min]=1\nsim.: [max-min]=Scaling factor'),...
        'value',1,...
        'Tag','minmax');%,... 
    
hscaling=uicontrol('Style','text','Units','Normalized','pos',[0.87 0.255 0.1 0.04],...
    'parent',hSimLabelmain,'String',{'Scaling';'factor'},'HorizontalAlignment','center',...
    'fontunits','pixels','fontsize',ftsz,'enable','on','TooltipString',sprintf('Scaling factor for simulations\n(normalized with amplitude)'));
hscalingval=uicontrol('Style','edit','Units','Normalized','pos',[0.955 0.255 0.04 0.04],'BackgroundColor','w',...
    'parent',hSimLabelmain,'String',num2str(1,'%3.2f'),'Callback', @defscaling,'fontunits','pixels','fontsize',ftsz,...
    'enable','on','TooltipString',sprintf('Scaling factor for simulations\n(normalized with amplitude)'));     
    
hcomponentletter=uicontrol('Style','text','Units','Normalized','pos',[0.64 0.30 0.3 0.2],...
    'parent',hSimLabelmain,'HorizontalAlignment','right',...
    'fontunits','pixels','fontsize',ftsz*1.3,'visible','off','backgroundcolor','w');

hcursorinfo=uicontrol('Style','text','Units','Normalized','pos',[0.06 0.31 0.25 0.02],...
    'parent',hSimLabelmain,'HorizontalAlignment','center','visible','off',...
    'fontunits','pixels','fontsize',ftsz,'fontweight','bold','backgroundcolor','w');
    
        %%%% pour ne garder que les outils zoomin, zoomout et main
hToolbar = findall(hSimLabelmain,'tag','FigureToolBar'); %handle toolbar
halltoolbar=allchild(hToolbar);%tous les handles de la toolbar
hzoomin=findall(halltoolbar,'TooltipString','Zoom In');
hzoomout=findall(halltoolbar,'TooltipString','Zoom Out');
hhand=findall(halltoolbar,'TooltipString','Pan');
halltoolbar(halltoolbar==hzoomin)=[];%supprime 1 handle a conserver
halltoolbar(halltoolbar==hzoomout)=[];%supprime 1 handle a conserver
halltoolbar(halltoolbar==hhand)=[];%supprime 1 handle a conserver
set(halltoolbar,'visible','off')

hdoc=uicontrol('Style','pushbutton','String','?','Units','Normalized','fontunits','pixels','fontsize',ftsz,...
            'pos',[0.27 0.012 0.035 0.03],'parent',hSimLabelmain,'Callback', @opendoc,...
            'TooltipString','Open documentation');

%% ================ "variables globales" + initialisations ===============

easyspinfunc=@chili; %par defaut Slow Motion
timeenable='on'; %=> temps de correlation
%pos_SimLabelx=[scrszpix(3)-scrszpix(3)/20-800 scrszpix(4)-scrszpix(4)/20-280-scrszpix(4)*0.1*(fignumber-1) 800 280];
kolor= [0 0 1; %1  pour les differentes composantes
        0.3 0.8 0; %2
        1 0.6 0; %3
        0 0.8 1; %4
        0.6 0 0; %5
        0.75 0.75 0; %6
        1 0 0; %7
        0 1 0.5; %8
        0.7 0 1; %9
        0.4 0.4 0.4;%10
        0.8 0.8 0.8];%11
    
poscomponentfig=ones(size(kolor,1),4); %positions des fenetres de component
posy=ones(size(kolor,1));
posx=scrszpix(3)-scrszpix(3)/20-800;
for ind=1:size(poscomponentfig,1) %initialisation
    posy(ind)=scrszpix(4)-scrszpix(4)/20-280-scrszpix(4)*0.1*(ind-1);
    if posy(ind)<0
        posy(ind)=posy(ind-1);
    end
    poscomponentfig(ind,:)=[posx posy(ind) 800 280];
end
    
%busy=0; %si calcul en cours busy=1    
% bornes des sliders g
gmin=-50;
gmax=1800;
minstepg=5/gmax; %facteur d'increment min de g-2
maxstepg=50/gmax; %facteur d'increment max de g-2

% bornes des sliders lw (lorentzian et gaussian) valeur par defaut pour
% slow motion
lwmin=0;
lwmax=0.3;
minsteplw=0.01/lwmax; %facteur d'increment min 
maxsteplw=0.05/lwmax; %facteur d'increment max 


% bornes du slider correlation time
tcorrmin=1e-12;%s
tcorrmax=1e-8;%s
minstep=5e-2; %facteur d'increment min de t_corr (s)
maxstep=0.1; %facteur d'increment max de t_corr (s)

% bornes des sliders A
Amin=0;%mT
Amax=7;%mT
minstepA=0.01/Amax; %facteur d'increment min de A (mT)
maxstepA=0.1/Amax; %facteur d'increment max de A (mT)

differentI={'';'1/2';'1';'3/2';'2';'5/2'}; %different spin nucleaires possibles
differentNucs={'';'1H';'14N';'7Li';'36Cl';'17O'}; %different noyau associes au spins precedents

%handle d'initialisation
versionyear=version('-date');
versionyear=str2double(versionyear(end-4:end)); %annee version matlab
if versionyear>=2014
        hinit=gobjects; %handle=structure
else
        hinit=NaN; %handle=double
end

%componenth=[]; %structure contenant les handles des fenetres SimLabel_X et des uicontrol associes
componenth = struct('hfig',hinit,... handles d'une figure pour initialisation (1er element du tableau de structure componenth)
    'hname',hinit,'hchk',hinit,'hvisible',hinit,'hhide',hinit,...
    'htextweight',hinit,'heditweight',hinit,'htextpercent',hinit,...
    'hedittime',hinit,'hslidtime',hinit,...
    'heditlorentzian',hinit,'hslidlorentzian',hinit,'heditgaussian',hinit,'hslidgaussian',hinit,...
    'hpanelg',hinit,'heditg',[hinit hinit hinit],'hslidg',[hinit hinit hinit],'haxialg',hinit,'hmarkerg',[hinit hinit hinit],'hgmoy',hinit,...
    'hpopupI',[hinit hinit],'haxialA',[hinit hinit],'heditA',[hinit hinit hinit;hinit hinit hinit],'hslidA',[hinit hinit hinit;hinit hinit hinit],...
    'hAmoy',[hinit hinit],'hpanelA',[hinit hinit],'hmarkerA',[hinit hinit hinit;hinit hinit hinit],...
    'hplot',hinit);

hpoint=hinit; %initialisation du handle du point clique sur spectre exp
handlesenab4comp=[];% initialisation des handles a rendre enable off pendant le mode comparaison

componentdatainit=struct(... donnees de composante pour initialisation (1er element du tableau de structure componentdata)
    'name','',...
    'color',[NaN NaN NaN],...
    'weightval',1,...
    'tcorrval',3e-10,...
    'gaussianval',0.1,...
    'lorentzianval',0,...
    'gval',[2.00860 2.00610 2.00220],...
    'axialcombinationg',[NaN NaN],... %si g axial [i j] avec i et j les deux coordonnees egales
    'Istr',{{'1',''}},...
    'Aval',[0.50 0.50 3.5;NaN NaN NaN],...
    'axialcombinationA',[1 2;NaN NaN],... %si A1 axial [i j; NaN NaN] avec i et j les deux coordonnees egales
    'include',1,...
    'status',0,...% 0='hide'  1='visible'
    'specsimul',[],...%simulation de la composante
    'type','Slow Motion');%type de simulation (la meme pour toutes les composantes!) 'Slow Motion'(defaut) ou 'Frozen Solution'

componentdata=componentdatainit;
Sysinit=struct('g',componentdata.gval,...%initialisation Structure systeme de spin pour simul easyspin / {} car tous les Sys n'ont pas les memes champs
           'lw',[componentdata.gaussianval componentdata.lorentzianval],...
           'logtcorr',log10(componentdata.tcorrval),'A',mt2mhz(componentdata.Aval(1,:)),'Nucs','14N',...
           'weight',1); %Structure systeme de spin pour easyspin
Sys{1}=Sysinit;
Exp=[]; %init structure experimentale pour easyspin
defaultRangeg=[2.05 1.96]; %g pour  plage de champ par default

bufferdatainit.Syssimul=Sys; %pour mise en tampon de la simul venant d'etre calculee
bufferdatainit.datasimul=componentdata;
bufferdatainit.Exp=Exp;
bufferdata=bufferdatainit;
runsim=false; %aucune simul lancee


reloading=false; %indicateur de recharge de simul.  en train ou non de reafficher une simul selectionee dans la liste
hsimlabelcompare=hinit; %handle de la figure contenant la table en mode comparaison de simuls
possimlabelcompare=[scrszpix(3)/7+350 0 350 scrszpix(4)*0.8];

%differentes possibilites pour A axial
markerstatepossy={'off off off',...  A rhombique (off off off)
                  'on on off',...    A1=A2 et A3 (on on off)
                  'on off on',...    A1=A3 et A2 (on off on)
                  'off on on'};%     A2=A3 et A1 (off on on)
              
              
%loadexpspec=0; %indicateur de spectre experimental charge (si spectre charge, loadspecexp=1)
hspecexp=hinit; %init handle du plot du spectre exp
scalefact=1; %facteur d'affichage de la simul 
% delta=0; %shift pour affichage de la simul (max(simul)=0.5, min(simul)=-0.5) (a appliquer aux composantes seules) affiche=calcule*scalefact+delta



hplotsimall=hinit; %handle du plot simul avec toutes les composantes selectionnees
hlegend=hinit; %handle legende
expfreq=NaN; %frequence experimentale
dispsimulfreq=NaN;%frequence de la simulation affichee

fsfactor=0.05; %full scale factor pour joli affichage (si h=amplitude du spectre, ylim pour fenetre= [min-fsfactor*h max+fsfactor*h]

expspecf=[]; %nom fu fichier exp
path2expspec=[];%chemin du fichier exp
Bexpinit=[]; %champ experimental brut
Bexp=[]; %champ experimental decale
spec=[]; %spectre experimental brut
specexp=[]; %spectre experimental normalise
dispspecsimul=[]; %spectre de simul totale lie a hplotsimall (pour fullscale) (1024 points quand non vide)
Bsimul=[]; %champ de la simul totale (1024 points quand non vide)

hprevsimplot=[]; %handles des plots de simuls precedentes "en mode comparaison"
% specsimul=[];% simulations brutes de chaque composantes
% specsimul_=specsimul;

listfile=[]; % tous les noms de fichiers sauves et/ou charges
listpath=[]; % tous les chemins des fichiers sauves et/ou charges
list2disp=[]; % liste a afficher: '#: fichier'

listfileexp=[]; % tous les noms de fichiers exp charges
listpathexp=[]; % tous les chemins des fichiers exp charges
list2dispexp=[]; % liste a afficher: '#: fichier'


warningstatus=0;% pas de warning affiche
simulfile4esfit=[]; %simulation manuelle utilisee pour lancer esfit
handlesmainenab4esfit=[];%liste des handles enable 'on' sur simlabel_main avant esfit
%Sysfit=[]; %tableau systeme de spin envoye a esfit
%datafit=[]; % 1 structure regroupant toutes les composantes a envoyer a esfit
componentdatafit=componentdatainit;%composantes, utilisees pour esfit (pour l'info d'axialite)
%Vary=[]; %structure des parametres variables envoyes a esfit
alldata={}; %cell array contenant donnees affichees sur fenetre avant esfit
htable=hinit; %handle de la table de parametres a transferer a esfit
hOK4esfit=hinit; %handle bouton OK de la table de parametres a transferer a esfit
path4func4esfit=path2expspec;
%path4func4esfit=which('bmagn.p');
%path4func4esfit=path4func4esfit(1:end-8);%chemin du dossier easyspin pour placer la function de simul temporaire pour fit
correltab=[]; %table des corelations pour esfit

hmt2mhz=hinit; %handle figure 

path2keep=pwd;%chemin mis en memoire pour prochaines ouvertures ou sauvegardes...

%% ================= FUNCTIONS ============================================

%% Callback functions de SimLabel_main

function closeSimLabel(~,~) %a la fermeture de la fenetre principale SimLabel_main
    allfigname=get(findobj('type','figure'),'name'); %cellarray avec noms des figures ouvertes
    if ~isempty(allfigname)
        if ischar(allfigname) %1! fenetre
         allfigname={allfigname};
        end
        for i=1:numel(allfigname)
            if strncmp(allfigname{i},'SimLabel',8) %compare les 8 premiers caracteres
                delete(findobj('type','figure','name',allfigname{i}));
            end
        end
    end
    clear componenth componentdata Sys;
    
    
   hfigesfit=findobj('type','figure','-and','name','EasySpin Least-Squares Fitting'); 
   if ishandle(hfigesfit)
       close(hfigesfit)
   end 
    %colormap('default') %pour applications futures
end

function chkrealtime(~,~)
    if get(hrealtime,'Value')==1
        if ishandle(hplotsimall)

            warnstatus=testwarning();%teste plage de champs et frequences :1 si warning s'affiche, 0 sinon
            if ~warnstatus
                set (hrunsimul,'enable','off');
                set (hexpx,'enable','off');
                set (hsetB,'enable','off');
                set (hzoomin,'enable','off');
                set (hzoomout,'enable','off');
                set (hhand,'enable','off');
                set (haddcomp,'enable','off');
                set (hsimultype,'enable','off');
                set (hlist,'enable','off');
                set (hsuprfromlist,'enable','off');
                set (hexpfromlist,'enable','off');
                set (hlistexp,'enable','off');
                set (hsuprfromlistexp,'enable','off');
                set (hdeltaB1,'enable','off');
                set (hdeltaB2,'enable','off');
                set (hdeltaBslid,'enable','off');
                set (hdeltaBval,'enable','off');
                set (hfs,'enable','off');
                pan off
                zoom off
            else
                set(hrealtime,'Value',0)
            end
        else
            set(hrealtime,'Value',0)
            uiwait(msgbox({'WARNING:   No global simulation in memory...';'';'You must first perform global simulation with "Run. Simul."...'},...
                 'SimLabel_WARNING','Warn','modal'));
        end
    else
        set(hrunsimul,'enable','on');
        set (hexpx,'enable','on');
        set (hsetB,'enable','on');
        set (hzoomin,'enable','on');
        set (hzoomout,'enable','on');
        set (hhand,'enable','on');
        set (haddcomp,'enable','on');
        set (hsimultype,'enable','on');
        set (hlist,'enable','on');
        set (hsuprfromlist,'enable','on');
        set (hexpfromlist,'enable','on');
        set (hlistexp,'enable','on');
        set (hsuprfromlistexp,'enable','on');
        set (hdeltaB1,'enable','on');
        set (hdeltaB2,'enable','on');
        set (hdeltaBslid,'enable','on');
        set (hdeltaBval,'enable','on');
        set (hfs,'enable','on');

    end
           
end


function loadexpcllbck(~,~)
    [filename,path2exp]=uigetfile(fullfile(path2keep,'*.DSC;*.SPC'),'Select Spectrum to Open','MultiSelect', 'on'); %ouverture boite de dialogue dans repertoire courant (.DSC selectionnes)
    
    if ischar(filename) %1!fichier selectione
         filename={filename};
     end
    
    
    if not(isnumeric(filename)) %no cancel;
         for i=1:numel(filename)
                add2listexp(filename{i},path2exp);
         end
          loadexp(filename{end},path2exp);%affichage du dernier

%         set(hlistexp,'value',find(ismember(listfileexp,filename{i})));
        expspecf=filename{1};
        path2expspec=path2exp;
        set(hlistexp,'enable','on');
        set(hsuprfromlistexp,'enable','on');
        path2keep=path2exp;

    end;
end       

function loadexp(filename,path2exp)
    set(hdeltaB1,'enable','on');
   set(hdeltaB2,'enable','on');
   set(hdeltaBval,'enable','on');
   set(hdeltaBslid,'enable','on');
   set(hsuprexp,'enable','on');

%         if ishandle(hspecexp)
%             delete(hspecexp)
%         end;

    [B,spec,param]=eprload(fullfile(path2exp,filename));
    Bexpinit=B/10;% B en G Bexpinit en mT
    if isfield(param,'MWFQ')
        expfreq=param.MWFQ*1e-9; %frequence exp en GHz from ELEXSYS
    elseif isfield(param,'MF')
        expfreq=param.MF; %en GHz from ESP
    else
        disp('No experimental frequency...')
    end

    specexp=mimilrescale(Bexpinit,spec,1);
    expdeltaBf=[filename(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
    if exist([path2exp,expdeltaBf], 'file')
        load([path2exp,expdeltaBf]); %definition de deltaB
    else
        deltaB=0;
    end
    set(hdeltaBval,'string',num2str(deltaB,'%3.2f'))
    set(hdeltaBslid,'value',deltaB);
    plotspecexp(deltaB); %trace spectre exp en tenant compte de deltaB
    set(hfitindicator,'visible','off');

    set(hexpname,'string',filename,'visible','on');
    
    sep=filesep();% / ou \ selon systeme exploitation
    if strcmp(sep,'\') %windows
        path2disp=strrep(path2exp,sep,[sep,sep]);
    else %linux
        path2disp=path2exp;
    end
    
    set(hexpname,'TooltipString',sprintf(['Experimental spectrum file in\n',path2disp,'\nfrequency = ',num2str(expfreq),'GHz']));
    
    if ishandle(hplotsimall)
        if get(hrealtime,'value')==1
            testwarning();
        end
        dispfitindicator() %affichage de l'indicateur de fit si bonnes plages de champ et bonnes frequences
    end

end
function defdeltaB(~,~)
    deltaB=str2double(get(hdeltaBval,'string'));
    if isnan(deltaB)
        deltaB=0;
    end
    set(hdeltaBval,'string',num2str(deltaB,'%3.2f'));
    
    set(hdeltaBslid,'value',deltaB);
    plotspecexp(deltaB);
%     if deltaB~=0
%          testwarning4deltaB();
%          set(hfitindicator,'visible','off'); 
%     end
%      if ishandle(hspecexp) && deltaB~=0 %enregistrement du deltaB s'il existe
%          rang2save=get(hlistexp,'value');
%         expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
%         save(fullfile(listpathexp{rang2save},expdeltaBf),'deltaB');
%      end

    rang2save=get(hlistexp,'value');
    expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB ?
    if ~exist(expdeltaBf,'file') %pas de fichier deltaB
       if deltaB~=0
         testwarning4deltaB();
         set(hfitindicator,'visible','off'); 
         rang2save=get(hlistexp,'value');
         expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
         save(fullfile(listpathexp{rang2save},expdeltaBf),'deltaB');
       end 
    else 
         testwarning4deltaB();
         set(hfitindicator,'visible','off'); 
         rang2save=get(hlistexp,'value');
         expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
         save(fullfile(listpathexp{rang2save},expdeltaBf),'deltaB');
    end

end

function sliddeltaB(~,~)
    deltaB=(get(hdeltaBslid,'value'));
    set(hdeltaBval,'string',num2str(deltaB,'%3.2f'));
    plotspecexp(deltaB);
%    testwarning4deltaB();
    set(hfitindicator,'visible','off'); 
%      if ishandle(hspecexp) && deltaB~=0 %enregistrement du deltaB s'il existe
%          rang2save=get(hlistexp,'value');
%         expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
%         save(fullfile(listpathexp{rang2save},expdeltaBf),'deltaB');
%      end
    rang2save=get(hlistexp,'value');
    expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB ?
    if ~exist(expdeltaBf,'file') %pas de fichier deltaB
       if deltaB~=0
         testwarning4deltaB();
         set(hfitindicator,'visible','off'); 
         rang2save=get(hlistexp,'value');
         expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
         save(fullfile(listpathexp{rang2save},expdeltaBf),'deltaB');
       end 
    else 
         testwarning4deltaB();
         set(hfitindicator,'visible','off'); 
         rang2save=get(hlistexp,'value');
         expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
         save(fullfile(listpathexp{rang2save},expdeltaBf),'deltaB');
    end
end

function defscaling(hobject,~)
    scalingfactor=str2double(get(hobject,'string'));
    if isnan(scalingfactor) || scalingfactor==0
        scalingfactor=1;
    end
    set(hobject,'string',num2str(scalingfactor,'%3.2f'));
    if scalingfactor~=1
        set(hobject,'backgroundcolor',[0.98 0.5 0.45]);
    else
        set(hobject,'backgroundcolor','w');
    end
    
    %si une selection dans liste
    rangselected=get(hlist,'value');
    realtimestatus=get(hrealtime,'value');
    
    if ishandle(hspecexp)
         specexp=mimilrescale(Bexp,spec,1);
         set(hspecexp,'ydata',specexp)
    end
    runsimul(hinit)

    cllbckfs %full scale sur sim
    cllbckfs %full scale sur exp
    if ~isempty(rangselected)
        set(hlist,'value',rangselected)
    end
    if realtimestatus==1
        chkrealtime
    end
    
    if ~isempty(rangselected) %si selection dans la liste de simul affichage du chemin dans tooltipstr de freq
        path2sim=listpath{rangselected};
        sep=filesep();% / ou \ selon systeme exploitation
        if strcmp(sep,'\') %windows
             path2disp=strrep(path2sim,sep,[sep,sep]);
        else %linux
             path2disp=path2sim;
        end
        set(hfreq,'TooltipString',sprintf(['Saved simulation file in\n',path2disp]));
    end
end

function loadparam(~,~) %charger parametres sauvegarde en .slb
     [prevparam,path2param]=uigetfile(fullfile(path2keep,'*.slb'),'Select Simulation to Open','MultiSelect', 'on'); %ouverture boite de dialogue dans repertoire courant (.mat selectionnes)
     
     if ischar(prevparam) %1!fichier selectione
         prevparam={prevparam};
     end
     if not(isnumeric(prevparam)) %no cancel;

         prevdata=load(fullfile(path2param,prevparam{end}),'-mat'); %chargement chargement des donnees (prevdata=structure)
         loadanddisp(prevdata); %affichage du dernier
         for i=1:numel(prevparam)
                add2list(prevparam{i},path2param);
         end
         set(hsavesimul,'enable','off'); 
         %set(hlist,'value',find(ismember(listfile,prevparam{i})));
         path2keep=path2param;
         
         sep=filesep();% / ou \ selon systeme exploitation
         if strcmp(sep,'\') %windows
             path2disp=strrep(path2param,sep,[sep,sep]);
         else %linux
             path2disp=path2param;
         end
         set(hfreq,'TooltipString',sprintf(['Saved simulation file in\n',path2disp]));
     end
end

function runsimulcllbck(~,~)
   runsimul(hinit) 
end

function normradiocllbck(~,~)
    %si une selection dans liste
    rangselected=get(hlist,'value');
    realtimestatus=get(hrealtime,'value');
    
     switch get(get(hnormpanel,'SelectedObject'),'Tag')
            case 'intensity'
                set([hscaling hscalingval],'enable','off');
             case 'minmax'
                set([hscaling hscalingval],'enable','on');
     end
     set(hscalingval,'String',num2str(1,'%3.2f'),'backgroundcolor','w'); 

    if ishandle(hspecexp)
         specexp=mimilrescale(Bexp,spec,1);
         set(hspecexp,'ydata',specexp)
    end
    
    runsimul(hinit)

    cllbckfs %full scale
    
    if ~isempty(rangselected)
        set(hlist,'value',rangselected)
    end
    if realtimestatus==1
        chkrealtime
    end
end

function runsimul(hobject)
   
     componentnumberincluded=sum([componentdata.include])-1; %nb de composante a inclure dans simul (componentdata(1) = initialisation)
    if componentnumberincluded>=1
        runsim=true;
        numcomp=numel(componenth);
        
        Exp=Expgeneration(); %Expgeneration avant de supprimer simul pour mise en memoire de la frequence
        if ~isnan(Exp.mwFreq) % si cancel "set frequency" (freq=NaN) pas de calcul!
            if ishandle(hplotsimall)
                delete(hplotsimall);
                prevsim=1; %il y avait une simul
            else
                prevsim=0; %il n'y avait pas de simul
            end
            for k=2:numcomp
                if ishandle(componenth(k).hplot)
                        delete(componenth(k).hplot); %suppression des  plot precedents
                end
            end
            %%%%% simul  %%%%%%
           % Exp=Expgeneration()
            specsimul=zeros(componentnumberincluded+1,1024); %par defaut 1024 points dans simul easyspin (specsimul(1,:)=somme )
            i2beincluded=find([componentdata.include]); % pas tenir compte du 1er element de ce tableau = 1 =>componentdata d'initialisation

            if ishandle(hobject)% runsimul appele depuis callback (component forcement included) ie real time! hobject=hinit si appel depuis bouton "run simul"
                hfigtest=[get(hobject,'parent')  get(get(hobject,'parent'),'parent')]; %handle des 1er et 2e parents de l'objet considere
                %hfigttest(2)=get(get(hobject,'parent'),'parent') %handle du 2e parent de l'objet considere
                index= ismember(hfigtest,[componenth.hfig]);
                place=find([componenth.hfig]==hfigtest(index)); %indice considere dans la structure des handles componenth
                for k=2:numel(i2beincluded)
                    specsimul(k,:)=componentdata(i2beincluded(k)).specsimul;%recuperation des simul de composantes prealables
                end
                specsimul(i2beincluded==place,:)=easyspinfunc(Sys{place},Exp); %simul de la composante selectionnee

            else %simul globale (pas real time)
                [Bsimul,specsimul(2,:)]=easyspinfunc(Sys{i2beincluded(2)},Exp); %simul de la premiere composante selectionnee
                if componentnumberincluded>=2 %simul des composantes selectionnees suivantes
                for k=3:componentnumberincluded+1
                  specsimul(k,:)=easyspinfunc(Sys{i2beincluded(k)},Exp); %simul avec composantes selectionnees
                end
                end
            end

            specsimul(1,:)=sum(specsimul(2:componentnumberincluded+1,:),1);
            specsimul_=specsimul;


            [specsimul_(1,:),scalefact]=mimilrescale(Bsimul,specsimul(1,:),str2double(get(hscalingval,'string'))); %recalage de la somme
            %specsimul_(2:componentnumberincluded+1,:)=scalefact*specsimul(k,:);
            for k=2:componentnumberincluded+1 %recalage des composantes
               specsimul_(k,:)=scalefact*specsimul(k,:);%+delta;
            end

            hplotsimall=plot(hspecaxes,Bsimul,specsimul_(1,:),'m','linewidth',2);hold(hspecaxes,'on');
            set(hplotsimall, 'ButtonDownFcn',@MouseleftclicksimCllbck);
            dispspecsimul=specsimul_(1,:); %spectre total affiche
            dispsimulfreq=Exp.mwFreq;
            for k=2:componentnumberincluded+1
                if componentdata(i2beincluded(k)).status==1
                    visibility='on';
                else
                    visibility='off';
                end
                componenth(i2beincluded(k)).hplot=plot(hspecaxes,Bsimul,specsimul_(k,:),'color',componentdata(i2beincluded(k)).color,'visible',visibility);
                componentdata(i2beincluded(k)).specsimul=specsimul(k,:);
            end   
             setlegend(); %remplace la legende existante
            if ishandle(hspecexp)
                uistack(hspecexp,'top'); %spectre exp au 1er plan
                dispfitindicator(); %affiche indicateur de fit
            else
                 set(hspecaxes,'Ytick',NaN,'XTickMode','auto');
                 xlabel(hspecaxes,'Magnetic Field [mT]');
                 if prevsim==0
                     if ~isnan(max(dispspecsimul))
                    fullscale(Bsimul,dispspecsimul);
                     end
                 end
            end

            set(hsavesimul,'enable','on'); %sauver param simul = possible
            set(hlist,'value',[]); %pas de selection dans la listbox
            set(hfreq,'TooltipString','');
           %mise en tampon de la simul qui vient d'etre calculee
            Sys2buffer=cell(1,numcomp);
            for k=2:numcomp
                Sys2buffer{k-1}=Sys{k};
            end;
            bufferdata=bufferdatainit; %reinitialistaion du buffer
            bufferdata.Syssimul=Sys2buffer;
            bufferdata.datasimul=componentdata(2:end);
            bufferdata.Exp=Exp;
            [bufferdata.status]=deal(0); %[]:considere tous les champs status comme un vecteur
            %[bufferdata.include]=deal(1); %deal: distribution sur tous les elements du vecteur

    %         dispsimulfreq=Exp.mwFreq;
            set(hcurrentsimul,'enable','off'); %buffer enable off
            set(hsuprsimul,'enable','on');
        end
    end
%toc
end

function runsimul2(hobject) %run simul si modification des include en real time
     place=find([componenth.hchk]==hobject); %indice considere dans la structure des handles componenth
     componentnumberincluded=sum([componentdata.include])-1; %nb de composante a inclure dans simul (componentdata(1) = initialisation)
     numcomp=numel(componenth);
     if ishandle(hplotsimall)
        delete(hplotsimall);
        hplotsimall=hinit;
        prevsim=1; %il y avait une simul
     else
        prevsim=0; %il n'y avait pas de simul
     end
     for k=2:numcomp
        if ishandle(componenth(k).hplot)
            delete(componenth(k).hplot); %suppression des  plot precedents
            componenth(k).hplot=hinit;
        end
     end
     %componentdata(5)
     
     if componentnumberincluded>=1
        %%%%% nouvelle simul  %%%%%%
        specsimul=zeros(componentnumberincluded+1,1024); %par defaut 1024 points dans simul easyspin (specsimul(1,:)=somme )
        i2beincluded=find([componentdata.include]); % pas tenir compte du 1er element de ce tableau = 1 =>componentdata d'initialisation
        for k=2:numel(i2beincluded)
            if k==place
                specsimul(k,:)=easyspinfunc(Sys{i2beincluded(k)},Exp);
            else
                specsimul(k,:)=componentdata(i2beincluded(k)).specsimul;%recuperation des simul de composantes inclues
            end
        end
        
        
        specsimul(1,:)=sum(specsimul(2:componentnumberincluded+1,:),1);
        specsimul_=specsimul;
        [specsimul_(1,:),scalefact]=mimilrescale(Bsimul,specsimul(1,:),str2double(get(hscalingval,'string'))); %recalage de la somme
        %specsimul_(2:componentnumberincluded+1,:)=scalefact*specsimul(k,:);
        for k=2:componentnumberincluded+1 %recalage des composantes
           specsimul_(k,:)=scalefact*specsimul(k,:);%+delta;
        end
        
        hplotsimall=plot(hspecaxes,Bsimul,specsimul_(1,:),'m','linewidth',2);hold(hspecaxes,'on');
        set(hplotsimall, 'ButtonDownFcn',@MouseleftclicksimCllbck);
        dispspecsimul=specsimul_(1,:); %spectre total affiche
        dispsimulfreq=Exp.mwFreq;
        for k=2:componentnumberincluded+1
            if componentdata(i2beincluded(k)).status==1
                visibility='on';
            else
                visibility='off';
            end
            componenth(i2beincluded(k)).hplot=plot(hspecaxes,Bsimul,specsimul_(k,:),'color',componentdata(i2beincluded(k)).color,'visible',visibility);
            componentdata(i2beincluded(k)).specsimul=specsimul(k,:);
        end   
         setlegend(); %remplace la legende existante
        if ishandle(hspecexp)
            uistack(hspecexp,'top'); %spectre exp au 1er plan
            dispfitindicator(); %affiche indicateur de fit
        else
             set(hspecaxes,'Ytick',NaN,'XTickMode','auto');
             xlabel(hspecaxes,'Magnetic Field [mT]');
             if prevsim==0
                fullscale(Bsimul,dispspecsimul);
             end
        end

        set(hsavesimul,'enable','on'); %sauver param simul = possible
        set(hlist,'value',[]); %pas de selection dans la listbox
        set(hfreq,'TooltipString','');
       %mise en tampon de la simul qui vient d'etre calculee
        Sys2buffer=cell(1,numcomp);
        for k=2:numcomp
            Sys2buffer{k-1}=Sys{k};
        end;
        bufferdata=bufferdatainit; %reinitialistaion du buffer
        bufferdata.Syssimul=Sys2buffer;
        bufferdata.datasimul=componentdata(2:end);
        bufferdata.Exp=Exp;
        [bufferdata.status]=deal(0); %[]:considere tous les champs status comme un vecteur
        %[bufferdata.include]=deal(1); %deal: distribution sur tous les elements du vecteur
        
%         dispsimulfreq=Exp.mwFreq;
        set(hcurrentsimul,'enable','off'); %buffer enable off
        set(hsuprsimul,'enable','on');
     end
end

function func4easyspin(hobj,~)
    if ishandle(hplotsimall)
        delete(hplotsimall)
        hplotsimall=hinit;
        set(hfreq,'string','');
        set(hfitindicator,'visible','off'); 
        dispsimulfreq=NaN;
        set(hsuprsimul,'enable','off');
            if ~ishandle(hspecexp)
                set(hspecaxes,'xlim',[0 1],'ylim',[0 1],'Xtick',NaN); %reinitialisation si pas de simul affichee
            end
    end
    for k=2:numel(componenth)
        if ishandle(componenth(k).hplot)
            delete(componenth(k).hplot)
            componenth(k).hplot=hinit;
            set(componenth(k).hhide,'value',1);
            set(componenth(k).hvisible,'value',0);
            componentdata(k).status=0;
        end
    end
%     if isempty(get(hspecaxes,'children'))%~ishandle(hspecexp)
%                 set(hspecaxes,'xlim',[0 1],'ylim',[0 1],'Xtick',NaN); %reinitialisation si pas de simul affichee
%     end
    set(hlist,'value',[]);
    set(hfreq,'TooltipString','');
    setlegend()
    
    statuslist=get(hobj,'string');
    statusval=get(hobj,'value');
    status=statuslist{statusval};
    switch status
        case 'Slow Motion'
            easyspinfunc=@chili;
            [componentdata.type]=deal(status);
            timeenable='on';
            lwmax=0.3;
            minsteplw=0.01/lwmax; %facteur d'increment min 
            maxsteplw=0.05/lwmax; %facteur d'increment max

        case 'Frozen Solution'
            easyspinfunc=@pepper;
            [componentdata.type]=deal(status);
            timeenable='off';
            lwmax=2;
            minsteplw=0.05/lwmax; %facteur d'increment min 
            maxsteplw=0.2/lwmax; %facteur d'increment max
    end
    for k=2:numel(componenth)
        hpaneltime=get(componenth(k).hedittime,'parent');
        htimecontrol=get(hpaneltime,'children');
        set(htimecontrol,'enable',timeenable);
        if strcmp(timeenable,'off')
            set(componenth(k).hedittime,'string','');
        else
        	set(componenth(k).hedittime,'string',num2str(componentdata(k).tcorrval,'%3.2e'));
        end
        set(componenth(k).hslidlorentzian,'Min',lwmin,'Max',lwmax,'SliderStep',[minsteplw maxsteplw]);
        set(componenth(k).hslidgaussian,'Min',lwmin,'Max',lwmax,'SliderStep',[minsteplw maxsteplw]);
    end
        
end

function savesimul(~,~)
     [simf,path2simf]=uiputfile(fullfile(path2keep,'*.slb')); %ouverture boite de dialogue dans repertoire courant (.mat selectionnes)
     if simf~=0
         %[componentdata.include]
         i2beincluded=find([componentdata.include]); % pas tenir compte du 1er element de ce tableau = 1 =>componentdata d'initialisation
        datasimul=componentdata(i2beincluded(2:end));
        [datasimul.status]=deal(0); %[]:considere tous les champs status comme un vecteur
        [datasimul.include]=deal(1); %deal: distribution sur tous les elements du vecteur
        
        %Syssimul=Sys{i2beincluded(2:end)} %<=> a Syssimul={Sys{...}}
        for k=2:numel(i2beincluded) %pas reussi a prendre sous tableau (struct, cell, ...)
            Syssimul{k-1}=Sys{i2beincluded(k)};
        end
        
        if strcmp(timeenable,'off') %frozen solution
            for k=1:numel(datasimul)
                datasimul(k).tcorrval=componentdata(1).tcorrval;
                Syssimul{k}.logtcorr=log10(componentdata(1).tcorrval);
            end
        end
       %Syssimul
        save([path2simf,simf],'Syssimul','datasimul','Exp');%
         deltaB=str2double(get(hdeltaBval,'string'));
%          if ishandle(hspecexp) && deltaB~=0 %enregistrement du deltaB s'il existe
%              rang2save=get(hlistexp,'value');
%             expdeltaBf=[listfileexp{rang2save}(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
%             save(fullfile(listpathexp{rang2save},expdeltaBf),'deltaB');
%          end
         set(hsavesimul,'enable','off');
         bufferdata=bufferdatainit; %reinitialistaion du buffer
         set(hcurrentsimul,'enable','off');
         set(hlist,'enable','on');
         set(hsuprfromlist,'enable','on');
         set(hexpfromlist,'enable','on');
         
         
         
         add2list(simf,path2simf);
         path2keep=path2simf;
     end
end

function currentsimul(~,~)
  if ~isequal(bufferdata,bufferdatainit)  
    if ishandle(hsimlabelcompare)
        delete(hsimlabelcompare)
        hsimlabelcompare=hinit;
    end
    if ishandle(hlegend)
        delete(hlegend)
        hlegend=hinit;
    end
    if ishandle(hprevsimplot)
        delete(hprevsimplot);
        hprevsimplot=hinit;
    end
    if ishandle(handlesenab4comp)
        set(handlesenab4comp,'enable','on') % tous les handles mis en 'enable' off en mode comparaison remis dans leur etat initial
    end
    if ishandle(hspecexp)
        uistack(hspecexp,'top'); %spectre exp au 1er plan
        set(hspecexp,'color','k');
    end
    set(hfs,'enable','on');
    handlesenab4comp=[]; %reinitialisation
    
    if get(hrealtime,'value') %en mode real time toutes les composantes sont affichees donc include=1
        sizebuffer=size(bufferdata.datasimul); %nb composante dans buffer
        for k=1:sizebuffer(2)
            bufferdata.datasimul(1,k).include=1;
            set(componenth(k+1).hvisible,'enable','on');
            set(componenth(k+1).hhide,'enable','on');
        end
    end
    
    loadanddisp(bufferdata);
    set(hsavesimul,'enable','on'); %sauver param simul
    set(hlist,'value',[]); %pas de selection dans la listbox
    set(hfreq,'TooltipString','');
    set(hcurrentsimul,'enable','off'); %buffer enable off
  end 
end

function reloadexp(~,~)
    
    rang2load=get(hlistexp,'value');
%if ~isempty(rang2load) %si clic 2 fois sur meme exp
%     if numel(rang2load)>1
%        rang2loadeff=rang2load(1);
%        set(hlistexp,'value',rang2loadeff);
%     else
%         rang2loadeff=rang2load;
%     end
    if ishandle(hprevsimplot)
       delete(hprevsimplot);
       hprevsimplot=hinit;
    end
    if ishandle(hspecexp)
       delete(hspecexp);
       hspecexp=hinit;
    end
if ~isempty(rang2load) %si clic 2 fois sur meme exp
    if numel(rang2load)==1 %si 1! simul sauvee a charger 
%     loadexp(listfileexp{rang2loadeff},listpathexp{rang2loadeff});
        loadexp(listfileexp{rang2load},listpathexp{rang2load});
        expspecf=listfileexp{rang2load};
        set(hspecaxes,'XDir','normal');
        set(hfitindicator,'visible','off');
        if ishandle(hplotsimall)
            dispfitindicator;
        end
        if ishandle(handlesenab4comp)
            set(handlesenab4comp,'enable','on') % tous les handles mis en 'enable' off en mode comparaison remis dans leur etat initial
        end
        handlesenab4comp=[]; %reinitialisation

        
    else %si plusieurs exp a comparer
             if numel(rang2load)>=2 
                 set(hfreq,'string','');
                 set(hexpname,'string','');
                if isempty(handlesenab4comp)
                 handlesenab4comp=findobj(hpanelmain,'-property','enable','-and','enable','on'); %tous les handles du panel hpanelmain avec propriete 'enable' on 
                 handlesenab4comp(handlesenab4comp==hlistexp)=[];%supprimer le handle de la liste des handles a rendre enable off
                 handlesenab4comp=[handlesenab4comp;hnormI;hnormminmax;hscaling;hscalingval;hfs;hsavefig;hsuprexp;hsetB]; %choix de normalisation desactive
                 set(handlesenab4comp,'enable','off') % tous les handles 'enable' off => pas d'action possible en mode comparaison
                end
             end
             oldhfig=[componenth.hfig];
             if ~isempty(oldhfig) %si fenetres de composantes affichees, les effacer
                 for k=2:numel(oldhfig)
                closeSimLabelX(oldhfig(k));
                 end
             end

             nbexp2compare=numel(rang2load);
             for k=1:nbexp2compare
                %%% chargement des donnees
                path2exp=listpathexp{rang2load(k)};
                filename=listfileexp{rang2load(k)};
                [B,y,param]=eprload(fullfile(path2exp,filename)); %chargement du spectre exp
                if isfield(param,'MWFQ')
                     freq=param.MWFQ*1e-9; %frequence exp en GHz from ELEXSYS
                elseif isfield(param,'MF')
                     freq=param.MF; %en GHz from ESP
                else
                     freq=NaN;
                end
                expdeltaBf=[filename(1:end-3),'mat']; %fichier contenant le deltaB s'il existe
                if exist([path2exp,expdeltaBf], 'file')
                    load([path2exp,expdeltaBf]); %definition de deltaB
                else
                    deltaB=0;
                end
                B=B/10+deltaB; %en mT
                g(k,:)=planck*freq*1e9/bmagn./B*1e3;
                
                y_(k,:)=mimilrescale(B,y,1);
                
                if k>size(kolor,1) %choix de la couleur
                    kstr=num2str(k);
                    kolornumber=str2double(kstr(end));
                else
                    kolornumber=k;
                end;
                hprevsimplot(k)=plot(hspecaxes,g(k,:),y_(k,:),'color',kolor(kolornumber,:));
                hold(hspecaxes,'on');

             end

             set(hspecaxes,'Ytick',NaN,'XTickMode','auto','XDir','reverse',...
                 'xlim',[min(min(g)) max(max(g))],'ylim',1.05*[min(min(y_)) max(max(y_))]);
             xlabel(hspecaxes,'g value');

             setlegend3(rang2load);

    end
    set(hlistexp,'value',rang2load);%laisse la selection apparente
end
end
    
function reload(~,~) 
    reloading=true;
        if ishandle(hsimlabelcompare)
            closefigcompare()
        end
         rang2load=get(hlist,'value');
         set(hfitindicator,'visible','off');
          if ishandle(hprevsimplot)
             delete(hprevsimplot);
             hprevsimplot=hinit;
          end
          
  %   if ~isempty(rang2load) %si clic 2 fois sur meme sim  
         if numel(rang2load)==1 %si 1! simul sauvee a charger 

             %set(hfs,'enable','on');
             if ishandle(hspecexp)
                uistack(hspecexp,'top'); %spectre exp au 1er plan
                set(hspecexp,'color','k');
                %fullscale(Bexp,specexp);
             end
            prevdata=load(fullfile(listpath{rang2load},listfile{rang2load}),'-mat'); %chargement chargement des donnees (prevdata=structure)
            
            if ~isempty(handlesenab4comp) %ishandle
                set(handlesenab4comp,'enable','on') % tous les handles mis en 'enable' off en mode comparaison remis dans leur etat initial
            end
            handlesenab4comp=[]; %reinitialisation
            loadanddisp(prevdata);
            
            sep=filesep();% / ou \ selon systeme exploitation
            if strcmp(sep,'\') %windows
                path2disp=strrep(listpath{rang2load},sep,[sep,sep]);
            else %linux
                path2disp=listpath{rang2load};
            end
            set(hfreq,'TooltipString',sprintf(['Saved simulation file in\n',path2disp]));
            
            
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %si plusieurs simul sauvees a comparer
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         elseif ~isempty(rang2load) %si clic 2 fois sur meme sim  
                         
             %%%%%% table %%%%%
             hsimlabelcompare=figure();
             set(hsimlabelcompare,'Units','pixels','outerposition',possimlabelcompare,...
                 'Name','SimLabel_compare sim.','Menubar', 'none', 'Toolbar', 'none',...
                 'NumberTitle','off','color',get(0,'DefaultUicontrolBackgroundColor'),...
                 'CloseRequestFcn',@closefigcompare);
             htablecompare=uitable(hsimlabelcompare,'Units','normalized','Position',[0.01 0.01 0.98 0.98]);
             
             %%%%%% plot %%%%%
             set(hfreq,'string','');
             %set(hfs,'enable','off');
             if numel(rang2load)>=2 
                if isempty(handlesenab4comp)
                 handlesenab4comp=findobj(hpanelmain,'-property','enable','-and','enable','on'); %tous les handles du panel hpanelmain avec propriete 'enable' on 
                 handlesenab4comp(handlesenab4comp==hlist)=[];%supprimer le handle de la liste des handles a rendre enable off
                 set(handlesenab4comp,'enable','off') % tous les handles 'enable' off => pas d'action possible en mode comparaison
                end
             end
             %set(hfs,'enable','off');
             %sortie du mode real time
             if get(hrealtime,'Value')==1
                 set(hrealtime,'Value',0);
                 chkrealtime();
             end
    
             
             oldhfig=[componenth.hfig];
             if ~isempty(oldhfig) %si fenetres de composantes affichees, les effacer
                 for k=2:numel(oldhfig)
                closeSimLabelX(oldhfig(k));
                 end
             end

             nbsim2compare=numel(rang2load);
             datasimul2disp=cell(nbsim2compare,1);%init tableau des datasimul a afficher dans table de comparaison
             nbcomp2compare=ones(nbsim2compare,1);%init du nb de composantes/simul

             for k=1:nbsim2compare
                %%% chargement des donnees
                prevdata=load(fullfile(listpath{rang2load(k)},listfile{rang2load(k)}),'-mat'); %chargement d'une structure sinon conflit de noms
                [B,y]=prevsimul(prevdata);
                datasimul2disp{k}=prevdata.datasimul;
                nbcomp2compare(k)=numel(datasimul2disp{k});
               
                if k>size(kolor,1) %choix de la couleur
                    kstr=num2str(k);
                    kolornumber=str2double(kstr(end));
                else
                    kolornumber=k;
                end;
                
                hprevsimplot(k)=plot(hspecaxes,B,y,'color',kolor(kolornumber,:));
                hold(hspecaxes,'on');
             end
            set(hspecaxes,'Ytick',NaN,'XTickMode','auto');
            xlabel(hspecaxes,'Magnetic Field [mT]');
            
            if ishandle(hspecexp)
                %uistack(hspecexp,'top'); %spectre exp au 1er plan
                set(hspecexp,'color',[0.8 0.8 0.8]);
                fullscale(Bexp,specexp);
            else
                fullscale(B,y);
            end
            setlegend2(rang2load);
            
            %%% table %%%
            nbcomp2disp=max(nbcomp2compare);
            rownamelistbase={'Weight (%)','t_corr (s)','Gaussian (mT)','Lorentzian (mT)','g(1)','g(2)','g(3)','g_iso','I_1',...
                'A_1(1) (mT)','A_1(2) (mT)','A_1(3) (mT)','A_1_iso (mT)','I_2','A_2(1) (mT)','A_2(2) (mT)','A_2(3) (mT)','A_2_iso (mT)'};

            nbparambase=numel(rownamelistbase)+1; %nb de param de base
            rownamelist2disp={}; %nom des lignes
            for k=1:nbcomp2disp
                rownamelist2disp=[rownamelist2disp,['Component ',num2str(k)],rownamelistbase];
            end
            colonneformat={}; %format des colonnes
            colonnelargeur={80}; 
            for k=1:nbsim2compare
                colonneformat=[colonneformat,'char'];
                colonnelargeur=[colonnelargeur,'auto'];
            end            
            simulname2disp=[{''},{listfile{rang2load}}]; %pas d'erreur
            alldata2disp=cell(nbparambase*nbcomp2disp,nbsim2compare+1); %init data de la table 
            for k=1:nbparambase*nbcomp2disp
                alldata2disp{k,1}=rownamelist2disp{k};
            end
            for k=1:nbsim2compare
                for m=1:nbcomp2compare(k)
                    
                    alldata2disp{1+(m-1)*nbparambase,k+1}=datasimul2disp{k}(m).name;
                    if nbcomp2compare(k)>1
                        alldata2disp{2+(m-1)*nbparambase,k+1}=num2str(100*datasimul2disp{k}(m).weightval/sum([datasimul2disp{k}(:).weightval]),'%3.1f');
                    end
                    if strcmp(datasimul2disp{k}(m).type,'Slow Motion')
                        alldata2disp{3+(m-1)*nbparambase,k+1}=num2str(datasimul2disp{k}(m).tcorrval,'%3.2e');
                    end
                    alldata2disp{4+(m-1)*nbparambase,k+1}=num2str(datasimul2disp{k}(m).gaussianval,'%3.2f');
                    alldata2disp{5+(m-1)*nbparambase,k+1}=num2str(datasimul2disp{k}(m).lorentzianval,'%3.2f');
                    
                    g2disp=datasimul2disp{k}(m).gval;
                    alldata2disp{6+(m-1)*nbparambase,k+1}=num2str(g2disp(1),'%6.5f');
                    alldata2disp{7+(m-1)*nbparambase,k+1}=num2str(g2disp(2),'%6.5f');
                    alldata2disp{8+(m-1)*nbparambase,k+1}=num2str(g2disp(3),'%6.5f');
                    alldata2disp{9+(m-1)*nbparambase,k+1}=num2str(mean(g2disp),'%6.5f');
                    
                    A2disp=datasimul2disp{k}(m).Aval;
                    Istr2disp=datasimul2disp{k}(m).Istr;
                    if ~isnan(A2disp(1,:))
                        if ischar(Istr2disp{1})
                            alldata2disp{10+(m-1)*nbparambase,k+1}=Istr2disp{1};
                        else %iscell
                            alldata2disp{10+(m-1)*nbparambase,k+1}=Istr2disp{1}{1};
                        end
                        alldata2disp{11+(m-1)*nbparambase,k+1}=num2str(A2disp(1,1),'%3.2f');
                        alldata2disp{12+(m-1)*nbparambase,k+1}=num2str(A2disp(1,2),'%3.2f');
                        alldata2disp{13+(m-1)*nbparambase,k+1}=num2str(A2disp(1,3),'%3.2f');
                        alldata2disp{14+(m-1)*nbparambase,k+1}=num2str(mean(A2disp(1,:)),'%3.2f');
                    end
                    if ~isnan(A2disp(2,:))
                        if ischar(Istr2disp{2})
                            alldata2disp{15+(m-1)*nbparambase,k+1}=Istr2disp{2};
                        else %iscell
                            alldata2disp{15+(m-1)*nbparambase,k+1}=Istr2disp{2}{1};
                        end
                        alldata2disp{16+(m-1)*nbparambase,k+1}=num2str(A2disp(2,1),'%3.2f');
                        alldata2disp{17+(m-1)*nbparambase,k+1}=num2str(A2disp(2,2),'%3.2f');
                        alldata2disp{18+(m-1)*nbparambase,k+1}=num2str(A2disp(2,3),'%3.2f');
                        alldata2disp{19+(m-1)*nbparambase,k+1}=num2str(mean(A2disp(2,:)),'%3.2f');
                    end
                end
                
            end

            set(htablecompare,'data',alldata2disp,'columnname',simulname2disp,'rowname',[],...
                'columnformat',colonneformat,'columnwidth',colonnelargeur);
         end
         
         set(hlist,'value',rang2load);%laisse la selection apparente
         set(hsavesimul,'enable','off'); 
         if runsim %=> 1 simul a ete lancee
            set(hcurrentsimul,'enable','on'); 
         end
   %  end
         reloading=false;
end

function closefigcompare(~,~)
       possimlabelcompare=get(hsimlabelcompare,'outerposition');
       delete(hsimlabelcompare)
       hsimlabelcompare=hinit;
end
        
function suprfromlist(~,~)
    rang2del=get(hlist,'value');
  if ~isempty(rang2del) && numel(rang2del)==1
    listfile{rang2del}=[];
    listpath{rang2del}=[];
    listfile(cellfun(@isempty,listfile)) = []; %enleve les elements vide de la liste de fichiers
    listpath(cellfun(@isempty,listpath)) = []; %enleve les elements vide de la liste de chemins
    if ~isempty(listfile)
        clear list2disp
        for i=1:numel(listfile)
            list2disp{i}=[num2str(i),': ',listfile{i}];
        end    
        if rang2del>1 %trouver le nouvel elt selectione de la liste
            rang=rang2del-1;
        else
            rang=1;
        end
        %set(hlist,'string',list2disp,'value',rang);
        prevdata=load(fullfile(listpath{rang},listfile{rang}),'-mat'); %chargement chargement des donnees (prevdata=structure)
        loadanddisp(prevdata);
        set(hsavesimul,'enable','off'); 
        
        set(hlist,'string',list2disp,'value',rang);
    else
        %buttonrun=get(hrunsimul,'enable'); %mise en memoire de l'etat du bouton  'run'
        set(hlist,'string',[])
        set(hfreq,'TooltipString','');
                 %%%% supression des donnees %%%
         hfig2del=[componenth.hfig]; %handles des figures SimLabel_X a supprimer (1er element de componenth: initialisation)
         if numel(hfig2del)>=2 %s'il y a des fenetres a fermer
             for k=hfig2del(end:-1:2)
                closeSimLabelX(k);
             end;
         end
%          set(hdeltaBval,'string',num2str(0));
%          set(hdeltaBslid,'value',0);
         
         
         set(hlist,'enable','off');
         set(hsuprfromlist,'enable','off');
         set(hexpfromlist,'enable','off');
         %set(hrunsimul,'enable',buttonrun); %bouton run dans meme etat qu'avant (si donnee dnas buffer)
    end 
  end
end

function suprfromlistexp(~,~)
    rang2del=get(hlistexp,'value');
  if ~isempty(rang2del) && numel(rang2del)==1
    listfileexp{rang2del}=[];
    listpathexp{rang2del}=[];
    listfileexp(cellfun(@isempty,listfileexp)) = []; %enleve les elements vide de la liste de fichiers
    listpathexp(cellfun(@isempty,listpathexp)) = []; %enleve les elements vide de la liste de chemins
    if ~isempty(listfileexp)
        clear list2dispexp
        for i=1:numel(listfileexp)
            list2dispexp{i}=[num2str(i),': ',listfileexp{i}];
        end    
        if rang2del>1 %trouver le nouvel elt selectione de la liste
            rang=rang2del-1;
        else
            rang=1;
        end
        loadexp(listfileexp{rang},listpathexp{rang});
        
        set(hlistexp,'string',list2dispexp,'value',rang);
    else
        %buttonrun=get(hrunsimul,'enable'); %mise en memoire de l'etat du bouton  'run'
        set(hlistexp,'string',[])
                 %%%% supression des donnees %%%
         suprexp();
         set(hdeltaBval,'string',num2str(0));
         set(hdeltaBslid,'value',0);
         
         
         set(hlistexp,'enable','off');
         set(hsuprfromlistexp,'enable','off');
         
    end 
  end
end


function expfromlist(~,~)
    
    rang2exp=get(hlist,'value'); %{fullfile(listpath{rang2exp},[listfile{rang2exp}(1:end-4),
  if numel(rang2exp)==1 %exportation possible si 1! simul selectionnee
      epsB=1e-13;
      [expf,path2expf]=uiputfile('*.txt','export',fullfile(listpath{rang2exp},listfile{rang2exp}(1:end-4))); %ouverture boite de dialogue dans repertoire courant (nom propose)
      if expf~=0 
             data2exp=load(fullfile(listpath{rang2exp},listfile{rang2exp}),'-mat'); 
             B2exp=get(hplotsimall,'xdata');%linspace(data2exp.Exp.Range(1),data2exp.Exp.Range(2),numel(spec2exp)); %champ magnetique a exporter
             nbcomp=numel(data2exp.datasimul);%nb de composantes
             for k=1:nbcomp
                speccomp2exp(:,k)=data2exp.datasimul(k).specsimul; %spectres des composantes a exporter
             end
             spectot2exp=sum(speccomp2exp,2);% somme des simul de composantes 
            [spectot2exp_,scalefact4exp]=mimilrescale(B2exp,spectot2exp,1);% somme des simul de composantes, recalee
            speccomp2exp_=speccomp2exp*scalefact4exp;
             %spectre
             mat2exp(:,1)=B2exp';
             currentcol=2;
             addspecexp=false; %marqueur de presence de spectre exp
             if ishandle(hspecexp)
                specexp2exp=mimilrescale(Bexp,spec,1);
                newBexp=Bsimul;
                specexp2exp=interp1(Bexp,specexp2exp,newBexp,'spline',0);
                mat2exp(:,2)=specexp2exp;
                currentcol=3;
                addspecexp=true;
             end
             fid=fopen(fullfile(path2expf,expf),'w');
             %1ere ligne
             fprintf(fid,'%13s\t','B [mT]');
             if addspecexp
                    fprintf(fid,'%13s\t','exp'); 
             end
             scalingfactor=str2double(get(hscalingval,'string'));
             mat2exp(:,currentcol)=scalingfactor*spectot2exp_;
             for k=1:nbcomp
                mat2exp(:,k+currentcol)=scalingfactor*speccomp2exp_(:,k);
             end
             
             if nbcomp>1                 
                 fprintf(fid,'%13s\t','sum');
                 nbcp=numel(componentdata); %nombre component +1
                 for k=2:nbcp
                     switch k
                         case nbcp
                             fprintf(fid,'%13s\n',componentdata(k).name);
                         otherwise
                             fprintf(fid,'%13s\t',componentdata(k).name);
                     end
                 end

                 %lignes suivantes
                 linenb=size(mat2exp,1);
                 colnb=size(mat2exp,2);
                 for k=1:linenb
                     for col=1:colnb-1
                         fprintf(fid,'%e\t',mat2exp(k,col));
                     end
                     if k~=linenb
                         fprintf(fid,'%e\n',mat2exp(k,col+1));
                     else
                         fprintf(fid,'%e',mat2exp(k,col+1));
                     end
                 end
             else
                 fprintf(fid,'%13s\n',componentdata(2).name);
                 %lignes suivantes
                 linenb=size(mat2exp,1);
                 colnb=size(mat2exp,2);
                 for k=1:linenb
                     for col=1:colnb-2
                         fprintf(fid,'%e\t',mat2exp(k,col));
                     end
                     if k~=linenb
                         fprintf(fid,'%e\n',mat2exp(k,col+1));
                     else
                         fprintf(fid,'%e',mat2exp(k,col+1));
                     end
                 end
             end
             fclose(fid);
             
             savepar(fullfile(path2expf,expf),rang2exp); %param de la simul dans fichier par
      end

 end
end

function suprexp(~,~)
    delete(hspecexp);
    set(hexpname,'visible','off');
    set(hfitindicator,'visible','off');
    hspecexp=hinit; %handle de spectre experimental 
    set(hsuprexp,'enable','off');
    set(hdeltaB1,'enable','off');
    set(hdeltaB2,'enable','off');
    set(hdeltaBval,'enable','off');
    set(hdeltaBslid,'enable','off');
    if ~ishandle(hplotsimall)
        set(hspecaxes,'xlim',[0 1],'ylim',[0 1],'Xtick',NaN); %reinitialisation si pas de simul affichee
    end
    Bexpinit=[]; %champ experimental brut
    Bexp=[]; %champ experimental decale
    specexp=[]; %spectre experimenatl normalise
    spec=[]; %spectre experimenatl brut
    expfreq=NaN; %frequence experimentale
    expspecf=[]; %nom fu fichier exp
    path2expspec=[];%chemin du fichier exp
    setlegend();
    set(hnormminmax,'value',1);
    normradiocllbck;
    set(hlistexp,'value',[]);
end

function suprsimul(~,~)
    delete(hplotsimall);
    hplotsimall=hinit;
    hplot2del=[componenth.hplot];
    for k=1:numel(hplot2del)
        if ishandle(hplot2del(k))
            delete(hplot2del(k))
        end
    end
    set(hfreq,'string','');
    set(hfitindicator,'visible','off');
    hplotsimall=hinit;  
    dispsimulfreq=NaN;
    set(hsuprsimul,'enable','off');
    if ~ishandle(hspecexp)
        set(hspecaxes,'xlim',[0 1],'ylim',[0 1],'Xtick',NaN); %reinitialisation si pas de simul affichee
    end
   h2close=[componenth.hfig];
    for k=2:numel(h2close)
        close(h2close(k))
    end
    set(hlist,'value',[]);
    set(hfreq,'TooltipString','');
    setlegend();
    set(hrealtime,'value',0);
    chkrealtime()
end

function cllbckfs(~,~) %full scale
    limitex=get(hspecaxes,'xlim');
    limitey=get(hspecaxes,'ylim');
    if ishandle(hspecexp)
        maxy=max(specexp);
        miny=min(specexp);
        h=maxy-miny;
        %[miny-0.08*h maxy+0.08*h]
        if limitex~=[Bexp(1) Bexp(end)] | limitey~=[miny-fsfactor*h maxy+fsfactor*h] %si limites courantes !=limites apres fullscale sur spectre exp
            fullscale(Bexp,specexp);
        elseif ishandle(hplotsimall)
            fullscale(Bsimul,dispspecsimul);
        end
    elseif ishandle(hplotsimall) && ~isequal(dispspecsimul,zeros(1,numel(dispspecsimul))) %= zeros() si pas de resonance sur plagede champ
        fullscale(Bsimul,dispspecsimul);
        %set(hrunsimul,'enable','off');
    end  
end

function cllbckexpandx(~,~) %x2 plage des x
    limitex=get(hspecaxes,'xlim');
    if limitex~=[0 1] %si limites courantes !=limites par defaut
        meanx=mean(limitex);
        swx=limitex(2)-limitex(1);
        set(hspecaxes,'xlim',[meanx-swx meanx+swx]); 
        set(hrunsimul,'enable','on');
        %set(hrealtime,'value',0);
    end    
end

function cllbcksetB(~,~) %imposer manuellement plage de B
    Blimcurr=get(hspecaxes,'xlim');
    if isequal(Blimcurr,[0 1])
        Blimcurr=defaultRangeB(9.8);
    end
    prompt = {'Enter B min (mT):','Enter B max (mT):'};
    dlg_title = 'SimLabel_setB';
    num_lines = 1;
    def = {num2str(Blimcurr(1)),num2str(Blimcurr(2))};
    newBlimcell=inputdlg(prompt,dlg_title,num_lines,def);
    newBlim=str2double(newBlimcell);
    if ~isnan(newBlim)
        set(hspecaxes,'xlim',newBlim);
    end
    
end

function cllbckexpandy(~,~) %x2 plage des y
    limitey=get(hspecaxes,'ylim');
    if limitey~=[0 1] %si limites courantes !=limites par defaut
        meany=mean(limitey);
        swy=limitey(2)-limitey(1);
        set(hspecaxes,'ylim',[meany-swy meany+swy]); 

    end    
end

function savefig(~,~)
 if ~isempty(get(hspecaxes,'children')) %si des plot sont affiches
  rang2exp=get(hlist,'value'); %{fullfile(listpath{rang2exp},[listfile{rang2exp}(1:end-4),
  if ~isempty(rang2exp) && numel(rang2exp)==1
    [figname,path2fig]=uiputfile({'*.bmp';'*.fig'},'export',fullfile(listpath{rang2exp},listfile{rang2exp}(1:end-4))); %ouverture boite de dialogue dans repertoire courant (nom propose)
  else
    [figname, path2fig] = uiputfile({'*.bmp';'*.fig'});
  end
    if figname~=0
        if ~isempty(rang2exp) && numel(rang2exp)==1
            savepar(fullfile(path2fig,figname),rang2exp); %param de la simul dans fichier par
            simulname=listfile{rang2exp};
        else
            uiwait(msgbox({'WARNING:   Simulation not saved'  ;['No ',figname(1:end-4),'.par will be saved.']},...
                 'SimLabel_WARNING','Warn','modal'));
            simulname=[];
        end    
        hplots2save=findobj(hSimLabelmain,'type','axes'); %liste des handles de plot a sauver (dans graphe=axes)
        pos2save=get(hSimLabelmain,'position');
        figure2save=figure(max(findobj('type','figure'))+1); %pour ne pas superposer des figures 
        set(figure2save,'Units','pixels','Name','SimLabel_archive','NumberTitle','off','visible','off',...
            'Position',pos2save.*[1 1 1 0.75],'Menubar', 'figure','Toolbar', 'figure');
        %hspecaxes=axes('parent',hSimLabelmain,'OuterPosition',[0 0.25 1 0.75],'Position',[0.05 0.30 0.9 0.65]
        %'Outerposition',[0.05 0.4 0.5 0.5],
        copyobj(hplots2save,figure2save);%graphe(=axes)+legend copier dans nouvelle figure

        %new title
        hnewaxes=findobj(figure2save,'type','axes');
        set(hnewaxes(2),'position',[0.05 0.067 0.9 0.87]);
        %set(hnewaxes(1),'position',[0.05 0.067 0.9 0.87]);
        %newtitle=['exp: ',expspecf(1:end-4),'  /  simul: ',strrep(simulname(1:end-4),'_','\_') ];
        if strcmp(get(hfitindicator,'visible'),'on')
                newtitle=['exp: ',expspecf(1:end-4),'  /  simul: ',simulname(1:end-4),'  /  ',get(hfitindicator,'string') ];
        else
                newtitle=['exp: ',expspecf(1:end-4),'  /  simul: ',simulname(1:end-4) ];
        end

        title(hnewaxes(2),newtitle,'interpreter','none'); %hnewaxes(1)=legend
        set(figure2save,'visible','on');
        %pause
        saveas(figure2save,fullfile(path2fig,figname));
        delete(figure2save);
        clear haxes2save hplots2save figure2save;
    end
 end
end

function opendoc(~,~)
        fullname=fullfile(path4doc,'SimLabel_documentation.pdf');
        if exist(fullname, 'file') %si .pdf present
            if ispc
           winopen(fullname); 
            elseif isunix
           system(['evince ',fullname]);
            end
        end
    if ishandle(hmt2mhz) %si figure conversion deja affichee
        figure(hmt2mhz)
    else
        openmhz2mt();%ouvrir figure avec conversion mT et MHz
   end
end

function openmhz2mt() %affiche figure avec conversion mT et MHz
     hmt2mhz=figure();   
     pos=get(hSimLabelmain,'position');
     set(hmt2mhz,'Units','pixels','position',[pos(1) pos(2) 200 420],...
                 'Name','SimLabel_conv','Menubar', 'none', 'Toolbar', 'none',...
                 'NumberTitle','off','resize','on',...
                 'color',get(0,'DefaultUicontrolBackgroundColor'));
                 %'CloseRequestFcn',@closefig2esfit);
    
    %%% 1
        AmT=3.25:0.2:4.85;
        AMHz=90:5:135;

        lw=2;%linewidth

        haxmt2mhz=subplot(1,2,2);
        plot(ones(numel(AmT),1),AmT,'.w');%faire apparaitre figure

        limitx=get(haxmt2mhz,'xlim');
        set(haxmt2mhz,'ylim',[3.05 5.2],'xlim',limitx,'xtick',NaN,'ytick',NaN,'position',[0.5 0.075 0.45 0.85]);
        annotation(hmt2mhz,'arrow',[0.73 0.73],[0.12 0.85],'linewidth',lw);

        %%% mT %%%
        for k=1:numel(AmT)
        line([0.8 1],AmT(k)*[1 1],'color','k','linewidth',lw)
        text(0.1,AmT(k),num2str(AmT(k)));
        end
        %%% MHz %%
        for k=1:numel(AMHz)
        line([1 1.2],mhz2mt(AMHz(k))*[1 1],'color','k','linewidth',lw)
        text(1.3,mhz2mt(AMHz(k)),num2str(AMHz(k)));
        end


        y=5.06;
        text(0.3,y,'mT','fontweight','bold');
        text(1.2,y,'MHz','fontweight','bold');

        %%% 2
        AmT=0.35:0.05:0.55;
        AMHz=10:1:15;

        haxmt2mhz=subplot(1,2,1);
        plot(ones(numel(AmT),1),AmT,'.w');%faire apparaitre figure

        limitx=get(haxmt2mhz,'xlim')-0.1;
        set(haxmt2mhz,'ylim',[0.33 0.6],'xlim',limitx,'xtick',NaN,'ytick',NaN,'position',[0.05 0.075 0.4 0.85]);
        annotation(hmt2mhz,'arrow',[0.275 0.275],[0.12 0.85],'linewidth',lw);

        %%% mT %%%
        for k=1:numel(AmT)
        line([0.8 1],AmT(k)*[1 1],'color','k','linewidth',lw)
        text(0,AmT(k),num2str(AmT(k),'%1.2f'));
        end
        %%% MHz %%
        for k=1:numel(AMHz)
        line([1 1.2],mhz2mt(AMHz(k))*[1 1],'color','k','linewidth',lw)
        text(1.3,mhz2mt(AMHz(k)),num2str(AMHz(k)));
        end


        y=0.582;%5.1;
        text(0.25,y,'mT','fontweight','bold');
        text(1.1,y,'MHz','fontweight','bold');

end


%% fenetre pour 1 composant
function addcomponent(~,~) %ouverture nouvelle fenetre avec parametres d'une composante
    hfig=opencomponentwin; % ouverture d'une nouvelle fenetre de composante SimLabel_X
    %numel(componentdata)

    %place=find([componenth.hfig]==hfig) %indice de la composante consideree dans la structure des handles componenth
        place=find([componenth.hfig]==hfig); %indice de la composante consideree dans la structure des handles componenth
        componentdata(place)=componentdata(1);
        Sys{place}=Sys{1};
        dispcomponent(place); % remplissage de la fenetre avec donnees de depart
        if ishandle(hplotsimall)
            set(componenth(place).hchk,'value',0);
            set(componenth(place).hhide,'enable','off');
            set(componenth(place).hvisible,'enable','off');
            componentdata(place).include=0;
            componentdata(place).status=0;
            set(hrealtime,'value',0);
            set(hrunsimul,'enable','on');
        end
%Sys
        dispweight();

end 

function hfig=opencomponentwin()   
    % ouverture d'une nouvelle fenetre de composante SimLabel_X :
    % hfig=handle de la figure, componentnumber: numero de composante
    %%% numero du nom de la fenetre: SimLabel_XX %%%
    fignumber=1; %numero de la  fenetres SimLabel_XX en train d'etre ouverte (1 par defaut)
    allfigname=get(findobj('type','figure'),'name'); %cellarray avec noms des figures ouvertes
    if ~isempty(allfigname)
        if ~ischar(allfigname) %Si 1! fenetre (SimLabel_main), fignumber=1
          allfigname=sort(allfigname);% +petit au + grand ('SimLabel_main' a la fin)
          for i=1:numel(allfigname)
              numSimLabel(i)=str2double(allfigname{i}(10:end));
          end
          numSimLabel(isnan(numSimLabel))=[]; %suprimer les NaN
          while  ~isempty(find(numSimLabel==fignumber,1))
              fignumber=fignumber+1;
          end
        end
    end
    
    %%%position de la figure
    if fignumber<=size(poscomponentfig,1)
        pos=poscomponentfig(fignumber,:);
    else
        posylocal=scrszpix(4)-scrszpix(4)/20-280-scrszpix(4)*0.1*(fignumber-1);
        if posylocal<0
            posylocal=min(poscomponentfig(:,2));
        end
        pos=[scrszpix(3)-scrszpix(3)/20-800 posylocal 800 280];
    end
    %%% creation figure SimLabel_X
    hcurrentcomp=figure();%floor(max(findobj('type','figure'))+1)); %pour ne pas superposer des figures
    %hcurrentcomp=handle de la figure dans cette function
    set(hcurrentcomp,'Units','pixels',...
        'position',pos,...
        'Name',['SimLabel_',num2str(fignumber)],'Menubar', 'none',...
        'Toolbar', 'none','NumberTitle','off','DoubleBuffer','on',...'resize','off',...
        'color',get(0,'DefaultUicontrolBackgroundColor'),'CloseRequestFcn',@closeSimLabelX); % handle=0 correspond a root (ie bureau?!)
   
    %%% boutons
%     if fignumber>10
%         fignumberstr=num2str(fignumber);
%         kolornumber=str2double(fignumberstr(end));
%     else
%         kolornumber=fignumber;
%     end;
    hname = uicontrol(...
        'Parent',hcurrentcomp,...
        'Style','edit',...
        'Units','normalized',...
        'FontUnits','pixels',...
        'FontWeight','bold',...
        'BackgroundColor','w',...
        'Callback',@cllbckname,...
        'FontSize',1.3*ftsz,...'ForegroundColor',kolor(kolornumber,:),...[1 0 1],...
        'HorizontalAlignment','left',...
        'Position',[0.02 0.77 0.2 0.1],...
        'TooltipString',sprintf('Name of the component\n(can be modified)'));%'String',['component ',num2str(fignumber)]);
    
    hchk = uicontrol(...
        'Parent',hcurrentcomp,...
        'Style','checkbox',...
        'Units','normalized',...
        'FontUnits','pixels',...
        'Callback',@cllbckchk,...
        'FontSize',ftsz,...
        'Position',[0.23 0.78 0.08 0.09],...
        'String','Include',...
        'TooltipString','Include in simulation',...
        'Value',1);
    
 %%%%%%%%%%%%
    hpanelradio=uibuttongroup(...
        'Parent',hcurrentcomp,...
        'BorderType','none',...'etchedin',
        'Title','',...
        'Position',[0.3 0.72 0.07 0.2],...
        'SelectedObject',[],...
        'SelectionChangeFcn',@visible_or_hide,...
        'OldSelectedObject',[]);
    
    hvisible = uicontrol(...
        'Parent',hpanelradio,...
        'Style','radiobutton',...
        'Units','normalized',...
        'Position',[0 0.7 1 0.3],...
        'String','Visible',...
        'FontUnits','pixels',...
        'FontSize',ftsz,...
        'TooltipString','Display the component spectrum');%,...
        %'Value',0);
   % 'Callback',@(hObject,eventdata)SimLabel_componentX_export('visible_Callback',hObject,eventdata,guidata(hObject)),...
    
    hhide = uicontrol(...
        'Parent',hpanelradio,...
        'Style','radiobutton',...
        'Units','normalized',...
        'Position',[0 0.1 1 0.3 ],...
        'String','Hidden',...
        'FontUnits','pixels',...
        'FontSize',ftsz,...
        'TooltipString','Hide the component spectrum');%,...
        %'Value',1);
    %        'Callback',@(hObject,eventdata)SimLabel_componentX_export('hide_Callback',hObject,eventdata,guidata(hObject)),...
 %%%  store in memory as default parameters %%%
    uicontrol(...
        'Parent',hcurrentcomp,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'Callback',@cllbckstorepar,...
        'FontSize',ftsz,...
        'Position',[0.02 0.90 0.07 0.09],...
        'String','To Next',...
        'TooltipString','Store parameters in memory for next new components',...
        'enable','on',...
        'Style','pushbutton');  
 %%%  weight   %%%   
      htextweight = uicontrol(...  % text weight=
        'Parent',hcurrentcomp,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'FontWeight','bold',...
        'HorizontalAlignment','center',...'BackgroundColor','w',...
        'FontSize',1.3*ftsz,...
        'Position',[0.12 0.615 0.08 0.08],...
        'String','weight =',...
        'TooltipString','Component absolute weight',...
        'visible','off',...
        'Style','text');
 
    heditweight = uicontrol(...
        'Parent',hcurrentcomp,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',@cllbckeditweight,...
        'FontSize',ftsz,...
        'Position',[0.2 0.62 0.05 0.08],...
        'TooltipString','Component absolute weight',...
        'visible','off',...
        'Style','edit');
    
     htextpercent = uicontrol(...  % text (XX%)
        'Parent',hcurrentcomp,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...'BackgroundColor','w',...
        'FontSize',1.3*ftsz,...
        'Position',[0.25 0.615 0.08 0.08],...
        'TooltipString','Relative proportion of this component',...
        'visible','off',...
        'Style','text');


 %%%% t_corr %%%%%%%
    hpaneltcorr = uipanel(...
        'Parent',hcurrentcomp,...
        'FontUnits','pixels',...
        'FontSize',1.3*ftsz,...
        'FontWeight','bold',...
        'Title','Correlation Time',...
        'Position',[0.38 0.70 0.28 0.25]);
    
    hedittime = uicontrol(...
        'Parent',hpaneltcorr,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',@cllbckedittime,...
        'FontSize',ftsz,...
        'Position',[0.05 0.35 0.27 0.49],...
        'TooltipString','Correlation time',...
        'Style','edit',...
        'enable',timeenable);

     uicontrol(...  % text seconds
        'Parent',hpaneltcorr,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...'BackgroundColor','w',...
        'FontSize',ftsz,...
        'Position',[0.34 0.39 0.05 0.35],...
        'String','s',...
        'Style','text',...
        'enable',timeenable);


     hslidtime = uicontrol(...
        'Parent',hpaneltcorr,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',@cllbckslidtime,...
        'Position',[0.42 0.39 0.52 0.35],...
        'Min',log10(tcorrmin),...
        'Max',log10(tcorrmax),...
        'Value',log10(tcorrmin),...
        'SliderStep',[minstep/abs(log10(tcorrmax)-log10(tcorrmin)) maxstep/abs(log10(tcorrmax)-log10(tcorrmin))],...
        'TooltipString','Correlation time',...
        'Style','slider',...
        'enable',timeenable);

%%%% lw  %%%%%%%
    hpanellw = uipanel(...
        'Parent',hcurrentcomp,...
        'FontUnits','pixels',...
        'FontSize',1.3*ftsz,...
        'FontWeight','bold',...
        'Title','Line Width',...
        'Position',[0.67 0.61 0.32 0.37]);
    
    uicontrol(...  % text lorentzian
        'Parent',hpanellw,...
        'Units','normalized',...
        'FontUnits','pixels',...'BackgroundColor','w',...
        'HorizontalAlignment','right',...
        'FontSize',ftsz,...
        'Position',[0.01 0.2 0.22 0.2],...
        'String','Lorentzian:',...
        'TooltipString','Lorentzian part of line width',...
        'Style','text');
   
    heditlorentzian = uicontrol(...
        'Parent',hpanellw,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',@cllbckeditlorentzian,...
        'FontSize',ftsz,...
        'Position',[0.24 0.15 0.14 0.3],...
        'TooltipString','Lorentzian part of line width',...
        'Style','edit');

     uicontrol(...  % text mT
        'Parent',hpanellw,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.38 0.2 0.08 0.2],...'BackgroundColor','w',...
        'String','mT',...
        'Style','text');

     hslidlorentzian = uicontrol(...
        'Parent',hpanellw,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',@cllbckslidlorentzian,...
        'Position',[0.48 0.2 0.48 0.22],...
        'Min',lwmin,...
        'Max',lwmax,...
        'SliderStep',[minsteplw maxsteplw],...
        'TooltipString','Lorentzian part of line width',...
        'Style','slider');
    
    uicontrol(...  % text gaussian
        'Parent',hpanellw,...
        'Units','normalized',...
        'FontUnits','pixels',... 'BackgroundColor','w',...
        'HorizontalAlignment','right',...
        'FontSize',ftsz,...
        'Position',[0.01 0.67 0.22 0.2],...
        'String','Gaussian:',...
        'TooltipString','Gaussian part of line width',...
        'Style','text');
   
    heditgaussian = uicontrol(...
        'Parent',hpanellw,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',@cllbckeditgaussian,...
        'FontSize',ftsz,...
        'Position',[0.24 0.63 0.14 0.3],...
        'TooltipString','Gaussian part of line width',...
        'Style','edit');

     uicontrol(...  % text mT
        'Parent',hpanellw,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.38 0.67 0.08 0.2],...'BackgroundColor','w',...
        'String','mT',...
        'Style','text');

     hslidgaussian = uicontrol(...
        'Parent',hpanellw,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',@cllbckslidgaussian,...
        'Position',[0.48 0.67 0.48 0.22],...
        'Min',lwmin,...
        'Max',lwmax,...
        'SliderStep',[minsteplw maxsteplw],...
        'TooltipString','Gaussian part of line width',...
        'Style','slider');
    
%%%% g  %%%%%%%
    hpanelg = uipanel(...
        'Parent',hcurrentcomp,...
        'FontUnits','pixels',...
        'FontSize',2*ftsz,...
        'FontWeight','bold',...
        'FontName','Times New Roman',...
        'Title','g',...
        'Position',[0.01 0.03 0.28 0.57]);
    
    haxialg = uicontrol(...
        'Parent',hpanelg,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'Callback',@cllbckaxialg,...
        'FontSize',ftsz,...
        'Position',[0.02 0.1 0.15 0.15],...
        'String','Axial',...
        'TooltipString','Axial g tensor',...
        'enable','on',...
        'Style','pushbutton'); 

    heditg1 = uicontrol(...
        'Parent',hpanelg,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditg,1},...
        'FontSize',ftsz,...
        'Position',[0.02 0.74 0.32 0.2],...
        'TooltipString','g_1',...
        'Style','edit');
    
     hmarkerg1 = uicontrol(...  
        'Parent',hpanelg,...
        'Units','normalized',...
        'Position',[0.02 0.74 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');

     hslidg1 = uicontrol(...
        'Parent',hpanelg,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidg,1},...
        'Position',[0.36 0.77 0.62 0.14],...
        'TooltipString','g_1',...
        'Min',gmin,...2.00000
        'Max',gmax,...2.01800,...
        'SliderStep',[minstepg maxstepg],...[1e-5/2 50e-5/2],...
        'Style','slider');    

     heditg2 = uicontrol(...
        'Parent',hpanelg,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditg,2},...
        'FontSize',ftsz,...
        'Position',[0.02 0.51 0.32 0.2],...
        'TooltipString','g_2',...
        'Style','edit');
    
      hmarkerg2 = uicontrol(...  
        'Parent',hpanelg,...
        'Units','normalized',...
        'Position',[0.02 0.51 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');

      hslidg2 = uicontrol(...
        'Parent',hpanelg,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidg,2},...
        'Position',[0.36 0.54 0.62 0.14],...
         'TooltipString','g_2',...
        'Min',gmin,...2.00000
        'Max',gmax,...2.01800,...
        'SliderStep',[minstepg maxstepg],...[1e-5/2 50e-5/2],...
        'Style','slider');
    
     heditg3 = uicontrol(...
        'Parent',hpanelg,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditg,3},...
        'FontSize',ftsz,...
        'Position',[0.02 0.28 0.32 0.2],...
        'TooltipString','g_3',...
        'Style','edit');
    
      hmarkerg3 = uicontrol(...  
        'Parent',hpanelg,...
        'Units','normalized',...
        'Position',[0.02 0.28 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');

      hslidg3 = uicontrol(...
        'Parent',hpanelg,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidg,3},...
        'Position',[0.36 0.31 0.62 0.14],...
         'TooltipString','g_3',...
        'Min',gmin,...2.00000
        'Max',gmax,...2.01800,...
        'SliderStep',[minstepg maxstepg],...[1e-5/2 50e-5/2],...
        'Style','slider');
    

       uicontrol(...  % text g_iso=
        'Parent',hpanelg,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',1.1*ftsz,...
        'FontName','Times New Roman',...
        'Position',[0.28 0.06 0.25 0.1],...'BackgroundColor','w',...
        'String','g_iso =',...
        'TooltipString','Averaged g value',...
        'Style','text');
    
       hgmoy = uicontrol(...  % 
        'Parent',hpanelg,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...'backgroundcolor','w',...
        'FontSize',ftsz,...
        'Position',[0.49 0.07 0.2 0.1],...
        'TooltipString','Averaged g value',...
        'Style','text');

%%%% A1  %%%%%%%
    hpanelA1 = uipanel(...
        'Parent',hcurrentcomp,...
        'FontUnits','pixels',...
        'FontSize',1.6*ftsz,...
        'FontWeight','bold',...
        'Title','A_1',...
        'Position',[0.31 0.03 0.33 0.57]);

    hpopupI1 = uicontrol(...
        'Parent',hpanelA1,...
        'FontUnits','pixels',...
        'FontSize',ftsz,...
        'BackgroundColor','w',...
        'Units','normalized',...
        'Callback',{@cllbckpopupI,1},...
        'Position',[0.01 0.6 0.15 0.25],...
        'String',differentI,...
        'Style','popupmenu',...
        'TooltipString','Nuclear spin for the 1st hyperfine coupling',...
        'Value',1);

    haxialA1 = uicontrol(...
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'Callback',{@cllbckaxialA,1},...
        'FontSize',ftsz,...
        'Position',[0.02 0.4 0.12 0.15],...
        'String','Axial',...
        'TooltipString','Axial A1 tensor',...
        'enable','off',...
        'Style','pushbutton');    
    
    heditA11 = uicontrol(...
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditA,1,1},...
        'FontSize',ftsz,...
        'Position',[0.18 0.74 0.18 0.2],...
        'TooltipString','A1_1',...
        'enable','off',...
        'Style','edit');
    
    hmarkerA11 = uicontrol(...  
        'Parent',hpanelA1,...
        'Units','normalized',...
        'Position',[0.18 0.74 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');
    
     uicontrol(...  % text mT(A1_1)
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.36 0.78 0.1 0.1],...'BackgroundColor','w',...
        'String','mT',...
        'enable','off',...
        'Style','text');

     hslidA11 = uicontrol(...
        'Parent',hpanelA1,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidA,1,1},...
        'Position',[0.46 0.77 0.52 0.14],...
        'TooltipString','A1_1',...
        'Min',Amin,...
        'Max',Amax,...
        'SliderStep',[minstepA maxstepA],...
        'enable','off',...
        'Style','slider');    

     heditA12 = uicontrol(...
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditA,1,2},...
        'FontSize',ftsz,...
        'Position',[0.18 0.51 0.18 0.2],...
        'TooltipString','A1_2',...
        'enable','off',...
        'Style','edit');
     
     hmarkerA12 = uicontrol(...  
        'Parent',hpanelA1,...
        'Units','normalized',...
        'Position',[0.18 0.51 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');

     uicontrol(...  % text mT(A1_2)
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.36 0.55 0.1 0.1],...'BackgroundColor','w',...
        'String','mT',...
        'enable','off',...
        'Style','text');
    
      hslidA12 = uicontrol(...
        'Parent',hpanelA1,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidA,1,2},...
        'Position',[0.46 0.54 0.52 0.14],...
        'TooltipString','A1_2',...
        'Min',Amin,...
        'Max',Amax,...
        'SliderStep',[minstepA maxstepA],...
        'enable','off',...
        'Style','slider');
    
     heditA13 = uicontrol(...
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditA,1,3},...
        'FontSize',ftsz,...
        'Position',[0.18 0.28 0.18 0.2],...
        'TooltipString','A1_3',...
        'enable','off',...
        'Style','edit');

    hmarkerA13 = uicontrol(...  
        'Parent',hpanelA1,...
        'Units','normalized',...
        'Position',[0.18 0.28 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');

     uicontrol(...  % text mT(A1_3)
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.36 0.32 0.1 0.1],...'BackgroundColor','w',...
        'String','mT',...
        'enable','off',...
        'Style','text');
    
      hslidA13 = uicontrol(...
        'Parent',hpanelA1,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidA,1,3},...
        'Position',[0.46 0.31 0.52 0.14],...
        'TooltipString','A1_3',...
        'Min',Amin,...
        'Max',Amax,...
        'SliderStep',[minstepA maxstepA],...
        'enable','off',...
        'Style','slider');
    
      uicontrol(...  % text A1_iso=
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.28 0.07 0.25 0.1],...'BackgroundColor','w',...
        'String','A_1_iso =',...
        'TooltipString','Averaged A1 value',...
        'enable','off',...
        'Style','text');
    
      hA1moy = uicontrol(...  % 
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...'backgroundcolor','w',...
        'FontSize',ftsz,...
        'Position',[0.5 0.07 0.1 0.1],...
        'TooltipString','Averaged A1 value',...
        'enable','off',...
        'Style','text');
    
      uicontrol(...  % text mT(A1moy)
        'Parent',hpanelA1,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.6 0.07 0.08 0.1],...'BackgroundColor','w',...
        'String','mT',...
        'TooltipString','Averaged A1 value',...
        'enable','off',...
        'Style','text');

%%%% A2  %%%%%%%
    hpanelA2 = uipanel(...
        'Parent',hcurrentcomp,...
        'FontUnits','pixels',...
        'FontSize',1.6*ftsz,...
        'FontWeight','bold',...
        'Title','A_2',...
        'Position',[0.66 0.03 0.33 0.57]);

    hpopupI2 = uicontrol(...
        'Parent',hpanelA2,...
        'FontUnits','pixels',...
        'FontSize',ftsz,...
        'BackgroundColor','w',...
        'Units','normalized',...
        'Callback',{@cllbckpopupI,2},...
        'Position',[0.01 0.6 0.15 0.25],...
        'String',differentI,...
        'Style','popupmenu',...
        'TooltipString','Nuclear spin for the 2nd hyperfine coupling',...
        'enable','off',...
        'Value',1);

    haxialA2 = uicontrol(...
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'Callback',{@cllbckaxialA,2},...
        'FontSize',ftsz,...
        'Position',[0.02 0.4 0.12 0.15],...
        'String','Axial',...
        'TooltipString','Axial A2 tensor',...
        'enable','off',...
        'Style','pushbutton');    
    
    heditA21 = uicontrol(...
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditA,2,1},...
        'FontSize',ftsz,...
        'Position',[0.18 0.74 0.18 0.2],...
        'TooltipString','A2_1',...
        'enable','off',...
        'Style','edit');
    
    hmarkerA21 = uicontrol(...  
        'Parent',hpanelA2,...
        'Units','normalized',...
        'Position',[0.18 0.74 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');    
    
     uicontrol(...  % text mT(A2_1)
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.36 0.78 0.1 0.1],...'BackgroundColor','w',...
        'String','mT',...
        'enable','off',...
        'Style','text');

     hslidA21 = uicontrol(...
        'Parent',hpanelA2,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidA,2,1},...
        'Position',[0.46 0.77 0.52 0.14],...
        'TooltipString','A2_1',...
        'Min',Amin,...
        'Max',Amax,...
        'SliderStep',[minstepA maxstepA],...
        'enable','off',...
        'Style','slider');    

     heditA22 = uicontrol(...
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditA,2,2},...
        'FontSize',ftsz,...
        'Position',[0.18 0.51 0.18 0.2],...
        'TooltipString','A2_2',...
        'enable','off',...
        'Style','edit');
    
      hmarkerA22 = uicontrol(...  
        'Parent',hpanelA2,...
        'Units','normalized',...
        'Position',[0.18 0.51 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');   

     uicontrol(...  % text mT(A2_2)
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.36 0.55 0.1 0.1],...'BackgroundColor','w',...
        'String','mT',...
        'enable','off',...
        'Style','text');
    
      hslidA22 = uicontrol(...
        'Parent',hpanelA2,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidA,2,2},...
        'Position',[0.46 0.54 0.52 0.14],...
        'TooltipString','A2_2',...
        'Min',Amin,...
        'Max',Amax,...
        'SliderStep',[minstepA maxstepA],...
        'enable','off',...
        'Style','slider');
    
     heditA23 = uicontrol(...
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'BackgroundColor','w',...
        'Callback',{@cllbckeditA,2,3},...
        'FontSize',ftsz,...
        'Position',[0.18 0.28 0.18 0.2],...
        'TooltipString','A2_3',...
        'enable','off',...
        'Style','edit');
    
    hmarkerA23 = uicontrol(...  
        'Parent',hpanelA2,...
        'Units','normalized',...
        'Position',[0.18 0.28 0.02 0.2],...
        'BackgroundColor','k',...
        'visible','off',...
        'Style','text');

     uicontrol(...  % text mT(A2_3)
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.36 0.32 0.1 0.1],...'BackgroundColor','w',...
        'String','mT',...
        'enable','off',...
        'Style','text');
    
      hslidA23 = uicontrol(...
        'Parent',hpanelA2,...
        'Units','normalized',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@cllbckslidA,2,3},...
        'Position',[0.46 0.31 0.52 0.14],...
        'TooltipString','A2_3',...
        'Min',Amin,...
        'Max',Amax,...
        'SliderStep',[minstepA maxstepA],...
        'enable','off',...
        'Style','slider');
    
      uicontrol(...  % text A2_iso=
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.28 0.07 0.25 0.1],...'BackgroundColor','w',...
        'String','A_2_iso =',...
        'TooltipString','Averaged A2 value',...
        'enable','off',...
        'Style','text');
    
      hA2moy = uicontrol(...  % 
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...'backgroundcolor','w',...
        'FontSize',ftsz,...
        'Position',[0.5 0.07 0.1 0.1],...
        'TooltipString','Averaged A2 value',...
        'enable','off',...
        'Style','text');
    
      uicontrol(...  % text mT(A2moy)
        'Parent',hpanelA2,...
        'Units','normalized',...
        'FontUnits','pixels',...
        'HorizontalAlignment','center',...
        'FontSize',ftsz,...
        'Position',[0.6 0.07 0.08 0.1],...'BackgroundColor','w',...
        'String','mT',...
        'TooltipString','Averaged A2 value',...
        'enable','off',...
        'Style','text');



        hfig=hcurrentcomp; %handle=double

    componentnumber=numel(componenth)+1;
    
 % structure avec handles de la fenetre venant d'etre construite
%   tempstruct = struct('hfig',hfig,...
%     'hname',hname,'hchk',hchk,'hvisible',hvisible,'hhide',hhide,...
%     'htextweight',htextweight,'heditweight',heditweight,'htextpercent',htextpercent,...
%     'hedittime',hedittime,'hslidtime',hslidtime,...
%     'heditlorentzian',heditlorentzian,'hslidlorentzian',hslidlorentzian,'heditgaussian',heditgaussian,'hslidgaussian',hslidgaussian,...
%     'hpanelg',hpanelg,'heditg',[heditg1 heditg2 heditg3],'hslidg',[hslidg1 hslidg2 hslidg3],...
%     'haxialg',haxialg','hmarkerg',[hmarkerg1 hmarkerg2 hmarkerg3],'hgmoy',hgmoy,...
%     'hpopupI',[hpopupI1 hpopupI2],'haxialA',[haxialA1 haxialA2],'heditA',[heditA11 heditA12 heditA13;heditA21 heditA22 heditA23],...
%     'hslidA',[hslidA11 hslidA12 hslidA13;hslidA21 hslidA22 hslidA23],'hAmoy',[hA1moy,hA2moy],...
%     'hpanelA',[hpanelA1 hpanelA2],'hmarkerA',[hmarkerA11 hmarkerA12 hmarkerA13;hmarkerA21 hmarkerA22 hmarkerA23]); 

  %componenth(componentnumber)=tempstruct;
    componenth(componentnumber).hfig=hfig;
    componenth(componentnumber).hname=hname;
    componenth(componentnumber).hchk=hchk;
    componenth(componentnumber).hvisible=hvisible;
    componenth(componentnumber).hhide=hhide;
    componenth(componentnumber).htextweight=htextweight;
    componenth(componentnumber).heditweight=heditweight;
    componenth(componentnumber).htextpercent=htextpercent;
    componenth(componentnumber).hedittime=hedittime;
    componenth(componentnumber).hslidtime=hslidtime;
    componenth(componentnumber).heditlorentzian=heditlorentzian;
    componenth(componentnumber).hslidlorentzian=hslidlorentzian;
    componenth(componentnumber).heditgaussian=heditgaussian;
    componenth(componentnumber).hslidgaussian=hslidgaussian;
    componenth(componentnumber).hpanelg=hpanelg;
    componenth(componentnumber).heditg=[heditg1 heditg2 heditg3];
    componenth(componentnumber).hslidg=[hslidg1 hslidg2 hslidg3];
    componenth(componentnumber).haxialg=haxialg;
    componenth(componentnumber).hmarkerg=[hmarkerg1 hmarkerg2 hmarkerg3];
    componenth(componentnumber).hgmoy=hgmoy;
    componenth(componentnumber).hpopupI=[hpopupI1 hpopupI2];
    componenth(componentnumber).haxialA=[haxialA1 haxialA2];
    componenth(componentnumber).heditA=[heditA11 heditA12 heditA13;heditA21 heditA22 heditA23];
    componenth(componentnumber).hslidA=[hslidA11 hslidA12 hslidA13;hslidA21 hslidA22 hslidA23];
    componenth(componentnumber).hAmoy=[hA1moy,hA2moy];
    componenth(componentnumber).hpanelA=[hpanelA1 hpanelA2];
    componenth(componentnumber).hmarkerA=[hmarkerA11 hmarkerA12 hmarkerA13;hmarkerA21 hmarkerA22 hmarkerA23]; 
    componenth(componentnumber).hplot=hinit; %reinitialisayion du handle de plot

end


%% Affichage d'une composante
function dispcomponent(nieme) %affichage des donnees niemes sur la figure correspondante 
  
    structdata=componentdata(nieme); %donnees a afficher
    structh=componenth(nieme); %handles correspondant
    %componenth
    figname=get(structh.hfig,'name'); %nom de la figure courante
    fignumber=str2double(figname(10:end)); % numero de la figure courante SimLabel_XX
    
    % initialisation des marqueurs d'axialite (si ils etaient present dans
    % une fenetre reutilisee)
    set(structh.hmarkerg,'visible','off');
    set(structh.hmarkerA,'visible','off');
   
    if fignumber>size(kolor,1)
        fignumberstr=num2str(fignumber);
        kolornumber=str2double(fignumberstr(end))-1;
    else
        kolornumber=fignumber;
    end;
    
    set(structh.hname,'ForegroundColor',kolor(kolornumber,:));
    componentdata(nieme).color=kolor(kolornumber,:);
    if strcmp(structdata.name,'')
        componentname=['component ',num2str(fignumber)];
        componentdata(nieme).name=componentname;
    else
        componentname=structdata.name;
    end
    set(structh.hname,'string',componentname);
    

    
    set(structh.heditweight,'string',num2str(structdata.weightval));
    %set(structh.htextpercent,'string',['(=',structdata.percentstr,'%)']); 

    set(structh.hchk,'value',structdata.include);
    if structdata.include
        set(structh.hvisible,'enable','on','value',structdata.status);
        set(structh.hhide,'enable','on','value',~structdata.status);
    else
        set(structh.hvisible,'enable','off','value',structdata.status);
        set(structh.hhide,'enable','off','value',~structdata.status);
    end

    if strcmp(timeenable,'off') %frozen solution
        set(structh.hedittime,'string','');
    else
        set(structh.hedittime,'string',num2str(structdata.tcorrval,'%3.2e'));
    end
    set(structh.hslidtime,'value',log10(structdata.tcorrval));

    set(structh.heditlorentzian,'string',num2str(structdata.lorentzianval,'%3.2f'));
    set(structh.hslidlorentzian,'value',structdata.lorentzianval);    
    
    set(structh.heditgaussian,'string',num2str(structdata.gaussianval,'%3.2f'));
    set(structh.hslidgaussian,'value',structdata.gaussianval);
    
    for i=1:3 %g
        set(structh.heditg(i),'string',num2str(structdata.gval(i),'%6.5f'));
        set(structh.hslidg(i),'value',(structdata.gval(i)-2)*1e5);  
    end
    set(structh.hgmoy,'string',num2str(mean(structdata.gval),'%6.5f'));
    
    if ~isnan(structdata.axialcombinationg)
            for j=1:2
               set(structh.hmarkerg(structdata.axialcombinationg(j)),'visible','on');
            end
    end
    %structdata.Istr
    for i=1:2 %A1 ou A2
        for k=1:3
            set(structh.hpopupI(i),'value',find(ismember(differentI,structdata.Istr{i}))); %donne indice (pour value) de Ii dans cellarray differentI
            if ~isnan(structdata.Aval(i,k)) 
                set(structh.hslidA(i,k),'value',structdata.Aval(i,k));
                set(structh.heditA(i,k),'string',num2str(structdata.Aval(i,k),'%3.2f'));
            else
                set(structh.hslidA(i,k),'value',Amin); %pour que le slider soit affiche meme si pas de valeur
                set(structh.heditA(i,k),'string','');
            end
        end

        Amoy=mean(structdata.Aval(i,:));
        if ~isnan(Amoy)
            set(structh.hAmoy(i),'string',num2str(Amoy,'%3.2f'));
        else
            set(structh.hAmoy(i),'string','')
        end
        
        if ~isnan(structdata.axialcombinationA(i,:))
            for j=1:2
               set(structh.hmarkerA(i,structdata.axialcombinationA(i,j)),'visible','on');
            end
        end
    
    end

    
    enableA(nieme); %gestion de la propriete 'enable' des A de la nieme composante
    dispweight();
    disppercent(); %affichage des %

end


%% Callback function de SimLabel_X
function cllbckname(hobject,~)
    place=[componenth.hname]==hobject; %indice considere dans la structure des handles componenth
    componentdata(place).name=get(hobject,'string');
    setlegend()
    set(hlist,'value',[]);%pas de selection dans la liste
    set(hfreq,'TooltipString','');
    if ishandle(hplotsimall)
        set(hsavesimul,'enable','on');
    end
end


function cllbckchk(hobject,~) %cllbck include
        
        place=find([componenth.hchk]==hobject); %indice considere dans la structure des handles componenth

        if get(hobject,'Value')==1
            componentdata(place).include=1;
            set(componenth(place).hvisible,'enable','on');
            set(componenth(place).hhide,'enable','on');

            if isempty(get(hspecaxes,'children'))%~ishandle(hspecexp)
                set(hspecaxes,'xlim',[0 1],'ylim',[0 1],'Xtick',NaN); %reinitialisation si pas de simul affichee
            end

        else
            if ishandle(componenth(place).hplot) %suppression de la simul de la composante
                delete(componenth(place).hplot)
                componenth(place).hplot=hinit;
            end
            componentdata(place).include=0;
            componentdata(place).status=0;
            set(componenth(place).hvisible,'enable','off','value',0);
            set(componenth(place).hhide,'enable','off','value',1);

        end;


        if get(hrealtime,'value')==1
            if isempty(componentdata(place).specsimul)
                set(componenth(place).hchk,'value',0);
                componentdata(place).include=0;
                uiwait(msgbox({'WARNING:   This component can''t be included...';'';'You should first perform global simulation with "Run. Simul."...'},...
                 'SimLabel_WARNING','Warn','modal'));
            else
                runsimul2(hobject);%si modif des include
                dispweight();
                disppercent();
                
            end
        else
           aspectbeforemanualrunsimul(place,1); %1:appel de aspect..simul depuis checkcallback
           dispweight();
           disppercent();
            
        end

   
end

function cllbckstorepar(hobject,~) %garder parametres de la composante courante pour la suivante
    hfig=get(hobject,'parent'); %handle de la figure correspondante
    place=find([componenth.hfig]==hfig); %indice considere dans la structure des handles componenth
    componentdata(1)=componentdata(place);
    componentdata(1).name='';
    componentdata(1).weightval=1;
    componentdata(1).include=1;
    componentdata(1).status=0;
    componentdata(1).specsimul=[];
    Sys{1}=Sys{place};
    Sys{1}.weight=1;

end


function reinitcomponent(~,~) %reinitialiser parametres de la composante courante pour la suivante
    componentdata(1)=componentdatainit;
    componentdata(1).name='';
    componentdata(1).weightval=1;
    componentdata(1).include=1;
    componentdata(1).status=0;
    componentdata(1).specsimul=[];
    Sys{1}=Sysinit;

end


function visible_or_hide(hobject,~) %hobject= handle du button group
    hfig=get(hobject,'parent'); %handle de la figure correspondante
    place=find([componenth.hfig]==hfig); %indice considere dans la structure des handles componenth
    if get(componenth(place).hvisible,'value')==1
        if ishandle(componenth(place).hplot)
            set(componenth(place).hplot,'visible','on');
            componentdata(place).status=1;
        elseif isempty(componentdata(place).specsimul) % simul pas encore calculee
            set(componenth(place).hvisible,'value',0);
            set(componenth(place).hhide,'value',1);
            componentdata(place).status=0;
        else %simul loadee mais jamais affichee
            componentdata(place).status=1;
            componenth(place).hplot=plot(hspecaxes,Bsimul,scalefact*componentdata(place).specsimul,'color',componentdata(place).color,'visible','on');
        end
    else
        componentdata(place).status=0;
        set(componenth(place).hplot,'visible','off')
    end
    if ishandle(hspecexp)
      uistack(hspecexp,'top'); %spectre exp au 1er plan
    end
    setlegend();
end

function cllbckedittime(hobject,~)
   % set(hlist,'value',[]);%pas de selection dans la liste
    place=find([componenth.hedittime]==hobject); %indice considere dans la structure des handles componenth
    time=str2double(get(hobject,'string'));
    if isnan(time)
        time=componentdata(1).tcorrval;
    end
    time=str2double(num2str(time,'%3.2e')); %correspondance exacte entre affichage et valeur en memoire
    set(hobject,'string',num2str(time,'%3.2e')); %mise au bon format
    componentdata(place).tcorrval=time;
    Sys{place}.logtcorr=log10(time);
    set(componenth(place).hslidtime, 'Value' , log10(time)); %accord slider et entree manuelle
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        runsimul(hobject)
    else
        aspectbeforemanualrunsimul(place,0);
    end
end

function cllbckslidtime(hobject,~)
    %set(hlist,'value',[]);%pas de selection dans la liste
    place=find([componenth.hslidtime]==hobject); %indice considere dans la structure des handles componenth
    time=get(hobject,'value');
    componentdata(place).tcorrval=str2double(num2str(10^time,'%3.2e'));
    Sys{place}.logtcorr=time;
    set(componenth(place).hedittime,'string',num2str(10^time,'%3.2e')); %mise au bon format
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        runsimul(hobject)
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

function cllbckeditweight(hobject,~)
    %set(hlist,'value',[]);%pas de selection dans la liste
    place=[componenth.heditweight]==hobject; %indice considere dans la structure des handles componenth
    weight=str2double(get(hobject,'string'));
    if isnan(weight)
        weight=componentdata(1).weightval;
    end
    componentdata(place).weightval=weight;
    Sys{place}.weight=weight;
    set(hobject,'string',num2str(weight,'%3.2f')); %mise au bon format
    disppercent(); %recalcul des pourcentages
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        runsimul(hobject)
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

function cllbckeditlorentzian(hobject,~)
    %set(hlist,'value',[]);%pas de selection dans la liste
    place=find([componenth.heditlorentzian]==hobject); %indice considere dans la structure des handles componenth
    lor=str2double(get(hobject,'string'));
    if isnan(lor)
        lor=componentdata(1).lorentzianval;
    end
    if componentdata(place).gaussianval==0 && lor==0 %les deux largeurs ne peuvent etre nulles en meme temps
        lor=0.01;
    end;
    lor=str2double(num2str(lor,'%3.2f')); %correspondance exacte entre affichage et valeur en memoire
    set(hobject,'string',num2str(lor,'%3.2f')); %mise au bon format
    componentdata(place).lorentzianval=lor;
    Sys{place}.lw(2)=lor;
    set(componenth(place).hslidlorentzian, 'Value',lor); %accord slider et entree manuelle
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        runsimul(hobject)
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

function cllbckslidlorentzian(hobject,~)
    %set(hlist,'value',[]);%pas de selection dans la liste
    place=find([componenth.hslidlorentzian]==hobject); %indice considere dans la structure des handles componenth
    lor=get(hobject,'value');
    if componentdata(place).gaussianval==0 && lor==0 %les deux largeurs ne peuvent etre nulles en meme temps
        lor=0.01;
        set(componenth(place).hslidlorentzian, 'Value',lor); %accord slider et entree manuelle
    end;
    lor=str2double(num2str(lor,'%3.2f')); %correspondance exacte entre affichage et valeur en memoire
    componentdata(place).lorentzianval=lor;
    Sys{place}.lw(2)=lor;
    set(componenth(place).heditlorentzian,'string',num2str(lor,'%3.2f')); %mise au bon format
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        runsimul(hobject)
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

function cllbckeditgaussian(hobject,~)
    %set(hlist,'value',[]);%pas de selection dans la liste
    place=find([componenth.heditgaussian]==hobject); %indice considere dans la structure des handles componenth
    gauss=str2double(get(hobject,'string'));
    if isnan(gauss)
        gauss=componentdata(1).gaussianval;
    end
    if componentdata(place).lorentzianval==0 && gauss==0 %les deux largeurs ne peuvent etre nulles en meme temps
        gauss=0.01;
    end;
    gauss=str2double(num2str(gauss,'%3.2f')); %correspondance exacte entre affichage et valeur en memoire
    set(hobject,'string',num2str(gauss,'%3.2f')); %mise au bon format
    componentdata(place).gaussianval=gauss;
    Sys{place}.lw(1)=gauss;
    set(componenth(place).hslidgaussian, 'Value',gauss); %accord slider et entree manuelle
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        runsimul(hobject)
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

function cllbckslidgaussian(hobject,~)
    %set(hlist,'value',[]);%pas de selection dans la liste
    place=find([componenth.hslidgaussian]==hobject); %indice considere dans la structure des handles componenth
    gauss=get(hobject,'value');
    if componentdata(place).lorentzianval==0 && gauss==0 %les deux largeurs ne peuvent etre nulles en meme temps
        gauss=0.01;
        set(componenth(place).hslidgaussian, 'Value',gauss); %accord slider et entree manuelle
    end;
    gauss=str2double(num2str(gauss,'%3.2f')); %correspondance exacte entre affichage et valeur en memoire
    componentdata(place).gaussianval=gauss;
    Sys{place}.lw(1)=gauss;
    set(componenth(place).heditgaussian,'string',num2str(gauss,'%3.2f')); %mise au bon format
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        runsimul(hobject)
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

%%%  g  %%%%
function cllbckaxialg(hobject,~)
    if get(hrealtime,'value')==0
        if ishandle(hplotsimall) %suppression de la simul totale
            delete(hplotsimall)
            hplotsimall=hinit;
            set(hsavesimul,'enable','off');
            setlegend()
            set(hfreq,'string','');
            set(hsuprsimul,'enable','off');
        end
        set(hlist,'value',[]);%pas de selection dans la liste

        hpanel=get(hobject,'parent');
        place=[componenth.hfig]==get(hpanel,'parent'); %indice considere dans la structure des handles componenth

        markerstatestr=[get(componenth(place).hmarkerg(1),'visible'),' ',... marqueurs actuel (genre 'off on on')
                        get(componenth(place).hmarkerg(2),'visible'),' ',...
                        get(componenth(place).hmarkerg(3),'visible')];
        possibility=find(strcmp(markerstatestr,markerstatepossy)); %numero de ligne dans markerstatepossy
        if possibility==4
            nextpossibility=1;
        else
            nextpossibility=possibility+1;
        end
        nextpossibilitystr=markerstatepossy{nextpossibility};
        indspace=strfind(nextpossibilitystr,' '); %indice des espaces dans str ('on off on' par ex)=>indspace a 2 elements
        nextpossibility_cell={nextpossibilitystr(1:indspace(1)-1) ...
                              nextpossibilitystr(indspace(1)+1:indspace(2)-1)... 'on off on'=>{'on' 'off' 'on'}
                              nextpossibilitystr(indspace(2)+1:end)};
        %axialcombinationA
       [~,onpos]=ismember(nextpossibility_cell,{'on'}); % cas 'off off off'=> onpos=[0 0 0]
       if sum(onpos)==0
           componentdata(place).axialcombinationg=[NaN NaN];
       else
           componentdata(place).axialcombinationg=find(onpos);
       end
       %disp(componentdata(place).axialcombinationA)
        for k=1:3
            set(componenth(place).hmarkerg(k),'visible',nextpossibility_cell{k});             
        end 
    else
        uiwait(msgbox({'WARNING:   "Real time" mode selected...';'';'Quit "Real time" first...'},...
            'SimLabel_WARNING','Warn','modal'));
   end    
end

function cllbckeditg(hobject,~,k)
    %set(hlist,'value',[]);%pas de selection dans la liste
    hpanel=get(hobject,'parent');
    place=find([componenth.hpanelg]==hpanel); %indice considere dans la structure des handles componenth
    g=str2double(get(hobject,'string'));
    if isnan(g)
        g=componentdata(1).gval(1);
    else
        g=str2double(num2str(g,'%6.5f')); %correspondance exacte entre affichage et valeur en memoire
    end
    poseq=componentdata(place).axialcombinationg; %positions x y / gx=gy (si non NaN)
    
    if ~ismember(k,poseq)
        if isnan(g)
            g=componentdata(1).gval(k);
        else
            set(hobject,'string',num2str(g,'%6.5f')); %mise au bon format
            set(componenth(place).hslidg(k), 'Value',g); %accord slider et entree manuelle
        end
        componentdata(place).gval(k)=g;%sauvegarde
        Sys{place}.g(k)=g;
        set(componenth(place).hslidg(k), 'Value',(g-2)*1e5); %accord slider et entree manuelle
    else
        for j=1:2 %donnees axiales donc 2 affichages
            if isnan(g)
                g=componentdata(1).gval(poseq(j));
            end
            set(componenth(place).heditg(poseq(j)),'string',num2str(g,'%6.5f')); 
            set(componenth(place).hslidg(poseq(j)),'value',(g-2)*1e5); %pour que le slider soit affiche meme si pas de valeur
            componentdata(place).gval(poseq(j))=g;%sauvegarde
            Sys{place}.g(poseq(j))=g;
        end 
    end
    dispgmoy(place);
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        if ~isequal(componentdata(place).gval,[2.00000 2.00000 2.00000])
            runsimul(hobject)
        end
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

function cllbckslidg(hobject,~,k)
    %set(hlist,'value',[]);%pas de selection dans la liste
    hpanel=get(hobject,'parent');
    place=find([componenth.hpanelg]==hpanel); %indice considere dans la structure des handles componenth
    g=2+1e-5*get(hobject,'value');
    g=str2double(num2str(g,'%6.5f')); %correspondance exacte entre affichage et valeur en memoire
    poseq=componentdata(place).axialcombinationg; %positions x y / gx=gy (si non NaN)
    if ~ismember(k,poseq)
        componentdata(place).gval(k)=g;
        Sys{place}.g(k)=g;
        set(componenth(place).heditg(k),'string',num2str(g,'%6.5f')); %mise au bon format
    else
        for j=1:2
            set(componenth(place).hslidg(poseq(j)),'value',(g-2)*1e5);
            componentdata(place).gval(poseq(j))=g;%correspondance exacte entre affichage et valeur en memoire
            Sys{place}.g(poseq(j))=g;
            set(componenth(place).heditg(poseq(j)),'string',num2str(g,'%6.5f')); %mise au bon format

        end
    end

    dispgmoy(place);
    if get(hrealtime,'value')==1 && componentdata(place).include==1
       % if ~isequal(componentdata(place).gval,[2.00000 2.00000 2.00000])
            runsimul(hobject)
       % end
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

%%% A %%%
function cllbckpopupI(hobject,~,i)
    %set(hlist,'value',[]);%pas de selection dans la liste
    hpanel=get(hobject,'parent');
    place=find([componenth.hfig]==get(hpanel,'parent')); %indice considere dans la structure des handles componenth
    Istr=differentI(get(hobject,'value'));
    componentdata(place).Istr{i}=Istr;
    enableA(place); %gestion de la propriete 'enable' des A
    SysAetNucs(place); %gestion des champs A et Nucs de Sys pour simul easyspin
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        if ~strcmp(Istr,'') 
            if isempty(find(isnan(componentdata(place).Aval(i,:)), 1))
                runsimul(hobject)
            end
        else
            runsimul(hobject)
        end
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end
 
function cllbckaxialA(hobject,~,i)
    if get(hrealtime,'value')==0
        if ishandle(hplotsimall) %suppression de la simul totale
            delete(hplotsimall)
            hplotsimall=hinit;
            set(hsavesimul,'enable','off');
            setlegend()
            set(hfreq,'string','');
            set(hsuprsimul,'enable','off');
        end
        set(hlist,'value',[]);%pas de selection dans la liste
        hpanel=get(hobject,'parent');
        place=[componenth.hfig]==get(hpanel,'parent'); %indice considere dans la structure des handles componenth

        markerstatestr=[get(componenth(place).hmarkerA(i,1),'visible'),' ',... marqueurs actuel (genre 'off on on')
                        get(componenth(place).hmarkerA(i,2),'visible'),' ',...
                        get(componenth(place).hmarkerA(i,3),'visible')];
        possibility=find(strcmp(markerstatestr,markerstatepossy)); %numero de ligne dans markerstatepossy
        if possibility==4
            nextpossibility=1;
        else
            nextpossibility=possibility+1;
        end
        nextpossibilitystr=markerstatepossy{nextpossibility};
        indspace=strfind(nextpossibilitystr,' '); %indice des espaces dans str ('on off on' par ex)=>indspace a 2 elements
        nextpossibility_cell={nextpossibilitystr(1:indspace(1)-1) ...
                              nextpossibilitystr(indspace(1)+1:indspace(2)-1)... 'on off on'=>{'on' 'off' 'on'}
                              nextpossibilitystr(indspace(2)+1:end)};
        %axialcombinationA
       [~,onpos]=ismember(nextpossibility_cell,{'on'}); % cas 'off off off'=> onpos=[0 0 0]
       if sum(onpos)==0
           componentdata(place).axialcombinationA(i,:)=[NaN NaN];
       else
           componentdata(place).axialcombinationA(i,:)=find(onpos);
       end
       %disp(componentdata(place).axialcombinationA)
        for k=1:3
            set(componenth(place).hmarkerA(i,k),'visible',nextpossibility_cell{k});             
        end
   else
        uiwait(msgbox({'WARNING:   "Real time" mode selected...';'';'Quit "Real time" first...'},...
            'SimLabel_WARNING','Warn','modal'));
   end
end

function cllbckeditA(hobject,~,i,k) %couplage i coordonnee k
    %set(hlist,'value',[]);%pas de selection dans la liste
    hpanel=get(hobject,'parent');
    place=find([componenth.hfig]==get(hpanel,'parent')); %indice considere dans la structure des handles componenth
    A=str2double(get(hobject,'string'));
    if isnan(A)
        A=componentdata(1).Aval(1);
    else
        A=str2double(num2str(A,'%3.2f')); %correspondance exacte entre affichage et valeur en memoire
    end

    poseq=componentdata(place).axialcombinationA(i,:); %positions x y / Ax=Ay (si non NaN)
    
    if ~ismember(k,poseq)
        if isnan(A)
            A=componentdata(1).Aval(i,k);
            set(hobject,'string',''); 
            set(componenth(place).hslidA(i,k),'value',Amin); %pour que le slider soit affiche meme si pas de valeur
        else
            set(hobject,'string',num2str(A,'%3.2f')); %mise au bon format
            set(componenth(place).hslidA(i,k), 'Value',A); %accord slider et entree manuelle
        end
        componentdata(place).Aval(i,k)=A;%sauvegarde
    else
        for j=1:2 %donnees axiales donc 2 affichages
            if isnan(A)
                A=componentdata(1).Aval(i,poseq(j));
                set(componenth(place).heditA(i,poseq(j)),'string',''); 
                set(componenth(place).hslidA(i,poseq(j)),'value',Amin); %pour que le slider soit affiche meme si pas de valeur
                
            else
                set(componenth(place).heditA(i,poseq(j)),'string',num2str(A,'%3.2f')); %mise au bon format
                set(componenth(place).hslidA(i,poseq(j)), 'Value',A); %accord slider et entree manuelle
            end
            componentdata(place).Aval(i,poseq(j))=A;%sauvegarde
        end
    end
    
    dispAmoy(componenth(place).hAmoy(i),componentdata(place).Aval(i,:)); %affichage de Amoy,sur uicontrol de handle hAmoy
    enableA(place); %gestion de la propriete 'enable' des A
    SysAetNucs(place); %gestion des champs A et Nucs de Sys pour simul easyspin
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        if ~strcmp(componentdata(place).Istr{i},'') && isempty(find(isnan(componentdata(place).Aval(i,:)), 1))
            runsimul(hobject)
        end
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

function cllbckslidA(hobject,~,i,k) %couplage i coordonnee k
    %set(hlist,'value',[]);%pas de selection dans la liste
    hpanel=get(hobject,'parent');
    place=find([componenth.hfig]==get(hpanel,'parent')); %indice considere dans la structure des handles componenth
    A=get(hobject,'value');
    poseq=componentdata(place).axialcombinationA(i,:); %positions x y / Ax=Ay (si non NaN)
    if ~ismember(k,poseq)
        componentdata(place).Aval(i,k)=str2double(num2str(A,'%3.2f'));%correspondance exacte entre affichage et valeur en memoire
        set(componenth(place).heditA(i,k),'string',num2str(A,'%3.2f')); %mise au bon format
    else
        for j=1:2
            set(componenth(place).hslidA(i,poseq(j)),'value',A);
            componentdata(place).Aval(i,poseq(j))=str2double(num2str(A,'%3.2f'));%correspondance exacte entre affichage et valeur en memoire
            set(componenth(place).heditA(i,poseq(j)),'string',num2str(A,'%3.2f')); %mise au bon format

        end
    end
    dispAmoy(componenth(place).hAmoy(i),componentdata(place).Aval(i,:)); %affichage de Amoy,sur uicontrol de handle hAmoy
    enableA(place); %gestion de la propriete 'enable' des A
    SysAetNucs(place); %gestion des champs A et Nucs de Sys pour simul easyspin
    if get(hrealtime,'value')==1 && componentdata(place).include==1
        if ~strcmp(componentdata(place).Istr{i},'') && isempty(find(isnan(componentdata(place).Aval(i,:)), 1))
            runsimul(hobject)
        end
    else 
        aspectbeforemanualrunsimul(place,0);
    end
end

function  aspectbeforemanualrunsimul(place,fromchk)
    if componentdata(place).include || fromchk
        set(hrunsimul,'enable','on')
        if ishandle(componenth(place).hplot) %suppression de la simul de la composante
            delete(componenth(place).hplot);
            componenth(place).hplot=hinit;
        end
        if ishandle(hplotsimall) %suppression de la simul totale
            delete(hplotsimall)
            hplotsimall=hinit;
            %dispsimulfreq=NaN;
            set(hfitindicator,'visible','off');
            set(hsavesimul,'enable','off');
            setlegend()
            set(hsuprsimul,'enable','off');
            set(hlist,'value',[]);%pas de selection dans la liste
            set(hfreq,'TooltipString','');
            if runsim %=> 1 simul a ete lancee
              set(hcurrentsimul,'enable','on'); 
            end

        end
    end
end
%% AUTRES FONCTIONS

function dispweight() %affichage ou pas des editbox
        componentnumber=numel(componenth);
        if componentnumber>2 %pour affichage pourcentage
            componentnumberincluded=sum([componentdata.include])-1; %componentdata(1) = initialisation
            if componentnumberincluded>1
                for i=2:componentnumber %componentnumber(1)=empty
                    if componentdata(i).include==1
                        set(componenth(i).htextweight,'visible','on');
                        set(componenth(i).heditweight,'visible','on');
                        set(componenth(i).htextpercent,'visible','on');
                    else
                        set(componenth(i).htextweight,'visible','off');
                        set(componenth(i).heditweight,'visible','off');
                        set(componenth(i).htextpercent,'visible','off'); 
                    end
                end
            else
                for i=2:componentnumber %componentnumber(1)=empty
                    set(componenth(i).htextweight,'visible','off');
                    set(componenth(i).heditweight,'visible','off');
                    set(componenth(i).htextpercent,'visible','off'); 
                end
            end
            
        else
            set(componenth(2).htextweight,'visible','off');
            set(componenth(2).heditweight,'visible','off');
            set(componenth(2).htextpercent,'visible','off');            
        end
        
end 

function disppercent() %calcul des pourcentages
    numcomp=numel(componenth);
    numcompincluded=sum([componentdata.include])-1; %componentdata(1) = initialisation
  
    if numcompincluded>1 %au moins 2 composantes
        k=1;
        for i=2:numcomp
            if componentdata(i).include==1
                    %componentdata(i).weightval
                Spercent(k)=struct('h',componenth(i).htextpercent,'weight',componentdata(i).weightval); %structure avec handle et poids
                k=k+1;
                
            end
        end
        weighttot=sum([Spercent.weight]); %<=>100
        for k=1:numel(Spercent)
            set(Spercent(k).h,'string',['(',num2str(100*Spercent(k).weight/weighttot,'%3.1f'),'%)']);
        end
    else
        
    end
 end

function dispgmoy(nieme) % %affichage de gmoyen de la nieme composante
    gmoy=mean(componentdata(nieme).gval);
    set(componenth(nieme).hgmoy,'string',num2str(gmoy,'%6.5f'));%affichage
end

function SysAetNucs(nieme) %gestion des champs A et Nucs de Sys{nieme} pour simul easyspin
    if isfield(Sys{nieme},{'A','Nucs'})
        Sys{nieme}=rmfield(Sys{nieme},{'A','Nucs'}); %par defaut pas de couplage
    end
    data=componentdata(nieme);
    if ~strcmp(data.Istr{1},'') & ~isnan(data.Aval(1,:)) %s'il existe un premier couplage (I et A definis) (& et pas &&)
        if isnan(data.Aval(2,:)) | strcmp(data.Istr{2},'') %sans 2e couplage (| et pas ||)
            Sys{nieme}.Nucs=differentNucs{ismember(differentI,data.Istr{1})}; 
            Sys{nieme}.A=mt2mhz(data.Aval(1,:)); %mt2mhz en  g=2
        else
            Sys{nieme}.Nucs=[differentNucs{ismember(differentI,data.Istr{1})},',',differentNucs{ismember(differentI,data.Istr{2})}];
            Sys{nieme}.A=mt2mhz(data.Aval); %mt2mhz en  g=2
        end
    end
end

function enableA(nieme) %gestion de la propriete 'enable' des A de la nieme composante
    A1handles=get(componenth(nieme).hpanelA(1),'children'); %tous les handles du panel A1 considere
    A1handles(A1handles==componenth(nieme).hpopupI(1))=[]; %suppression du handle de popupI1
    
    A2handles=get(componenth(nieme).hpanelA(2),'children'); %tous les handles du panel A2 considere
    A2handles(A2handles==componenth(nieme).hpopupI(2))=[]; %suppression du handle de popupI2
    if strcmp(componentdata(nieme).Istr{1},'') %pas de couplage hyperfin
       set(A1handles,'enable','off');
       set(componenth(nieme).hpopupI(2),'enable','off');
       set(A2handles,'enable','off');
    else 
       set(A1handles,'enable','on');
       if ~isnan(componentdata(nieme).Aval(1,:))
           set(componenth(nieme).hpopupI(2),'enable','on');
           if strcmp(componentdata(nieme).Istr{2},'') %pas de 2nd couplage hyperfin
                set(A2handles,'enable','off');
           else
                 set(A2handles,'enable','on');
           end
       else
           set(componenth(nieme).hpopupI(2),'enable','off');
           set(A2handles,'enable','off');
       end
    end         
end

function dispAmoy(hAmoy,A) % %affichage de Amoy,sur uicontrol de handle hAmoy
    Amoy=mean(A);
    if ~isnan(Amoy) %s'il existe bien 3 composantes
        Amoy=str2double(num2str(Amoy,'%3.2f')); %correspondance exacte entre affichage et valeur en memoire
        set(hAmoy,'string',num2str(Amoy,'%3.2f')); %affichage sur handle qui va bien
    else
        set(hAmoy,'string',''); %affichage sur handle qui va bien
    end   
end



function closeSimLabelX(hobject,~) %fermeture fenetre de composante
   if get(hrealtime,'value')==0
     place=find([componenth.hfig]==hobject); %indice de la composante consideree dans la structure des handles componenth
     figname=get(hobject,'name');
     fignumber=str2double(figname(10:end));
%     if componentdata(place).include==1 && ishandle(hplotsimall) %si derniere composante vient d'etre fermee et que simul affichee
     if componentdata(place).include==1  %si derniere composante vient d'etre fermee et que simul affichee
        if ishandle(hplotsimall)
            delete(hplotsimall);
            hplotsimall=hinit;
             set(hfitindicator,'visible','off');
            if ~ishandle(hspecexp) %pas de spectre exp => reinit des abscisses
                set(hspecaxes,'xlim',[0 1],'ylim',[0 1],'Xtick',NaN); %reinitialisation si pas de simul affichee
            end

        end
         if ishandle(componenth(place).hplot) %si simul de cette composante est affichee=> l'effacer
            delete(componenth(place).hplot)
            componenth(place).hplot=hinit;
         end
         
         set(hsavesimul,'enable','off');
         set(hsuprsimul,'enable','off');
         %set(hcurrentsimul,'enable','off');
         %hplotsimall=hinit;
         set(hfreq,'visible','off');
         set(hlist,'value',[]); %pas de selection dans la listbox
         set(hfreq,'TooltipString','');
     end
     
     poscomponentfig(fignumber,:)=get(hobject,'pos'); %mise en memoire du vecteur position de la figure
     delete(hobject)
     componenth(place)=[]; %supression des handles de la composante dont la fenetre vient d'etre fermee
     componentdata(place)=[]; %supression des donnees de la composante dont la fenetre vient d'etre fermee
     Sys(place)=[]; %supression des donnees de la composante dont la fenetre vient d'etre fermee
     componentnumber=numel(componenth);
     
         
     if componentnumber==2 %componenth(1)=empty <=> plus qu'une seule fenetre affichee
         set(componenth(2).htextweight,'visible','off');
         set(componenth(2).heditweight,'visible','off');
         set(componenth(2).htextpercent,'visible','off');
         %set(componenth(2).htextpercent,'string',componentdata(i).textpercent);
     elseif componentnumber>2
         disppercent()
     else %componentnumber==1 ie plus de fenetre affichee
         dispsimulfreq=NaN;
         if isempty(get(hspecaxes,'children'))%~ishandle(hspecexp)
            set(hspecaxes,'xlim',[0 1],'ylim',[0 1],'Xtick',NaN); %reinitialisation si pas de simul affichee
         end
         setlegend()
     end
%      if get(hrealtime,'value')==1
%          if ~reloading
%         runsimul2();%<=> si modif des include
%          end
%      else
        setlegend()
   else
        uiwait(msgbox({'WARNING:   "Real time" mode selected...';'';'Quit "Real time" first...'},...
            'SimLabel_WARNING','Warn','modal'));
   end
end
       
function Exp=Expgeneration() %generation de la  structure Exp  pour 
    % simulation des spectres avec easyspinfunc (easyspin)
   
        %Exp=struct('mwFreq',9.8,'Range',[300 400]); 
    if ishandle(hspecexp) %si spectre exp: frequence=freq exp
        freq=expfreq;
        str2disp=['Simulation frequency: ',num2str(freq),' GHz (from exp.)'];
    elseif ~isnan(dispsimulfreq) %si simul seule: frequence=frequence de la simul
        freq=dispsimulfreq;
        str2disp=['Simulation frequency: ',num2str(freq),' GHz (from prev. simul.)'];
    else %freq par defaut
        %freq=9.8;%GHz
        prompt = 'Enter frequency (GHz):';
        dlg_title = 'SimLabel_setFrequency';
        def={'9.8'}; %valeur par defaut
        freqtxt=inputdlg(prompt,dlg_title,1,def);
        freq=str2double(freqtxt);
        
        if isempty(freq)
            freq=NaN;
        end
            
        str2disp=['Simulation frequency: ',num2str(freq),' GHz (from user)'];
    end
    %freq
    if ~isnan(freq)
        set(hfreq,'string',str2disp,'visible','on');
    end
    RangeB=get(hspecaxes,'xlim');
    if isequal(RangeB,[0 1]) %valeur par defaut  si aucun spectre experimental n'est ou n'a ete affiche
         RangeB=defaultRangeB(freq);
    end
    
    Exp=struct('mwFreq',freq,'Range',RangeB); %expfreq en GHz

end

function RangeB=defaultRangeB(freq)
    RangeB=floor(1e3*planck*freq*1e9/bmagn./defaultRangeg); %mT
end

function [y_,h]=mimilrescale(B,y,scalingfactor) %scaling
   switch get(get(hnormpanel,'SelectedObject'),'Tag')
       
       case 'intensity' %normalisation/Intensite
            h=1/abs(trapz(B,cumtrapz(B,y)));
            
       case 'minmax'
            %normalisation min max
            if max(y)~=min(y)
             h=1/(max(y)-min(y));
            else
                h=1;
            end
           
%        case 'proportion'
%             yexp=get(hspecexp,'ydata');
%             if max(yexp)~=min(yexp)
%              h=weight/(max(yexp)-min(yexp));
%             else
%                 h=weight;
%             end
        
   end
   
    h=h*scalingfactor;
    y_=y*h;
end

function setlegend() % supprime la veille legende, affiche la nouvelle legende sur le graphe 
    if ishandle(hlegend)
        delete(hlegend);
        hlegend=hinit;
    end
    i2bevisible=find([componentdata.status]); % tenir compte du 1er element car componentdata(1).status=0
    handlevec=[];
     legendtxt=[];

   if ishandle(hspecexp) && ishandle(hplotsimall)
        handlevec(1:2)=[hspecexp hplotsimall];
        legendtxt={'exp.','simul.'};

   elseif ishandle(hplotsimall) 
        handlevec=hplotsimall;
        legendtxt={'simul.'};
   elseif ishandle(hspecexp)
        handlevec=hspecexp;
        legendtxt={'exp.'};
   end
   nbspecdisp=numel(handlevec);
       if ~isempty(i2bevisible)
               classhinit=class(hinit);
               switch classhinit
                   case 'double' %version matlab ou handle=double
                       for k=1:numel(i2bevisible)
                       if ishandle(componenth(i2bevisible(k)).hplot) %la composante peut etre "visible" mais plot efface 
                          handlevec(k+nbspecdisp)=componenth(i2bevisible(k)).hplot;
                          legendtxt{k+nbspecdisp}=componentdata(i2bevisible(k)).name;
                       else
                           componentdata(i2bevisible(k)).status=0;
                           set(componenth(i2bevisible(k)).hvisible,'value',0);
                           set(componenth(i2bevisible(k)).hhide,'value',1);
                       end
                       end
                   case 'struct' %version matlab ou handle=struct
                       for k=1:numel(i2bevisible)
                       if isequal(componenth(i2bevisible(k)).hplot,hinit) %la composante peut etre "visible" mais plot efface 
                          handlevec(k+nbspecdisp)=componenth(i2bevisible(k)).hplot;
                          legendtxt{k+nbspecdisp}=componentdata(i2bevisible(k)).name;
                       else
                           componentdata(i2bevisible(k)).status=0;
                           set(componenth(i2bevisible(k)).hvisible,'value',0);
                           set(componenth(i2bevisible(k)).hhide,'value',1);
                       end
                       end
                end
       end

       if ~isempty(handlevec)
            hlegend=legend(hspecaxes,handlevec,legendtxt);
            set(hlegend,'Interpreter','none');
       end;
end


function setlegend2(index) % affiche la nouvelle legende sur le graphe en mode comparaison de simuls
                                %index=vecteur contenant les indices de
                                %listfile (=ceux de hprevsimplot)
    
    handlevec=[];
    legendtxt=[];
    if ishandle(hspecexp) 
        handlevec=hspecexp;
        legendtxt={'exp.'};
       
%         handlevec
%         legendtxt
   end
       nbspecdisp=numel(handlevec);
       for k=1:numel(index)
               handlevec(k+nbspecdisp)=hprevsimplot(k);
               legendtxt{k+nbspecdisp}=listfile{index(k)};
       end

       hlegend=legend(hspecaxes,handlevec,legendtxt);
       set(hlegend,'Interpreter','none');

end

function setlegend3(index) % affiche la nouvelle legende sur le graphe en mode comparaison de spec exp
                                %index=vecteur contenant les indices de
                                %listfileexp (=ceux de hprevsimplot)
    
    handlevec=[];
    legendtxt=[];

       nbspecdisp=numel(handlevec);
       for k=1:numel(index)
               handlevec(k+nbspecdisp)=hprevsimplot(k);
               legendtxt{k+nbspecdisp}=listfileexp{index(k)};
       end

       hlegend=legend(hspecaxes,handlevec,legendtxt);
       set(hlegend,'Interpreter','none');

end


function plotspecexp(deltaB)% affiche spectre experimental y en tenant compte du decalage en
    % champ(deltaB=reel-lu)
    if ishandle(hspecexp)
        delete(hspecexp)
    end
    Bexp=Bexpinit+deltaB; %champ decale en mT
    hspecexp=plot(hspecaxes,Bexp,specexp,'k','linewidth',2);hold(hspecaxes,'on');
    set(hspecexp, 'ButtonDownFcn',@MouseleftclickexpCllbck);
    
    set(hspecaxes,'Ytick',NaN,'XTickMode','auto');
    xlabel(hspecaxes,'Magnetic Field [mT]');
    fullscale(Bexp,specexp);
    setlegend()
    
    %reload?

end

function MouseleftclickexpCllbck(~,~)
    if ishandle(hpoint)
        delete(hpoint)
    end
     p = get(hspecaxes,'CurrentPoint');
     p = p(1,1:2);
     str2disp=[num2str(p(1),'%3.2f'),'mT, ',num2str(p(2),'%3.3f'),', g=',num2str(planck*expfreq*1e9/bmagn/p(1)*1e3,'%6.5f')];
     set(hcursorinfo,'string',str2disp,'visible','on','foregroundcolor','k');
     hpoint=plot(p(1),p(2),'ok','markersize',6,'markerfacecolor','k');
end

function MouseleftclicksimCllbck(~,~)
    if ishandle(hpoint)
        delete(hpoint)
    end
     p = get(hspecaxes,'CurrentPoint');
     p = p(1,1:2);
     str2disp=[num2str(p(1),'%3.2f'),'mT, ',num2str(p(2),'%3.3f'),', g=',num2str(planck*dispsimulfreq*1e9/bmagn/p(1)*1e3,'%6.5f')];
     set(hcursorinfo,'string',str2disp,'visible','on','foregroundcolor','m');
     hpoint=plot(p(1),p(2),'om','markersize',6,'markerfacecolor','m');
end

function MouseleftclickaxeCllbck(~,~)
    set(hcursorinfo,'string','','visible','off');
    if ishandle(hpoint)
        delete(hpoint)
    end
end
    
function fullscale(x,y)
    maxy=max(y);
    miny=min(y);
    h=maxy-miny;
%     if (miny-fsfactor*h)==0 && (maxy+fsfactor*h)==0 
        axis(hspecaxes,[x(1) x(end) miny-fsfactor*h maxy+fsfactor*h]);
%     else %pas de resonance dans la plage de champ
%         set(hspecaxes,'xlim',[0 1],'ylim',[0 1],'Xtick',NaN); %reinitialisation si pas de simul affichee
%     end
end       

%% functions gestion sauvegarde ...
function add2list(file,path)
    set(hlist,'value',[]);
    rang2test=find(ismember(listfile,file));
    rang=0;
    if isempty(rang2test) % si ce nom de fichier n'est pas deja affiche
        rang=numel(listfile)+1;
        listfile{rang}=file;
        listpath{rang}=path;
        list2disp{rang}=[num2str(rang),': ',file];
    else
          for k=1:numel(rang2test)
             if strcmp(path,listpath{rang2test(k)}) %sinon si meme chemin
                 rang=rang2test(k);
             end
          end
          if rang==0 %si chemin different
            rang=numel(listfile)+1;
            listfile{rang}=file;
            listpath{rang}=path;
            list2disp{rang}=[num2str(rang),': ',file];
          end
    end

    set(hlist,'string',list2disp,'value',rang);
end

function add2listexp(file,path)
    set(hlistexp,'value',[]);
    rang2test=find(ismember(listfileexp,file));
    rang=0;
    if isempty(rang2test) % si ce nom de fichier n'est pas deja affiche
        rang=numel(listfileexp)+1;
        listfileexp{rang}=file;
        listpathexp{rang}=path;
        list2dispexp{rang}=[num2str(rang),': ',file];
    else
          for k=1:numel(rang2test)
             if strcmp(path,listpathexp{rang2test(k)}) %sinon si meme chemin
                 rang=rang2test(k);
             end
          end
          if rang==0 %si chemin different
            rang=numel(listfileexp)+1;
            listfileexp{rang}=file;
            listpathexp{rang}=path;
            list2dispexp{rang}=[num2str(rang),': ',file];
          end
    end
    set(hlistexp,'string',list2dispexp,'value',rang);

end

function loadanddisp(prevdata) %charge et affiche simul anterieure sauvee
       %%% champs attendus
%          waitedfields={'Exp','Syssimul','datasimul'};
%          if isfield(prevdata,waitedfields)
            %numel([prevdata.datasimul])
            %simul type
            %save('test.mat','prevdata')
            set(hfitindicator,'visible','off');
            
            type=prevdata(1).datasimul.type;
            componentdata(1).type=type;
            set(hsimultype,'value',find(ismember(simultype,type)));
            switch type
             case 'Slow Motion'
                 easyspinfunc=@chili;
                 timeenable='on';
                 lwmax=0.3;
                 minsteplw=0.01/lwmax; %facteur d'increment min 
                 maxsteplw=0.05/lwmax; %facteur d'increment max
             case 'Frozen Solution'
                 easyspinfunc=@pepper;
                 timeenable='off';
                 lwmax=2;
                 minsteplw=0.05/lwmax; %facteur d'increment min 
                 maxsteplw=0.2/lwmax; %facteur d'increment max
            end
    
             nbcomponent2disp=numel(prevdata.datasimul); %nb de composantes a afficher
             %handles des figures SimLabel_X encore affichees
             allfigname=get(findobj('type','figure'),'name'); %cellarray avec noms des figures ouvertes
             if ishandle(hmt2mhz) %si fenetre conversion affichee
                 [~,index]=ismember('SimLabel_conv',allfigname);
                 allfigname(index)=[];
             end
            if ~isempty(allfigname)
                if ~ischar(allfigname) %Si 1! fenetre (SimLabel_main), fignumber=1
                  pos2keep= find(strncmp(allfigname,'SimLabel',8)); %compare les 8 premiers caracteres peutetre existe-t-il d'autres fenetres ouvertes
                  allfigname2=cell(1,numel(pos2keep));
                  for k=1:numel(pos2keep)
                      allfigname2{k}=allfigname{pos2keep(k)};
                  end
                  allfigname2=sort(allfigname2);% +petit au + grand ('SimLabel_main' a la fin)
                  oldhfig=-ones(1,numel(allfigname2)-1); %init
                  for i=1:numel(allfigname2)-1
                      oldhfig(i)=findobj('type','figure','-and','name',allfigname2{i});
                  end

                else
                    oldhfig=[];
                end
            end
             %oldhfig=[componenth.hfig] %handles des figures SimLabel_X encore affichees (1er element de componenth: initialisation)
             oldnbcomponent=numel(oldhfig);%-1;%nb de composantes encore affichees
%             hfig2del=[componenth.hfig]; %handles des figures SimLabel_X a supprimer (1er element de componenth: initialisation)
%              if numel(hfig2del)>=2 %s'il y a des fenetres a fermer
%                  for k=hfig2del(2:end)
%                     closeSimLabelX(k);
%                  end;
%              end

             diffnb=nbcomponent2disp-oldnbcomponent; %nb de composantes a afficher - nb de composante affichees
             if diffnb>0
                if versionyear>=2014
                        hfigtemp=gobjects(1,diffnb); %handle=structure
                else
                        hfigtemp=-1*ones(1,diffnb); %init (-1 ~= handle); %handle=double
                end
 

                    for k=1:diffnb
                        hfigtemp(k)=opencomponentwin; % ouverture d'une nouvelle fenetre de composante SimLabel_X
                        place=find([componenth.hfig]==hfigtemp(k)); %indice de la composante consideree dans la structure des handles componenth
                        componentdata(place)=componentdata(1); %init
                        Sys{place}=Sys{1}; %init
                    end
                   % hfigtemp
                   % if numel(oldhfig)==1 %pas de fenetres prealablement ouvertes
                    %    newhfig=hfigtemp;
                    %else
                    %    newhfig=[oldhfig(2:end),hfigtemp];
                    %end
                    newhfig=[oldhfig,hfigtemp];
             elseif diffnb<0
                 newhfig=oldhfig(1:nbcomponent2disp);
                 for h=oldhfig(nbcomponent2disp+1:end)
                     closeSimLabelX(h);
                 end;
             else
                 newhfig=oldhfig(1:end);
             end
             

             
             
             
             for h=[componenth.hplot]
                 if ishandle(h)
                    set(h,'visible','off');% efface composantes affichees 
                 end
             end
             

       
             %newhfig
             for k=1:nbcomponent2disp %affichage des fenetres et remplissage
                place=find([componenth.hfig]==newhfig(k)); %indice de la composante consideree dans la structure des handles componenth
                componentdata(place)=prevdata.datasimul(k);
                Sys(place)=prevdata.Syssimul(k);
                dispcomponent(place); % remplissage de la fenetre avec donnees correspondantes
                componenth(place).hplot=hinit;
                set(componenth(place).hslidlorentzian,'Min',lwmin,'Max',lwmax,'SliderStep',[minsteplw maxsteplw]);
                set(componenth(place).hslidgaussian,'Min',lwmin,'Max',lwmax,'SliderStep',[minsteplw maxsteplw]);

             end
             Exp=prevdata.Exp;
             dispsimulfreq=prevdata.Exp.mwFreq;  %frequence de la simulation affichee
             plotsimul(prevdata);
             
             %Exp=prevdata.Exp;
             if strcmp(get(hlist,'enable'),'off');
             set(hlist,'enable','on');
             set(hsuprfromlist,'enable','on');
             set(hexpfromlist,'enable','on');
             set(hsavesimul,'enable','off');
             end
             %dispsimulfreq=prevdata.Exp.mwFreq;  %frequence de la simulation affichee
             if get(hrealtime,'value')==1
                testwarning();%teste plage de champs et frequences
             end
             set(hsuprsimul,'enable','on');
             if ishandle(hspecexp)
                dispfitindicator() %affichage de l'indicateur de fit si bonnes plages de champ et bonnes frequences
             end

            for k=2:numel(componenth)
                    hpaneltime=get(componenth(k).hedittime,'parent');
                    htimecontrol=get(hpaneltime,'children');
                    set(htimecontrol,'enable',timeenable);
                    figure(componenth(k).hfig);%au premier plan...
            end
            
            figure(hSimLabelmain);%au premier plan...

% 
%          else
%              file=char(listfile(get(hlist,'value')));
%              
%              
%              %disp(['The file ',file,' is not a previous simulation of SimLabel.']);
%             uiwait(msgbox({'WARNING:   Wrong file...';'';['The file ',file,' is not a previous simulation of SimLabel.']},...
%                  'SimLabel_WARNING','Warn','modal'));
%              %suprfromlist()
%          end
end

function plotsimul(prevdata)
        nbcomponent=numel(prevdata.datasimul);
        if ishandle(hplotsimall)
            delete(hplotsimall)
        end

        for k=1:nbcomponent
            compsimul(k,:)=prevdata.datasimul(k).specsimul;
            if ~prevdata.datasimul(k).include
                compsimul(k,:)=deal(0);
            end
        end
%         [dispspecsimul,h,delta]=mimilrescale(sum(compsimul,1));% somme des simul de composantes, recalee

        dispspecsimul=sum(compsimul,1);% somme des simul de composantes, 
        Bsimul=linspace(prevdata.Exp.Range(1),prevdata.Exp.Range(2),numel(dispspecsimul)); %champ magnetique de la simul
        [dispspecsimul,scalefact]=mimilrescale(Bsimul,dispspecsimul,str2double(get(hscalingval,'string')));% somme des simul de composantes, recalee
        
        %affichage simul anterieure
        hplotsimall=plot(hspecaxes,Bsimul,dispspecsimul,'m','linewidth',2);hold(hspecaxes,'on');
        set(hplotsimall, 'ButtonDownFcn',@MouseleftclicksimCllbck);
        set(hspecaxes,'Ytick',NaN,'XTickMode','auto');
        xlabel(hspecaxes,'Magnetic Field [mT]');
        if ~ishandle(hspecexp)
            fullscale(Bsimul,dispspecsimul);
        else
            fullscale(Bexp,specexp);
            uistack(hspecexp,'top'); %spectre exp au 1er plan
        end
        setlegend();
        %dispsimulfreq=prevdata.Exp.mwFreq;
        

        %if dispsimulfreq==9.8 %affichage de la frquence de calcul
        %    str2disp=['Simulation frequency: ',num2str(prevdata.Exp.mwFreq),' GHz (default)'];
        %else
            str2disp=['Simulation frequency: ',num2str(prevdata.Exp.mwFreq),' GHz (from exp. or prev. sim.)'];
        %end
        
        set(hfreq,'string',str2disp,'visible','on');
        %%%%
end

function [B,y]=prevsimul(prevdata) %retourne champ B et spectre simule de simul sauvee
        nbcomponent=numel(prevdata.datasimul);
        for k=1:nbcomponent
            compsimul(k,:)=prevdata.datasimul(k).specsimul;
        end
        y=sum(compsimul,1);% somme des simul de composantes       
        B=linspace(prevdata.Exp.Range(1),prevdata.Exp.Range(2),numel(y)); %champ magnetique de la simul
        y=mimilrescale(B,y,1);%,prevdata.datasimul(1).weightval);% somme des simul de composantes, recalee
        set(hscalingval,'string',num2str(1,'%3.2f'),'backgroundcolor','w');
end

function warnstatus=testwarning() %teste plage de champs et frequences
    warnstatus=0;
    epsB=1e-13;
     if dispsimulfreq~=expfreq && ~isnan(expfreq) && ~isequal([Bsimul(1) Bsimul(end)],get(hspecaxes,'xlim'))
             uiwait(msgbox({'WARNING:   Field Ranges and Frequencies conflicts...';'';'You should first perform global simulation with "Run. Simul."...'},...
                 'SimLabel_WARNING','Warn','modal'));
             warnstatus=1;
     else
         if dispsimulfreq~=expfreq && ~isnan(expfreq) % si frequence exp et de la simul affichee sont differentes
             uiwait(msgbox({'WARNING:   Frequencies conflict...';'';'You should first perform global simulation with "Run. Simul."...'},...
                 'SimLabel_WARNING','Warn','modal'));
             warnstatus=1;
         end
         Bdiff=abs([Bsimul(1) Bsimul(end)]-get(hspecaxes,'xlim'));
         if Bdiff(1)>=epsB || Bdiff(2)>=epsB
             %~isequal([Bsimul(1) Bsimul(end)],get(hspecaxes,'xlim')) %si plages de champs affichee et de la simul differentes
             uiwait(msgbox({'WARNING:   Field Ranges conflict...';'';'You should first perform global simulation with "Run. Simul."...'},...
                 'SimLabel_WARNING','Warn','modal'));
             warnstatus=1;
         end
     end
end

function testwarning4deltaB() %test les deux frequences lors d'un deltaB
    if ishandle(hplotsimall)
        simfreq=dispsimulfreq;
    else
        simfreq=NaN;
    end
    if simfreq~=expfreq && ~isnan(simfreq)% si frequence exp et de la simul affichee sont differentes
        uiwait(msgbox({'WARNING:   Frequencies conflict...';'';'You should first perform global simulation with "Run. Simul."...'},...
              'SimLabel_WARNING','Warn','modal'));
    end
end

function savepar(fullname,rang) %param de la simul dans fichier par 
    datastruct=load(fullfile(listpath{rang},listfile{rang}),'-mat'); 
    fid = fopen([fullname(1:end-4),'.par'],'w');
    if ~isempty(rang)
        fprintf(fid,'%s\n',['path: ',listpath{rang}]);
        fprintf(fid,'%s\n',' ');
        fprintf(fid,'%s\n',['simul. name: ',listfile{rang}(1:end-4)]);
        fprintf(fid,'%s\n',' ');
        fprintf(fid,'%s\n',['simul. type: ',simultype{get(hsimultype,'value')}]);
        fprintf(fid,'%s\n',' ');
    end
    if ~isempty(expspecf)
        fprintf(fid,'%s\n',['exp. spectrum from ',expspecf]);
        fprintf(fid,'%s\n',' ');
    end
    nbcomp=numel(datastruct.datasimul);
    for k=1:nbcomp
        fprintf(fid,'%s\n',datastruct.datasimul(k).name);
        tempstruct=datastruct.Syssimul{k};
        if strcmp(timeenable,'off') %frozen solution
           tempstruct=rmfield(tempstruct,'logtcorr');
        end
        parametres=evalc('tempstruct');
        fprintf(fid,'%s\n',parametres(:,16:end)); %resultat sans 'ans ='
        %fprintf(fid,'%s\n','');
        parametres=[];
    end
    fclose(fid);  
end 

function dispfitindicator() %affichage de l'indicateur de fit si bonnes plages de champ et bonnes frequences (hspecexp est un handle)
    % indicateur inspire d'un chi 2. Calcul sur les spectres absorption
    % pour ponderer le tout   
    epsB=1e-13;
         Bdiff=abs([Bsimul(1) Bsimul(end)]-get(hspecaxes,'xlim'));
         testBsweep= (Bdiff(1)<=epsB || Bdiff(2)<=epsB); %logical: 1 si plages equivalentes a 1e-13 pres.
         if dispsimulfreq==expfreq  && testBsweep %isequal([Bsimul(1) Bsimul(end)],get(hspecaxes,'xlim'))
             intspecexp=cumtrapz(get(hspecexp,'xdata'),specexp'); %spectre absorption exp
             intsimul=cumtrapz(Bsimul,dispspecsimul); %spectre absorption simul
             Bcalcfitext=[max([Bsimul(1),Bexp(1)]),min([Bsimul(end),Bexp(end)])]; %extrema plage pour calculer fitindicator
             Bcalcfit=linspace(Bcalcfitext(1),Bcalcfitext(2),1000); %plage pour calculer fitindicator (1000 pts)
            %alignement des grilles!
            intspecexp_=interp1(Bexp,intspecexp,Bcalcfit,'spline');
            intsimul_=interp1(Bsimul,intsimul,Bcalcfit,'spline');
            specexp_=interp1(Bexp,specexp',Bcalcfit,'spline');
            dispspecsimul_=interp1(Bsimul,dispspecsimul,Bcalcfit,'spline');

            fitindicatorabs=sum((intspecexp_-intsimul_).^2)/sum(intspecexp_.^2); %indicateur de fit (pas vraiment chi 2)
            fitindicatordataasis=sum((specexp_-dispspecsimul_).^2)/sum(specexp_.^2); %indicateur de fit (pas vraiment chi 2)

            set(hfitindicator,'string',['fit=',num2str(fitindicatordataasis,'%4.3f'),'/',num2str(fitindicatorabs,'%4.3f')],'visible','on');
         end
end

%% ESFIT


function openesfit(~,~)
    selectedrank=get(hlist,'value');
%     if isempty(selectedrank) || isempty(listfile)
%         uiwait(msgbox('WARNING:   No saved simulation selected...','SimLabel_WARNING','Warn','modal'));
%         %warningstatus=1; 
%     end
    epsB=1e-13;
    if ~isempty(selectedrank) && ishandle(hspecexp) && ~isempty(listfile) 
        if abs(Bsimul(1)-Bexp(1))>epsB  || abs(Bsimul(end)-Bexp(end))>epsB
            uiwait(msgbox('WARNING:   Field range of the simulation too large...','SimLabel_WARNING','Warn','modal'));
            warningstatus=1; 
        else
            warningstatus=testwarning(); %si warningstatus=0 pas de warning affiche
        end
    if warningstatus==0 
        %supression des fits precedents non sauves
        fitname=evalin('base','who(''-regexp'', ''fit*'')');
        if ~isempty(fitname)
            for k=1:numel(fitname)
                evalin('base',['clear ',fitname{k}])
            end
        end
        
        simulfile4esfit=fullfile(listpath{selectedrank},listfile{selectedrank}); %simulation manuelle utilisee pour lancer esfit

        alldata={}; %cell array contenant donnees affichees sur fenetre avant esfit (init)

        i2beincluded=find([componentdata.include]); % pas tenir compte du 1er element de ce tableau = 1 =>componentdata d'initialisation
        Sysfit=[];%initialisation du tableau de structures contenant les composantes pour le fit 
        for k=2:numel(i2beincluded) %generation de la structure Sys pour fit
                Sysfit{k-1}=Sys{i2beincluded(k)};
                componentdatafit(k-1)=componentdata(i2beincluded(k));
        end
        nbcmp2fit=numel(Sysfit);
        
        %%%%%  Recherche de correlation(s) possibles(s) (ie meme g,lw,A,Nucs) si plus d'une composante  %%%%%
        cancellation=0; %abandon quand correlation
        correlinfo=''; %string pour preciser l'existence ou non de correlation
        correltab=1:nbcmp2fit; %init: pas de correlation, correltab=[1 2 3 ...]
                       % si especes 1 et 2 correlees, correltab=[1 1 3 ...]
                        % si especes 2 et 3 correlees, correltab=[1 2 2 ...]
        testcorrel=zeros(nbcmp2fit);%init de la matrice des correlations
                
        if nbcmp2fit>1 
            Systest=Sysfit; %structure Sys avec les champs d'interet pour test
            for k=1:nbcmp2fit
                Systest{k}=rmfield(Systest{k},{'logtcorr','weight'}); %plus que g,lw,A,Nucs dans Systest
            end
            Systest=[Systest{:}];%structure array plutot que cell array 

            for k=1:nbcmp2fit
               for n=1:nbcmp2fit
                   testcorrel(k,n)=isequal(Systest(k),Systest(n));
               end
            end
        end


        if ~isequal(testcorrel,eye(nbcmp2fit)) && nbcmp2fit>1 %testcorrel n'est pas la matrice identite: correlation(s) possible(s) si plusieurs composantes 
            correltemp=correltab;
            qst=''; %pour affichage dans boite de dialogue
            nbcorrel=0;
            for k=1:nbcmp2fit
                correltemp(k)=find(testcorrel(:,k),1,'first');
            end
            for k=1:nbcmp2fit
                if ~isequal(correltemp(k),k) %correltemp(2)=1 :correlation possible entre compste 1 et 2
                   qst=[qst,'''',componentdata(i2beincluded(correltemp(k)+1)).name,''' and ''',componentdata(i2beincluded(k+1)).name,''' are similar (same g, lw and A values).\n'];
                    nbcorrel=nbcorrel+1;
                    correlinfo{nbcorrel}=['C',num2str(i2beincluded(correltemp(k))),' and C',num2str(i2beincluded(k)),' are correlated.'];
                end
            end
            qst=[qst,' \nDo you want their g, lw and A values to be fitted being correlated?'];
            titleqst='to fitting mode: available correlation(s)...';
            choice = questdlg(sprintf(qst),titleqst,'Yes','No','Cancel','No');          
            switch choice
                case 'Cancel'
                    set(hcomponentletter,'string','','visible','off');
                    componentdatafit=componentdatainit;%composantes utilisees pour esfit (conservation de l'info d'axialite)
                    clc
                    cancellation=1; %abandon quand correlation
                    correltab=[];
                case 'Yes'
                    correltab=correltemp;
%                     if nbcorrel>1
%                         correlinfo='Correlations are considered...';
%                     else
%                         correlinfo='A correlation is considered...';
%                     end
                case 'No'
                    %correltab=correltab;
                    correlinfo='No correlation is considered...';
            end
        end

        
     if ~cancellation   % pas d'abandon quand correlation (si correlation possible)     
            line=1;%numero de la ligne courante de alldata
            for k=1:numel(Sysfit) %generation des donnees de la table pour esfit (chaque valeur par defaut = 10% des chifres apres la virgule (?))
                % + generation du cell array alldata pour choix des donnees variables
                Varytemp=Sysfit{k};
                names=fieldnames(Sysfit{k}); %liste des noms de champ de la composante k
                 strk=num2str(k);
                for n=1:numel(names)
                    %fieldval=getfield(Sysfit{k},names{n});%valeur du champ considere
                    switch names{n}
                        case 'g'
                            if k==correltab(k)
                               Varytemp.g=ones(1,3)*1e-3;%1e-5*gmax/2;
                               iperp=componentdatafit(k).axialcombinationg;
                               if sum(isnan(iperp))==0 % g axial (g non axial=[NaN NaN])
                                   iperp=componentdatafit(k).axialcombinationg;
                                   ipar=setdiff(1:3,iperp);
                                   alldata(line,:)={false,['gperp_C',strk],num2str(Sysfit{k}.g(iperp(1)),'%6.5f'),num2str(Varytemp.g(iperp(1)),'%6.5f')};line=line+1;
                                   alldata(line,:)={false,['gpar_C',strk],num2str(Sysfit{k}.g(ipar),'%6.5f'),num2str(Varytemp.g(ipar),'%6.5f')};line=line+1;
                               else
                                   alldata(line,:)={false,['g_C',strk,'(1)'],num2str(Sysfit{k}.g(1),'%6.5f'),num2str(Varytemp.g(1),'%6.5f')};line=line+1;
                                   alldata(line,:)={false,['g_C',strk,'(2)'],num2str(Sysfit{k}.g(2),'%6.5f'),num2str(Varytemp.g(2),'%6.5f')};line=line+1;
                                   alldata(line,:)={false,['g_C',strk,'(3)'],num2str(Sysfit{k}.g(3),'%6.5f'),num2str(Varytemp.g(3),'%6.5f')};line=line+1;
                               end
                            end
                        case 'lw'
                            if k==correltab(k)
                               Varytemp.lw=0.5*Sysfit{k}.lw;
                               alldata(line,:)={false,['lw_C',strk,'(1)'],num2str(Sysfit{k}.lw(1),'%3.2f'),num2str(Varytemp.lw(1),'%3.2f')};line=line+1;
                               alldata(line,:)={false,['lw_C',strk,'(2)'],num2str(Sysfit{k}.lw(2),'%3.2f'),num2str(Varytemp.lw(2),'%3.2f')};line=line+1;
                            end
                        case 'logtcorr'
                            if strcmp(timeenable,'on') %slow motion
                                Varytemp.logtcorr=1;
                                alldata(line,:)={false,['logtcorr_C',strk],num2str(Sysfit{k}.logtcorr,'%5.3f'),num2str(Varytemp.logtcorr,'%5.3f')};line=line+1;
                            end
                        case 'weight'
                            if numel(i2beincluded)>2 %si plusieurs composantes
                                Varytemp.weight=0.9*Sysfit{k}.weight;
                                alldata(line,:)={false,['weight_C',strk],num2str(Sysfit{k}.weight,'%3.2f'),num2str(Varytemp.weight,'%3.2f')};line=line+1;
    %                         else
    %                             Sysfit{k}=rmfield(Sysfit{k},'weight');
                            end
    %                     case 'Nucs'
    %                         Varytemp=rmfield(Varytemp,'Nucs');
                        case 'A'
                            if k==correltab(k)
                                Varytemp.A=0.5*Sysfit{k}.A;
                                if numel(Varytemp.A)==6 %2 couplages
                                    iperp=componentdatafit(k).axialcombinationA(1,:);
                                    if sum(isnan(iperp))==0 % A1 axial
                                        ipar=setdiff(1:3,iperp);
                                        alldata(line,:)={false,['A1perp_C',strk],num2str(Sysfit{k}.A(1,iperp(1)),'%3.1f'),num2str(Varytemp.A(1,iperp(1)),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A1par_C',strk],num2str(Sysfit{k}.A(1,ipar),'%3.1f'),num2str(Varytemp.A(1,ipar),'%3.1f')};line=line+1;
        %                                 Sysfit{k}.A1perp=Sysfit{k}.A(1,iperp(1)); %nouveaux champs dans Sysfit
        %                                 Sysfit{k}.A1par=Sysfit{k}.A(1,ipar); 
                                    else
                                        alldata(line,:)={false,['A1_C',strk,'(1)'],num2str(Sysfit{k}.A(1,1),'%3.1f'),num2str(Varytemp.A(1,1),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A1_C',strk,'(2)'],num2str(Sysfit{k}.A(1,2),'%3.1f'),num2str(Varytemp.A(1,2),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A1_C',strk,'(3)'],num2str(Sysfit{k}.A(1,3),'%3.1f'),num2str(Varytemp.A(1,3),'%3.1f')};line=line+1;
        %                                 Sysfit{k}.A1=Sysfit{k}.A(1,:); %nouveaux champs dans Sysfit
                                    end
                                    iperp=componentdatafit(k).axialcombinationA(2,:);
                                    if sum(isnan(iperp))==0 % A2 axial
                                        ipar=setdiff(1:3,iperp);
                                        alldata(line,:)={false,['A2perp_C',strk],num2str(Sysfit{k}.A(2,iperp(1)),'%3.1f'),num2str(Varytemp.A(2,iperp(1)),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A2par_C',strk],num2str(Sysfit{k}.A(2,ipar),'%3.1f'),num2str(Varytemp.A(2,ipar),'%3.1f')};line=line+1;
                                    else
                                        alldata(line,:)={false,['A2_C',strk,'(1)'],num2str(Sysfit{k}.A(2,1),'%3.1f'),num2str(Varytemp.A(2,1),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A2_C',strk,'(2)'],num2str(Sysfit{k}.A(2,2),'%3.1f'),num2str(Varytemp.A(2,2),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A2_C',strk,'(3)'],num2str(Sysfit{k}.A(2,3),'%3.1f'),num2str(Varytemp.A(2,3),'%3.1f')};line=line+1;
                                    end
                                else %numel(Varytemp.A)=3 ie 1! couplage hyperfin
                                    iperp=componentdatafit(k).axialcombinationA(1,:);
                                    if sum(isnan(iperp))==0 % A axial
                                        ipar=setdiff(1:3,iperp);
                                        alldata(line,:)={false,['A1perp_C',strk],num2str(Sysfit{k}.A(iperp(1)),'%3.1f'),num2str(Varytemp.A(iperp(1)),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A1par_C',strk],num2str(Sysfit{k}.A(ipar),'%3.1f'),num2str(Varytemp.A(ipar),'%3.1f')};line=line+1;
                                     else
                                        alldata(line,:)={false,['A1_C',strk,'(1)'],num2str(Sysfit{k}.A(1),'%3.1f'),num2str(Varytemp.A(1),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A1_C',strk,'(2)'],num2str(Sysfit{k}.A(2),'%3.1f'),num2str(Varytemp.A(2),'%3.1f')};line=line+1;
                                        alldata(line,:)={false,['A1_C',strk,'(3)'],num2str(Sysfit{k}.A(3),'%3.1f'),num2str(Varytemp.A(3),'%3.1f')};line=line+1;
                                    end
                                end
                            end
                    end
                end
                clear names

            end
            %alldata{1,:}
            %%%%% figure avec tableau pour parametres variables
            hsimlabel2esfit=figure();%figure(max(findobj('type','figure'))+1); %pour ne pas superposer des figures
            pos=get(hSimLabelmain,'position');
            set(hsimlabel2esfit,'Units','pixels','position',[pos(1)+pos(3)/3 pos(2)+pos(4)/4 pos(3)/2.5 pos(4)/2],...
                 'Name','to fitting mode','Menubar', 'none', 'Toolbar', 'none',...
                 'NumberTitle','off','WindowStyle','modal',...
                 'color',get(0,'DefaultUicontrolBackgroundColor'),...
                 'CloseRequestFcn',@closefig2esfit);

            htable=uitable(hsimlabel2esfit,'Units','normalized','Position',...
                [0.01 0.01 0.73 0.98],'Data',alldata,...
                'columnname',{'','Name','center',['vary (',char(177),')']},...
                'columnformat',{'logical','char','char','char'},... plutot que numeric
                'ColumnEditable',[ true false true true],...
                'rowname',[],...
                'TooltipString',sprintf([char(183),' Hyperfine coupling A in MHz\n',char(183),' 0<nb of parameters<=30']),...
                'ColumnWidth',{17 65 55 55},...
                'CellEditCallback',@newalldata);

           hOK4esfit=uicontrol('Style','pushbutton',...
               'String','Go','Units','Normalized',...
               'fontunits','pixels','fontsize',ftsz,...
                'pos',[0.76 0.02 0.21 0.1],'parent',hsimlabel2esfit,...
                'Callback', @ok4esfit,...{@ok4esfit,selectedrank},...
                'TooltipString','Open "esfit" panel with the pre-selected parameters','enable','off');

           hcancel4esfit=uicontrol('Style','pushbutton',...
               'String','Cancel','Units','Normalized',...
               'fontunits','pixels','fontsize',ftsz,...
                'pos',[0.76 0.13 0.21 0.07],'parent',hsimlabel2esfit,...
                'Callback', @cancel4esfit,'TooltipString','Back to SimLabel','enable','on'); 

            hall4esfit=uicontrol('Style','pushbutton',...
               'String','All','Units','Normalized',...
               'fontunits','pixels','fontsize',ftsz,...
                'pos',[0.74 0.94 0.15 0.05],'parent',hsimlabel2esfit,...
                'Callback', @all4esfit,'TooltipString','Select all parameters','enable','on'); 

            hnone4esfit=uicontrol('Style','pushbutton',...
               'String','None','Units','Normalized',...
               'fontunits','pixels','fontsize',ftsz,...
                'pos',[0.74 0.88 0.15 0.05],'parent',hsimlabel2esfit,...
                'Callback', @none4esfit,'TooltipString','Unselect all parameters','enable','on'); 
            %%%%%%%%%%%

            for k=2:numel(componentdata) %affichage des corresponadances esfit et componentdata
                if componentdata(k).include
                    corres2disp{k-1}=[componentdata(k).name,': C',num2str(k-1)]; 
                end
            end
            if iscell(correlinfo) %il existe des correl
                for n=1:numel(correlinfo)
                    corres2disp{k-1+n}=correlinfo{n};
                end
            else %correlinfo='No correlation is considered...' =char
                corres2disp{k}=correlinfo;
            end
            set(hcomponentletter,'string',corres2disp,'visible','on');
            if sum(cell2mat(alldata(:,1)))>30
                set(hOK4esfit,'enable','off')
            end
      end
    end
    else

         uiwait(msgbox({'WARNING:   Several possible reasons...';'';[char(183),' No saved simulation selected'];[char(183),' No experimental spectrum loaded']},'SimLabel_WARNING','Warn','modal'));

     end

end


function quitesfit(~,~)
      %pour quitter esfit. Question pour importer les donnees issues de
      %esfit qui sont contenues dans structure "fit1" du workspace de base
      
      fitname=evalin('base','who(''-regexp'', ''fit*'')');

      % Construct a questdlg with 2 options
      nbfit=numel(fitname);
      askstr=[];
      switch nbfit
          case 1 %1!fit
              askstr='Do you want to save the fit result?';
          case 0
              
              hfigesfit=findobj('type','figure','-and','name','EasySpin Least-Squares Fitting');
              if ishandle(hfigesfit)
              choice1=questdlg({'No fit exported from EasySpin Least-Squares Fitting.';'';'Do you really want to quit fitting mode?'},'Back to SimLabel...','No','Yes','Yes');
                switch choice1
                    case 'Yes'
                        closeesfit();
                end
              
              else
                  closeesfit();
              end
            otherwise
              askstr='Do you want to save the fit results?';
      end
     if ~isempty(askstr)
        choice2 = questdlg(askstr,'Back to SimLabel...','Cancel','No','Yes','Yes');
        % Handle response
        switch choice2
             case 'No'
                 closeesfit()

             case 'Yes'
                
                
%                     hfigesfit=findobj('type','figure','-and','name','EasySpin Least-Squares Fitting'); 
%                     delete(hfigesfit)

                    datafromfit=load(simulfile4esfit,'-mat'); %chargement de 'Syssimul','datasimul','Exp' de la simul manuelle utilisee pour lancer esfit
                    if nbfit==1
                        [fitfile,path2fitfile]=uiputfile('*.slb',['Saving ',fitname{1}],[simulfile4esfit(1:end-4),'_fit']); %ouverture boite de dialogue dans repertoire courant (nom propose)
                        if fitfile~=0
                            fit=evalin('base',fitname{1});
                            savefit(fit,datafromfit,path2fitfile,fitfile);
                            loadanddisp(load(fullfile(path2fitfile,fitfile),'-mat')); %affichage du dernier
                        end

                    else
                        for k=1:nbfit
                            [fitfile,path2fitfile]=uiputfile('*.slb',['Saving ',fitname{k}],[simulfile4esfit(1:end-4),'_fit',num2str(k)]); %ouverture boite de dialogue dans repertoire courant (nom propose)
                            if fitfile~=0
                                fit=evalin('base',fitname{k});
                                savefit(fit,datafromfit,path2fitfile,fitfile);
                            end
                        end
                        if fitfile~=0
                            loadanddisp(load(fullfile(path2fitfile,fitfile),'-mat')); %affichage du dernier
                        end
                    end
                    closeesfit()
        end
      end
      clc
end

function savefit(fit,datafromfit,path2fitfile,fitfile)
        nbcomp=numel(datafromfit.datasimul);
        Sysfromfit=fit.Sys; %Sys resultat du fit
        newSys=datafromfit.Syssimul; %nouveau Sys=Sys du .slb envoye vers esfit pour modification et sauvegarde dans nouveau .slb
        datasimul=datafromfit.datasimul; %nouveau datasimul  /componentdata envoye a esfit

        allfield=fieldnames(Sysfromfit); %liste des noms de champ
        num_cp=zeros(1,numel(allfield)); %tableau des numeros de composante correspondant a allfield
        for k=1:numel(allfield)
            num_cp(k)=str2double(allfield{k}(end));
        end
        for k=1:nbcomp
           strk=num2str(k);
           strkcorr=num2str(correltab(k));
           %champs forcement presents
           if nbcomp>1
            eval(['datasimul(k).weightval=Sysfromfit.weight_C',strk,';']);
            newSys{k}.weight=datasimul(k).weightval;
           end
           eval(['datasimul(k).gaussianval=Sysfromfit.lw_C',strkcorr,'(1);']);
           eval(['datasimul(k).lorentzianval=Sysfromfit.lw_C',strkcorr,'(2);']);
           newSys{k}.lw=[datasimul(k).gaussianval datasimul(k).lorentzianval];
           
           %tcorr si pas frozen mode
           statusval=get(hsimultype,'value');
           status=simultype{statusval}; %'Slow Motion' ou 'Frozen Solution' 
           if strcmp(status,'Slow Motion')
               %tcorr: si logtcorr non variable envoye a esfit => on recupere
               %ancienne valeur pour avoir meme valeur qu'au depart (risque de
               %changement a cause de 10^log10...
               logtcorr_Ck=['logtcorr_C',strk];
               [~,pos]=ismember(logtcorr_Ck,{alldata{:,2}});
               if alldata{pos,1} %tcorr variable sinon valeur inchangee
                    eval(['datasimul(k).tcorrval=10^Sysfromfit.logtcorr_C',strk,';']);   
                    eval(['newSys{k}.logtcorr=Sysfromfit.logtcorr_C',strk,';']);
               end
           end

           indcpk= num_cp==k; %tableau des indices des champs de allfield correspondant a la composante k
           indcpkcorr= num_cp==correltab(k); %tableau des indices des champs de allfield correspondant a la composante a laquelle est correlee k
                % si pas de correlation, correltab(k)=k
          % names=allfield(indcpk); %liste des noms de champ associe a la composante k
           namescorr=allfield(indcpkcorr); %liste des noms de champ associe a la composante a laquelle est correlee k
           isA1=0; %indicateur de presence de A1
           isA2=0; %indicateur de presence de A2
           for n=1:numel(namescorr)
            switch namescorr{n}
               case ['A1perp_C',strkcorr]
                      iperp=datasimul(correltab(k)).axialcombinationA(1,:); %indice directions perp (2elements)
                      ipar=setdiff(1:3,iperp); 
                      eval(['datasimul(k).Aval(1,[',num2str(iperp),'])=mhz2mt(Sysfromfit.A1perp_C',strkcorr,');']);
                      eval(['datasimul(k).Aval(1,',num2str(ipar),')=mhz2mt(Sysfromfit.A1par_C',strkcorr,');']);
                      isA1=1;
                      
               case ['A1_C',strkcorr]
                      eval(['datasimul(k).Aval(1,:)=mhz2mt(Sysfromfit.A1_C',strkcorr,');']);
                      isA1=1;

               case ['A2perp_C',strkcorr]
                      iperp=datasimul(correltab(k)).axialcombinationA(2,:); %indice directions perp (2elements)
                      ipar=setdiff(1:3,iperp); 
                      eval(['datasimul(k).Aval(2,[',num2str(iperp),'])=mhz2mt(Sysfromfit.A2perp_C',strkcorr,');']);
                      eval(['datasimul(k).Aval(2,',num2str(ipar),')=mhz2mt(Sysfromfit.A2par_C',strkcorr,');']);
                      isA2=1;

               case ['A2_C',strkcorr]   
                      eval(['datasimul(k).Aval(2,:)=mhz2mt(Sysfromfit.A2_C',strkcorr',');']);
                      isA2=1;

               case ['gperp_C',strkcorr]
                       iperp=datasimul(correltab(k)).axialcombinationg; %indice directions perp (2elements)
                       ipar=setdiff(1:3,iperp);
                       eval(['datasimul(k).gval([',num2str(iperp),'])=Sysfromfit.gperp_C',strkcorr,';']);
                       eval(['datasimul(k).gval(',num2str(ipar),')=Sysfromfit.gpar_C',strkcorr,';']);
                       newSys{k}.g=datasimul(k).gval;

                case ['g_C',strkcorr]
                       eval(['datasimul(k).gval=Sysfromfit.g_C',strkcorr,';']);
                       newSys{k}.g=datasimul(k).gval;
            end
           end


            if isA1 %A1 existe
                if isA2
                    newSys{k}.A=mt2mhz(datasimul(k).Aval);
                else
                    newSys{k}.A=mt2mhz(datasimul(k).Aval(1,:));
                end
%                 newSys{k}.Nucs=Syssimul{k}.Nucs;
%             else
%                 newSys{k}=rmfield(Syssimul{k},'A');
            end

            datasimul(k).specsimul=easyspinfunc(newSys{k},datafromfit.Exp);

           clear names
        end
        
        datafromfit=rmfield(datafromfit,'datasimul');
        datafromfit=rmfield(datafromfit,'Syssimul');
        datafromfit.datasimul=datasimul;
        datafromfit.Syssimul=newSys;
        save([path2fitfile,fitfile],'-struct','datafromfit');% sauvegarde de 'Syssimul','datasimul','Exp');%
        %evalin('base',['clear ', fit]); %suppression de fit du workspace de base
        add2list(fitfile,path2fitfile);

end


function closeesfit()% %ferme la figure esfit et remet les handle on et component visibles
   hfigesfit=findobj('type','figure','-and','name','EasySpin Least-Squares Fitting');
% hfigesfit
% hSimLabelmain
   if ishandle(hfigesfit)
       delete(hfigesfit)
   end 
   set(hcomponentletter,'string','','visible','off');
   set([componenth(2:end).hfig],'visible','on');
%    for k=1:numel(handlesmainenab4esfit)
%        if ~ishandle(handlesmainenab4esfit(k))
%            disp([num2str(k),': ', num2str(handlesmainenab4esfit(k))])
%        end
%    end
   set(hesfit,'Callback', @openesfit,'TooltipString','Open "esfit" panel (fitting with EasySpin)','String','Fit');
   set(handlesmainenab4esfit,'enable','on'); % tous les handles anciennement 'on 'redeviennent 'on'
  
   datafit=[]; % 1 structure regroupant toutes les composantes a envoyer a esfit 
   componentdatafit=componentdatainit;%composantes utilisees pour esfit (conservation de l'info d'axialite)
   Vary=[]; %structure des paramaetres variables envoyes a esfit
    htable=hinit; %handle de la table de parametres a transferer a esfit
    hOK4esfit=hinit; %handle bouton OK de la table de parametres a transferer a esfit
    warningstatus=0;% pas de warning affiche
    simulfile4esfit=[]; %simulation manuelle utilisee pour lancer esfit
    handlesmainenab4esfit=[];%liste des handles enable 'on' sur simlabel_main avant esfit
    correltab=[]; %table des corelations pour esfit 
    delete(fullfile(path4func4esfit,'temporary_func4esfit.m'));
end

function ok4esfit(hObject,~)%,selectedrank)
     %simulfile4esfit=fullfile(listpath{selectedrank},listfile{selectedrank}); %simulation manuelle utilisee pour lancer esfit

        %boutons enable off 
        set([componenth(2:end).hfig],'visible','off');
        handlesmainenab4esfit=findobj(hSimLabelmain,'-property','enable','-and','enable','on'); %tous les handles de SimLabel_main avec propriete 'enable' on
        handlesmainenab4esfit(handlesmainenab4esfit==hesfit)=[]; %sans le handle de "esfit"
        handlesmainenab4esfit(handlesmainenab4esfit==hcomponentletter)=[]; %sans le handle du texte d'info sur correspondance lettre component
        handlesmainenab4esfit(handlesmainenab4esfit==hdoc)=[]; %sans le handle de "?"
        handlesmainenab4esfit(end+1:end+3)=[hzoomin,hzoomout,hhand]; %handles zoom et main sont invisibles
        set(handlesmainenab4esfit,'enable','off'); % tous les handles 'enbale' off => pas d'action possible pendant esfit     
        set(hesfit,'Callback', @quitesfit,'TooltipString',sprintf('Back to Simlabel:\nImport data from "esfit" (fitting with EasySpin)?'),'String','Esc. Fit Mode');

        %nouveau Vary et Sysfit si modification des valeurs dans tableau
        
        Vary=[];%struct([]);
        Sysfit=Vary;

        nbvar=size(alldata,1);%sizealldata(1);
        for k=1:nbvar
            fieldval=alldata{k,2}; % du genre g_C1(1) ou weight_C2
        
            if alldata{k,1} %si parametre inclu dans fit
                strvalvary=alldata{k,4};%num2str(alldata{k,4},strformat);
            else
                strvalvary='0';
            end
            strvalsys=alldata{k,3};%num2str(alldata{k,3},strformat);
            %pbl si element de  structure avec que des zeros
            if ~isnan(str2double(strvalvary)) && ~isnan(str2double(strvalsys)) % si entrees non numeriques
               eval(['Vary.',fieldval,'=',strvalvary,';']);
               eval(['Sysfit.',fieldval,'=',strvalsys,';']);
            else
                error([fieldval,' contains non numeric data...']);
            end
        end

        if ~isequal([Bexp(1) Bexp(end)],Exp.Range)
            newBexp=linspace(Exp.Range(1),Exp.Range(2),1024);
            specexp4fit=interp1(Bexp,specexp,newBexp,'spline');
        else
            specexp4fit=specexp;
        end
       % save('test.mat','Sysfit')
        generate_func4esfit(Sysfit); %creation de la fonction de fitting

        esfit('temporary_func4esfit',specexp4fit,Sysfit,Vary,Exp) %{Vary{1} Vary{2} Vary{3}}
        close(get(hObject,'parent')); %tue alldata Sys Vary
        
end

function generate_func4esfit(Sys)%,ind)
    %creation de la fonction de fitting
    % Sys: systeme de spin customise pour le fit 
    %charfunction: chaine de caracteres contenant le nom de la fonction easyspin (chili ou pepper)
    
    path4func4esfit=pwd;%path2expspec;
    fid=fopen(fullfile(path4func4esfit,'temporary_func4esfit.m'),'w'); %nouvelle function dans repertoire courant pour etre utilisable par esfit
    fprintf(fid,'%s\n','function varargout = temporary_func4esfit(Sys,Exp,SimOpt)');
    allfield=fieldnames(Sys); %liste des noms de champ
    nbcp=str2double(allfield{end}(end)); %nb de component=dernier caractere du dernier champ (A2par_C3)=> 3 composantes
   
    num_cp=zeros(1,numel(allfield)); %tableau des numeros de composante correspondant a allfield
    for k=1:numel(allfield)
        num_cp(k)=str2double(allfield{k}(end));
    end


 
    for k=1:nbcp
        indcpk= num_cp==k; %tableau des indices des champs de allfield correspondant a la composante k
        indcpkcorr= num_cp==correltab(k); %tableau des indices des champs de allfield correspondant a la composante a laquelle est correlee k
                % si pas de correlation, correltab(k)=k
        names=allfield(indcpk); %liste des noms de champ associe a la composante k
        namescorr=allfield(indcpkcorr); %liste des noms de champ associe a la composante a laquelle est correlee k
        
        strk=num2str(k);
        strkcorr=num2str(correltab(k));
        
        isA1=0; %indicateur de presence de A1
        isA2=0; %indicateur de presence de A2
        
        axialA=componentdatafit(correltab(k)).axialcombinationA;
        
        for n=1:numel(names)
            switch names{n}
                case ['logtcorr_C',strk]
                    fprintf(fid,'%s\n',['     Sys',strk,'.logtcorr=Sys.logtcorr_C',strk,';']);

            end
        end
        for n=1:numel(namescorr)
            switch namescorr{n}
                case ['lw_C',strkcorr]
                    fprintf(fid,'%s\n',['     Sys',strk,'.lw=Sys.lw_C',strkcorr,';']);
                    
                case ['g_C',strkcorr]
                    fprintf(fid,'%s\n',['     Sys',strk,'.g=Sys.g_C',strkcorr,';']);
                    
                case ['gperp_C',strkcorr]
                    iperp=componentdatafit(correltab(k)).axialcombinationg; %indice directions perp (2elements)
                    ipar=setdiff(1:3,iperp);
                    fprintf(fid,'%s\n',['     Sys',strk,'.g([',num2str(iperp),'])=Sys.gperp_C',strkcorr,';']);
                    fprintf(fid,'%s\n',['     Sys',strk,'.g(',num2str(ipar),')=Sys.gpar_C',strkcorr,';']);

                case ['A1perp_C',strkcorr]
                    iperp=axialA(1,:); %indice directions perp (2elements)
                    ipar=setdiff(1:3,iperp);
                    fprintf(fid,'%s\n',['     A1([',num2str(iperp),'])=Sys.A1perp_C',strkcorr,';']);
                    fprintf(fid,'%s\n',['     A1(',num2str(ipar),')=Sys.A1par_C',strkcorr,';']);
                    isA1=1;
               
                case ['A2perp_C',strkcorr] 
                    iperp=axialA(2,:); %indice directions perp (2elements)
                    ipar=setdiff(1:3,iperp);
                    fprintf(fid,'%s\n',['     A2([',num2str(iperp),'])=Sys.A2perp_C',strkcorr,';']);
                    fprintf(fid,'%s\n',['     A2(',num2str(ipar),')=Sys.A2par_C',strkcorr,';']);
                    isA2=1;
                    
                case ['A1_C',strkcorr]
                    fprintf(fid,'%s\n',['     A1=Sys.A1_C',strkcorr,';']);
                    isA1=1;
                
                case ['A2_C',strkcorr]
                    fprintf(fid,'%s\n',['     A2=Sys.A2_C',strkcorr,';']);
                    isA2=1;
                    

            end
        end


        if isA1 %A1 existe
            Istr=componentdatafit(correltab(k)).Istr; %string contenant les spins nucleaires
            Istr1=Istr{1}; %char ou cell???
            if iscell(Istr1) %=> Istr1:char
                Istr1=Istr1{1};
            end
            indNuc1=ismember(differentI,Istr1); %indice du noyau1

            if isA2
                Istr2=Istr{2}; %char ou cell???
                if iscell(Istr2)%=> Istr2:char
                    Istr2=Istr2{1};
                end
                indNuc2= ismember(differentI,Istr2); %indice du noyau2
                fprintf(fid,'%s\n',['     Sys',strk,'.A=[A1;A2];']);
                fprintf(fid,'%s\n',['     Sys',strk,'.Nucs=''',differentNucs{indNuc1},',',differentNucs{indNuc2},''';']);
            else
                fprintf(fid,'%s\n',['     Sys',strk,'.A=A1;']);
                fprintf(fid,'%s\n',['     Sys',strk,'.Nucs=''',differentNucs{indNuc1},''';']);
            end
        end
        if k==1
            fprintf(fid,'%s\n',['     [x,y_(:,1)]=',func2str(easyspinfunc),'(Sys',strk,',Exp,SimOpt);']);
        else
            fprintf(fid,'%s\n',['     y_(:,',strk,')=',func2str(easyspinfunc),'(Sys',strk,',Exp,SimOpt);']);
        end

    end
    strcalc='y=y_(:,1)';
    if nbcp>1
       strcalc=[strcalc,'*Sys.weight_C1'];   
       for k=2:nbcp
           strk=num2str(k);
           strcalc=[strcalc,'+y_(:,',strk,')*Sys.weight_C',strk];
        end
    end
    fprintf(fid,'%s\n',['     ',strcalc,';']);
    fprintf(fid,'%s\n','     if nargout==1');
    fprintf(fid,'%s\n','        varargout={y};');
    fprintf(fid,'%s\n','     else');
    fprintf(fid,'%s\n','        varargout={x,y};');
    fprintf(fid,'%s\n','     end');
    
    
    fprintf(fid,'%s','end');
    fclose(fid);  

end

function cancel4esfit(hObject,~)
    close(get(hObject,'parent'));
    set(hcomponentletter,'string','','visible','off');
    %datafit=[]; % 1 structure regroupant toutes les composantes a envoyer a esfit
     componentdatafit=componentdatainit;%composantes utilisees pour esfit (conservation de l'info d'axialite)
     correltab=[]; %table des corelations pour esfit
     % Vary=[]; %structure des paramaetres variables envoyes a esfit
%     alldata={}; %cell array contenant donnees affichees sur fenetre avant esfit
%     htable=hinit; %handle de la table de parametres a transferer a esfit
%     hOK4esfit=hinit; %handle bouton OK de la table de parametres a transferer a esfit
     clc
end

function closefig2esfit(hobject,~)
    delete(hobject);
    %datafit=[]; % 1 structure regroupant toutes les composantes a envoyer a esfit
    componentdatafit=componentdatainit;%composantes utilisees pour esfit (conservation de l'info d'axialite)
    %Vary=[]; %structure des paramaetres variables envoyes a esfit
    %alldata={}; %cell array contenant donnees affichees sur fenetre avant esfit
    htable=hinit; %handle de la table de parametres a transferer a esfit
    hOK4esfit=hinit; %handle bouton OK de la table de parametres a transferer a esfit
    %correltab=[]; %table des corelations pour esfit
    clc
end
    
function all4esfit(~,~)
    alldata(:,1)=deal({true});
    set(htable,'Data',alldata);
    nbdata2fit=sum(cell2mat(alldata(:,1)));
    if nbdata2fit>30 || nbdata2fit==0
        set(hOK4esfit,'enable','off')
    else
        set(hOK4esfit,'enable','on')
    end
end

function none4esfit(~,~)
    alldata(:,1)=deal({false});
    set(htable,'Data',alldata);
    set(hOK4esfit,'enable','off')
end

function newalldata(hobj,~)
        alldata=get(hobj,'data');
        nbdata2fit=sum(cell2mat(alldata(:,1)));
        if nbdata2fit>30 || nbdata2fit==0
            set(hOK4esfit,'enable','off')
        else
            set(hOK4esfit,'enable','on')
        end
end

end