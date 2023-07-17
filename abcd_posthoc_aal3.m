function abcd_posthoc_aal3(level1,level2)
%changed the main to continue running regardless of significant results
%no age, no log scale, mode-A, fair, [1 sqrt(feats)] for both views

%set 
% level1 = 1;
% level2 = 15;
set_path('plot');
% frworkNow = '/SAN/intelsys/anomaly_detection/Code/spls_cca_pca/abcdAll_noA/framework/spls_fair20-5_fair_modeA';
frworkNow = '/cs/research/intelsys/anomaly_detection/Code/spls_cca_pca/abcdAll_noA_aal3/framework/spls_fair20-5_fair_modeA_pub_aal3_new';
dataDirNow = '/cs/research/intelsys/anomaly_detection/Code/spls_cca_pca/abcdAll_noA_aal3/data';
load(fullfile(frworkNow, 'outmat_815.mat'));
trid = otrid(:,1); 

load(fullfile(dataDirNow,'','C_Proj'))
bmiVector = C(:,end);

% %load
% load(fullfile(dataDirNow, 'motionVector.mat'));
% load(fullfile(dataDirNow, 'patientOrderFinal.mat'));
% load(fullfile(dataDirNow, 'all', 'X_Proj.mat'));
% load(fullfile(dataDirNow, 'all', 'Y_Proj.mat'));
% load(fullfile(frworkNow, 'teid.mat'));
% load(fullfile(frworkNow, 'trid.mat'));
% load(fullfile(frworkNow, 'tedata_norm.mat'));
% load(fullfile(frworkNow, 'trdata_norm.mat'));
% 
% %pre-calculate
% motionVector(motionVector==10)=NaN;
% nonan_ind = ~isnan(motionVector);
% 
% 
% [values]  = svd(trdata.X*(trdata.X)');
% % total_brain_var_tr = (sum(values(values>0).^2));
% % 
% % [vectors_y, values_y]  = svd(trdata.Y*(trdata.Y)');
% % total_beh_var_tr = (sum(values_y(values_y>0).^2));
% 
% 
%     
% %allocate
% %tr/test br/beh correlations with movement
% %tr/test br/bh stdev in each mode
% [mov_corr_beh_tr, mov_corr_beh_test, mov_corr_br_tr, mov_corr_br_test]= deal(zeros(1,level2-level1+1));
% [std_beh_tr, std_beh_test, std_br_tr, std_br_test]= deal(zeros(1,level2-level1+1));
% [exp_beh_tr, exp_b eh_test, exp_br_tr, exp_br_test]= deal(zeros(1,level2-level1+1));


%analyse
lenVec=[];
indVec=[];

for l=1:3
    display(['At level ' num2str(l)]);
    reses=dir(fullfile(frworkNow,'res',['level' num2str(l)],'res_*'));
    res = load(fullfile(frworkNow,'res',['level' num2str(l)],reses(1).name));
    res = res.res;
    load(fullfile(frworkNow, 'res',['level' num2str(l)], 'P.mat'));
    P = squeeze(P);

    stDScale = 6;
    brainV = P(trid,1);
    behV = P(trid,2);
    bmiV = bmiVector(trid);
    display(corr(bmiV,brainV));
    display(corr(bmiV,behV));
    
    trids = find(trid);
    stdBr = std(brainV);
    meanBr = mean(brainV);
    indNow = find((brainV > (meanBr+stDScale*stdBr)) | (brainV < (meanBr-stDScale*stdBr)));
    lenNow = length(indNow);
    lenVec = [lenVec, lenNow];
    indVec = [indVec, indNow'];    
%     figure, plot(brainV,'kx'); 
%     figure, plot(brainV, 1:length(brainV),'kx'); 


    
%     scatter(P(teid,1), P(teid,2), 100, 'MarkerFaceColor', [0.3 0.1 0.1], 'MarkerEdgeColor', 'k');
%     figure, plot3(P(:,1), P(:,2), 1:length(P(:,1)), 'kx'); view(0,90); 


%     myFit = fitdist(P(trid,1),'Normal');
%     sum(abs(P(trid,1))>3*myFit.sigma)
%     sum(abs(P(trid,1))>5*mad(P(trid,1)))
%     
%     myFit = fitdist(P(trid,2),'Normal');
%     sum(abs(P(trid,2))>3*myFit.sigma)
%     sum(abs(P(trid,2))>5*mad(P(trid,2)))

    
%     %movement 
%     disp('Calculating movement');
%     mov_corr_beh_tr(l) = corr(P(trid&nonan_ind,2), motionVector(trid&nonan_ind));
%     mov_corr_beh_test(l) = corr(P(teid&nonan_ind,2), motionVector(teid&nonan_ind));
%     mov_corr_br_tr(l) = corr(P(trid&nonan_ind,1), motionVector(trid&nonan_ind));
%     mov_corr_br_test(l) = corr(P(teid&nonan_ind,1), motionVector(teid&nonan_ind));
%     
%     %stdev
%     disp('Calculating stdev');
%     std_beh_tr(l) = std(P(trid,2));
%     std_beh_test(l) = std(P(teid,2));
%     std_br_tr(l) = std(P(trid,1));
%     std_br_test(l) = std(P(teid,1));
%     
%     %explained variance 
%     disp('Calculating explained variance');
%     
%     exp_beh_tr(l) = var(P(trid,2)); %/total_beh_var_tr;
%     exp_br_tr(l) = var(P(trid,1)); %/total_brain_var_tr;

end

% save(fullfile(frworkNow, 'mov_corr_beh_tr.mat'), 'mov_corr_beh_tr');
% save(fullfile(frworkNow, 'mov_corr_beh_test.mat'), 'mov_corr_beh_test');
% save(fullfile(frworkNow, 'mov_corr_br_tr.mat'), 'mov_corr_br_tr');
% save(fullfile(frworkNow, 'mov_corr_br_test.mat'), 'mov_corr_br_test');
% 
% save(fullfile(frworkNow, 'std_beh_tr.mat'), 'std_beh_tr');
% save(fullfile(frworkNow, 'std_beh_test.mat'), 'std_beh_test');
% save(fullfile(frworkNow, 'std_br_tr.mat'), 'std_br_tr');
% save(fullfile(frworkNow, 'std_br_test.mat'), 'std_br_test');
% 
% save(fullfile(frworkNow, 'exp_beh_tr.mat'), 'exp_beh_tr');
% save(fullfile(frworkNow, 'exp_br_tr.mat'), 'exp_br_tr');
lenVec
uniqInd = unique(indVec);
length(uniqInd)
brain_anomalous_ind = trids(uniqInd)
save brain_anomalous_ind brain_anomalous_ind

cemre = 1


