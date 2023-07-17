function abcdFinal_K_seitzman %(level1,level2)
%changed the main to continue running regardless of significant results
%no age, no log scale, mode-A, fair, [1 sqrt(feats)] for both views


set_path;
cfg.idf='';  %don't forget to change the frwork.flag as well for your experiments
cfg.dir.project = '/cs/research/intelsys/anomaly_detection/Code/spls_cca_pca/abcdAll_noA_seitzman';
cfg.frwork.flag = '_fair_modeA_pub_seitzman_new';

%%%%%%%%%%%%%%%%  BEFORE RUNNING FOR A NEW DATA PARTITION YOU COMMENT OUT AND RUN THIS PART 
%%%%%%%%%%%%%%%%  ONCE AND THEN COMMENT IN AND RUN IN CLUSTER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set the portion of data you want to use
% origDataLoc=fullfile(cfg.dir.project,'data/orig');
% saveDataLoc=fullfile(cfg.dir.project,'data', cfg.idf);
% 
% load(fullfile(origDataLoc,'X'));
% load(fullfile(origDataLoc,'Y'));
% load(fullfile(origDataLoc,'C'));
% load(fullfile(origDataLoc,'EB'));
% 
% %anomaly wipe-out - don't forget to use the same cv matrix (anomalies are
% %out from the training) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load(fullfile(origDataLoc,'brain_anomalous_ind'));
% X(brain_anomalous_ind,:)=[];
% Y(brain_anomalous_ind,:)=[];
% C(brain_anomalous_ind,:)=[];
% EB(brain_anomalous_ind,:)=[];
% 
% save(fullfile(saveDataLoc, 'X_Proj'),'X','-v7.3');
% save(fullfile(saveDataLoc, 'Y_Proj'),'Y');
% save(fullfile(saveDataLoc, 'C_Proj'),'C');
% save(fullfile(saveDataLoc, 'EB'),'EB');


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
main(cfg);



%%%%%%%%%%%%%%%%%% THE REST IS FOR PLOTTING. IF YOU WILL ONLY DO PLOTTING
%%%%%%%%%%%%%%%%%% AFTER THE JOBS ARE DONE, THEN COMMENT OUT THE MAIN(CFG)
%%%%%%%%%%%%%%%%%% LINE ABOVE 

% frworkNow=cfg.dir.frwork;
% % try
% %     load(fullfile(frworkNow,'plotID'),'plotID');
% % catch
% %     plotID=1;
% %     save(fullfile(frworkNow,'plotID'),'plotID');
% %     
%     for l=1:4
%         display(['Plot and clean level ' num2str(l)]);
%         reses=dir(fullfile(frworkNow,'res',['level' num2str(l)],'res_*'));
%         load(fullfile(frworkNow,'res',['level' num2str(l)],reses(1).name));
%         plot_spls(l,cfg,1);
% %         cleanup_files(cfg);
%         clear res
%     end  
% % end
    
