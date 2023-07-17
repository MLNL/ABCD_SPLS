function abcd %(level1,level2)
%changed the main to continue running regardless of significant results
%no age, no log scale, mode-A, fair, [1 sqrt(feats)] for both views


set_path;
cfg.idf='all';
cfg.dir.project = '/SAN/intelsys/anomaly_detection/Code/spls_cca_pca/abcd';
cfg.frwork.flag = '_fair_modeA';

%set the portion of data you want to use
origDataLoc=fullfile(cfg.dir.project,'data/orig');
saveDataLoc=fullfile(cfg.dir.project,'data', cfg.idf);

% load(fullfile(origDataLoc,'X'));
% load(fullfile(origDataLoc,'Y'));
% load(fullfile(origDataLoc,'C'));
% load(fullfile(origDataLoc,'EB'));
% 
% save(fullfile(saveDataLoc, 'X_Proj'),'X','-v7.3');
% save(fullfile(saveDataLoc, 'Y_Proj'),'Y');
% save(fullfile(saveDataLoc, 'C_Proj'),'C');
% save(fullfile(saveDataLoc, 'EB'),'EB');

% load(fullfile(saveDataLoc, 'X_Proj'));
% load(fullfile(saveDataLoc, 'Y_Proj'));
% load(fullfile(saveDataLoc, 'C_Proj'));
% load(fullfile(saveDataLoc, 'EB'),'EB');

cfg.data.block = 1;
cfg.frwork.split.EBcol = 2:3;

cfg.machine.param.nL1x = 20; %20
cfg.machine.param.nL1y = 20; %20
cfg.frwork.split.nin = 5;  %5
cfg.frwork.split.nout = 1;
cfg.frwork.split.propout = 0.2;
cfg.stat.nperm = 500; %500
cfg.frwork.name='fair';
%in the fair framework, we have mutually exclusive test sets (nout many and with propout
%proportion) with corresponding training sets (nout many and with the
%remaining subjects). the inner folds are regular CV's with nin many sets.

% Machine settings
cfg.machine.name = 'spls';
cfg.machine.metric = {'correl' 'simwx' 'simwy'};
cfg.machine.param.crit = 'correl+simwxy';

% Environment settings
cfg.env.comp = 'cluster';

% Deflation settings
cfg.defl.name = 'pls-modeA';
cfg.defl.crit = 'none';
cfg.defl.split = 'all';

% Statistical inference
cfg.stat.split.crit = 'correl';
cfg.stat.overall.crit = 'none';
  
% Update cfg with defaults
cfg = cfg_defaults(cfg);

%----- Run analysis
% main(cfg);


frworkNow=cfg.dir.frwork;
% try
%     load(fullfile(frworkNow,'plotID'),'plotID');
% catch
%     plotID=1;
%     save(fullfile(frworkNow,'plotID'),'plotID');
    
    for l=1:7
        display(['Plot and clean level ' num2str(l)]);
        reses=dir(fullfile(frworkNow,'res',['level' num2str(l)],'res_*'));
        load(fullfile(frworkNow,'res',['level' num2str(l)],reses(1).name));
        plot_spls(l,cfg,1);
%         cleanup_files(cfg);
        clear res
    end  
% end
    
