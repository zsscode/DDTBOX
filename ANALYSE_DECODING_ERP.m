function ANALYSE_DECODING_ERP(study_name,vconf,input_mode,sbjs_todo,dcg_todo)
%__________________________________________________________________________
% DDTBOX script written by Stefan Bode 01/03/2013
%
% The toolbox was written with contributions from:
% Daniel Bennett, Daniel Feuerriegel, Phillip Alday
%
% The author further acknowledges helpful conceptual input/work from: 
% Jutta Stahl, Simon Lilburn, Philip L. Smith, Elaine Corbett, Carsten Murawski, 
% Carsten Bogler, John-Dylan Haynes
%__________________________________________________________________________
%
% This script is the master-script for the group-level analysis of EEG-decoding
% results. It will call several subscripts that run all possible analyses,
% depending on the specific decoding analyses.
%
% requires:
% - study_name (e.g. 'DEMO')
% - vconf (version of study configuration script, e.g., "1" for DEMO_config_v1)
% - input_mode (1 = use coded varialbles from first section / 2 = enter manually)
% - sbjs_todo (e.g., [1 2 3 4 6 7 9 10 13])
% - dcg_todo (discrimination group to analyse, as specified in SLIST.dcg_labels{dcg})

%__________________________________________________________________________
%
% Variable naming convention: STRUCTURE_NAME.example_variable

%% GENERAL PARAMETERS AND GLOBAL VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

global DCGTODO;
DCGTODO = dcg_todo;

sbj_list = [study_name '_config_v' num2str(vconf)]; % use latest slist-function!

% define which subjects enter the second-level analysis
ANALYSIS.nsbj = size(sbjs_todo,2);
ANALYSIS.sbjs = sbjs_todo;
ANALYSIS.dcg_todo = dcg_todo;

%% specify details about analysis & plotting

%__________________________________________________________________________
if input_mode == 0 % Hard-coded input

    % define all parameters of results to analyse & Plot
    %______________________________________________________________________
    ANALYSIS.allchan = 1; % Are all possible channels analysed? 1=yes (default if spatial/spatio-temporal) / 2=no
    ANALYSIS.relchan = []; % specify channels to be analysed (for temporal only)
    
    ANALYSIS.analysis_mode = 1; % ANALYSIS mode (1=SVM with LIBSVM / 2=SVM with liblinear / 3=SVR with LIBSVM)
    ANALYSIS.stmode = 3; % SPACETIME mode (1=spatial / 2=temporal / 3=spatio-temporal)
    ANALYSIS.avmode = 1; % AVERAGE mode (1=no averaging; single-trial / 2=run average) 
    ANALYSIS.window_width_ms = 40; % width of sliding window in ms
    ANALYSIS.step_width_ms = 40; % step size with which sliding window is moved through the trial
           
    ANALYSIS.pstats = 0.05; % critical p-value
    ANALYSIS.group_level_analysis = 2; % Select statistical analysis method: 1 = Global null and prevalence testing based on the minimum statistic / 2 = Global null testing with t tests
    
    % If using minimum statistic approach for group-level analyses:
    ANALYSIS.P2 = 100000; % Number of second-level permutations to use
    ANALYSIS.minstat_multcomp = 1; % Correct for multiple comparisons using the maximum statistic approach:
    % 0 = no correction
    % 1 = correction based on the maximum statistic (also applied to prevalence lower bound testing)
    
    % If using t test approach for group-level analyses:
    ANALYSIS.permstats = 2; % Testing against: 1=theoretical chance level / 2=permutation test results
    ANALYSIS.drawmode = 1; % Testing against: 1=average permutated distribution (default) / 2=random values drawn form permuted distribution (stricter)
    ANALYSIS.groupstats_ttest_tail = 'right'; % Choose between two-tailed or one-tailed tests. 'both' = two-tailed / 'right' / 'left' = one-tailed testing for above/below chance accuracy
    ANALYSIS.use_robust = 0; % Use Yuen's t, the robust version of the t test? 1 = Yes / 0 = No
    ANALYSIS.trimming = 20; % If using Yuen's t, select the trimming percentage for the trimmed mean (20% recommended)
    
    ANALYSIS.multcompstats = 0; % Correction for multiple comparisons: 
    % 0 = no correction
    % 1 = Bonferroni correction
    % 2 = Holm-Bonferroni correction
    % 3 = Strong FWER Control Permutation Test
    % 4 = Cluster-Based Permutation Test
    % 5 = KTMS Generalised FWER Control
    % 6 = Benjamini-Hochberg FDR Control
    % 7 = Benjamini-Krieger-Yekutieli FDR Control
    % 8 = Benjamini-Yekutieli FDR Control
    ANALYSIS.n_iterations = 1000; % Number of permutation or bootstrap iterations for resampling-based multiple comparisons correction procedures
    ANALYSIS.ktms_u = 2; % u parameter of the KTMS GFWER control procedure
    ANALYSIS.cluster_test_alpha = 0.05; % For cluster-based test: Significance threshold for detecting effects at individual time windows (e.g. 0.05)
    
    % Group-level classifier accuracy results plotting options
    ANALYSIS.disp.on = 1; % display a results figure? 0=no / 1=yes
    ANALYSIS.permdisp = 1; % display the results from permutation test in figure as separate line? 0=no / 1=yes
    ANALYSIS.disp.sign = 1; % display statistically significant steps in results figure? 0=no / 1=yes
    ANALYSIS.plot_robust = 2; % Choose estimate of location to plot. 0 = arithmetic mean / 1 = trimmed mean / 2 = median
    ANALYSIS.plot_robust_trimming = 20; % Percent to trim if using the trimmed mean
    
    % Feature weight analysis options
    ANALYSIS.fw.do = 0; % analyse feature weights? 0=no / 1=yes
    ANALYSIS.fw.corrected = 1; % Use feature weights corrected using Haufe et al. (2014) method? 0=no / 1=yes
    ANALYSIS.use_robust_fw = 0; % Use Yuen's t, the robust version of the t test for feature weights? 1 = Yes / 0 = No
    ANALYSIS.trimming_fw = 20; % If using Yuen's t, select the trimming percentage for the trimmed mean (20% recommended)
    ANALYSIS.fw_ttest_tail = 'right';
    ANALYSIS.fw.multcompstats = 1; % Feature weights correction for multiple comparisons:
    % 1 = Bonferroni correction
    % 2 = Holm-Bonferroni correction
    % 3 = Strong FWER Control Permutation Test
    % 4 = Cluster-Based Permutation Test (Currently not available)
    % 5 = KTMS Generalised FWER Control
    % 6 = Benjamini-Hochberg FDR Control
    % 7 = Benjamini-Krieger-Yekutieli FDR Control
    % 8 = Benjamini-Yekutieli FDR Control
    
        % if feature weights are analysed, specify what is displayed
        %__________________________________________________________________
        
        % 0=no / 1=yes
        ANALYSIS.fw.display_matrix = 0; % feature weights matrix
        
        % maps and stats for averaged analysis time windows
        ANALYSIS.fw.display_average_zmap = 0; % z-standardised average FWs
        ANALYSIS.fw.display_average_uncorr_threshmap = 0; % thresholded map uncorrected t-test results
        ANALYSIS.fw.display_average_corr_threshmap = 0; % thresholded map corrected t-test results (Bonferroni)
        
        % maps and stats for each analysis time window
        ANALYSIS.fw.display_all_zmaps = 0; % z-standardised average FWs
        ANALYSIS.fw.display_all_uncorr_thresh_maps = 0; % thresholded map uncorrected t-test results
        ANALYSIS.fw.display_all_corr_thresh_maps = 0; % thresholded map corrected t-test results (Bonferroni)
%__________________________________________________________________________    

elseif input_mode == 1 % Prompted manual input
    
    % specify analysis channels
    ANALYSIS.allchan = input('Are all possible channels analysed? "0" for no; "1" for yes (default if spatial/spatio-temporal): ');
    
    if ANALYSIS.allchan ~= 1
        
        ANALYSIS.relchan = input('Enter the channels to be analysed (e.g. [1 4 5]): ');
        
    end
    
    % specify properties of the decoding analysis
    ANALYSIS.analysis_mode = input('Specifiy analysis method: "1" SVM with LIBSVM , "2" SVM with liblinear, "3" with LIBSVM: '); 
    ANALYSIS.stmode = input('Specify the s/t-analysis mode of the original analysis. "1" spatial, "2" temporal. "3" spatio-temporal: ');
    ANALYSIS.avmode = input('Specify the average mode of the original analysis. "1" single-trial, "2" run-average: ');
    ANALYSIS.window_width_ms = input('Specify the window width [ms] of the original analysis: ');
    ANALYSIS.step_width_ms = input('Specify the step width [ms] of the original analysis: ');
    
    % specify stats
    ANALYSIS.permstats = input('Testing against: "1" chance level; "2" permutation distribution: ');
    
    if ANALYSIS.permstats == 2
        
        ANALYSIS.drawmode = input('Testing against: "1" average permutated distribution (default); "2" random values drawn form permuted distribution (stricter): ');
        ANALYSIS.permdisp = input('Do you wish to display chance-level test results in figure? "0" for no; "1" for yes: ');
        
    end
    
    ANALYSIS.pstats = input('Specify critical p-value for statistical testing (e.g. 0.05): ');
    ANALYSIS.multcompstats = input(['\nSpecify if you wish to control for multiple comparisons: \n"0" for no correction \n'...
        '"1" for Bonferroni \n"2" for Holm-Bonferroni \n"3" for Strong FWER Control Permutation Testing \n' ...
        '"4" for Cluster-Based Permutation Testing \n"5" for KTMS Generalised FWER Control \n' ...
        '"6" for Benjamini-Hochberg FDR Control \n"7" for Benjamini-Krieger-Yekutieli FDR Control \n' ...
        '"8" for Benjamini-Yekutieli FDR Control \n Option: ']);
    
    if ANALYSIS.multcompstats == 3 || ANALYSIS.multcompstats == 4 || ANALYSIS.multcompstats == 5 % For permutation tests
        ANALYSIS.n_iterations = input('Number of permutation iterations for multiple comparisons procedure (at least 1000 is recommended): ');    
    end
    if ANALYSIS.multcompstats == 5 % For KTMS Generalised FWER control
       ANALYSIS.ktms_u = input('Enter the u parameter for the KTMS Generalised FWER control procedure: '); 
    end
    if ANALYSIS.multcompstats == 4 % For cluster-based permutation testing
       ANALYSIS.cluster_test_alpha = input('Enter the clustering threshold for detecting effects at individual time points (e.g. 0.05): '); 
    end
    
    % specify display options
    ANALYSIS.disp.on = input('Do you wish to display the results in figure(s)? "0" for no; "1" for yes: ');
    ANALYSIS.disp.sign = input('Specify if you wish to highlight significant results in figure. "0" for no; "1" for yes: ');
    
    % analyse feature weights
    ANALYSIS.fw.do = input('Do you wish to analyse the feature weights (only for spatial or spatio-temporal decoding)? "0" for no; "1" for yes: ');
    
    if ANALYSIS.fw.do == 1
        ANALYSIS.fw.corrected = input('Use feature weights corrected using Haufe et al. (2014) method? "0" for no; "1" for yes: ');
        ANALYSIS.fw.multcompstats = input(['\nSpecify which multiple comparisons correction method to use: \n' ...
        '"1" for Bonferroni \n"2" for Holm-Bonferroni \n"3" for Strong FWER Control Permutation Testing \n' ...
        '"4" for Cluster-Based Permutation Testing (Currently not available) \n"5" for KTMS Generalised FWER Control \n' ...
        '"6" for Benjamini-Hochberg FDR Control \n"7" for Benjamini-Krieger-Yekutieli FDR Control \n' ...
        '"8" for Benjamini-Yekutieli FDR Control \n Option: ']);
    
        if ANALYSIS.multcompstats == 3 || ANALYSIS.multcompstats == 4 || ANALYSIS.multcompstats == 5 % For permutation tests
            ANALYSIS.n_iterations = input('Number of permutation iterations for multiple comparisons procedure (at least 1000 is recommended): ');    
        end
        if ANALYSIS.multcompstats == 5 % For KTMS Generalised FWER control
           ANALYSIS.ktms_u = input('Enter the u parameter for the KTMS Generalised FWER control procedure: '); 
        end
        if ANALYSIS.multcompstats == 4 % For cluster-based permutation testing
           fprintf('Cluster-based corrections are currently not available.\n')
           % ANALYSIS.cluster_test_alpha = input('Enter the clustering threshold for detecting effects at individual time points (e.g. 0.05): '); 
        end
        
        ANALYSIS.fw.display_average_zmap = input('Do you wish to display the group-level averaged, z-standardised feature weights as a heat map? "0" for no; "1" for yes: '); % z-standardised average FWs
        ANALYSIS.fw.display_average_uncorr_threshmap = input(...
            'Do you wish to display the statistical threshold map (uncorrected) for the group-level averaged, z-standardised feature weights as a heat map? "0" for no; "1" for yes: '); % thresholded map uncorrected t-test results
        ANALYSIS.fw.display_average_corr_threshmap = input(...
            'Do you wish to display the statistical threshold map (corrected for multiple comparisons) for the group-level averaged, z-standardised feature weights as a heat map? "0" for no; "1" for yes: '); % thresholded map corrected t-test results (Bonferroni)
        
        % individual maps and stats
        ANALYSIS.fw.display_all_zmaps = input('');
        ANALYSIS.fw.display_all_uncorr_thresh_maps = input(...
            'Do you wish to display the statistical threshold map (uncorrected) for the group-level z-standardised feature weights for each time-step as a heat map? "0" for no; "1" for yes: ');
        ANALYSIS.fw.display_all_corr_thresh_maps = input(...
            'Do you wish to display the statistical threshold map (corrected for multiple comparisons) for the group-level z-standardised feature weights for each time-step as a heat map? "0" for no; "1" for yes: ');
        
    end
    
end % input

if ANALYSIS.analysis_mode == 1 
    ANALYSIS.analysis_mode_label='SVM_LIBSVM';
elseif ANALYSIS.analysis_mode == 2 
    ANALYSIS.analysis_mode_label='SVM_LIBLIN';
elseif ANALYSIS.analysis_mode == 3
    ANALYSIS.analysis_mode_label='SVR_LIBSVM';
end
    
%__________________________________________________________________________

fprintf('Group-level statistics will now be computed and displayed. \n'); 


%% OPEN FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

for s = 1:ANALYSIS.nsbj
    
    %% open subject data
    global SBJTODO;
    SBJTODO = s;
    sbj = ANALYSIS.sbjs(SBJTODO);
    
    global SLIST;
    eval(sbj_list);
    
    % open subject's decoding results       
    if size(dcg_todo,2) == 1
        
        fprintf('Loading results for subject %d in DCG %s.\n',sbj,SLIST.dcg_labels{dcg_todo});
        
        open_name = [(SLIST.output_dir) study_name '_SBJ' num2str(sbj) '_win' num2str(ANALYSIS.window_width_ms) '_steps' num2str(ANALYSIS.step_width_ms)...
            '_av' num2str(ANALYSIS.avmode) '_st' num2str(ANALYSIS.stmode) '_' ANALYSIS.analysis_mode_label '_DCG' SLIST.dcg_labels{ANALYSIS.dcg_todo} '.mat'];

    elseif size(dcg_todo,2) == 2
        
        fprintf('Loading results for subject %d for cross decoding DCG %s => DCG %s.\n',sbj,SLIST.dcg_labels{dcg_todo(1)},SLIST.dcg_labels{dcg_todo(2)});
        
        open_name=[(SLIST.output_dir) study_name '_SBJ' num2str(sbj) '_win' num2str(ANALYSIS.window_width_ms) '_steps' num2str(ANALYSIS.step_width_ms)...
            '_av' num2str(ANALYSIS.avmode) '_st' num2str(ANALYSIS.stmode) '_' ANALYSIS.analysis_mode_label '_DCG' SLIST.dcg_labels{ANALYSIS.dcg_todo(1)}...
            'toDCG' SLIST.dcg_labels{ANALYSIS.dcg_todo(2)} '.mat'];
    end   
   
    load(open_name);
    fprintf('Done.\n');
    
    ANALYSIS.pointzero=SLIST.pointzero;
        
    %% fill in parameters and extract results 
    %______________________________________________________________________
    %
    % RESULTS contains averaged results:
    % RESULTS.subj_acc(analysis/channel,time-step) 
    % RESULTS.subj_perm_acc(analysis/channel,time-step) 
    % RESULTS contains raw results:
    % RESULTS.prediction_accuracy{analysis/channel}(time-step,cross-val_step,rep_step)
    % RESULTS.perm_prediction_accuracy{analysis/channel}(time-step,cross-val_step,rep_step)
    %
    % this section adds group results to ANALYSIS:
    % ANALYSIS.RES.all_subj_acc(subject,analysis/channel,time_step(fist_step:last_step))
    % ANALYSIS.RES.all_subj_perm_acc(subject,analysis/channel,time_step(fist_step:last_step))
    % ANALYSIS.RES.all_subj_perm_acc_reps(subject,analysis/channel,time_step(fist_step:last_step),cross-val_step,rep_step)
    
    % Define missing parameters using the first subject's dataset
    %______________________________________________________________________
    if s == 1 
        
        % ask for the specific time steps to analyse
        if ANALYSIS.avmode == 1 || ANALYSIS.avmode == 1 % DF NOTE: Is the second IF statement supposed to specify a different value?
    
            fprintf('\n');
            fprintf('You have %d time-steps in your RESULTS. Each time-step represents a %d ms time-window. \n',size(RESULTS.subj_acc,2),STUDY.window_width_ms);
            ANALYSIS.firststep = 1;
            ANALYSIS.laststep = input('Enter the number of the last time-window you want to analyse: ');

        end
    
        % shift everything back by step-width, as first bin gets label=0ms
        ANALYSIS.firststepms = (ANALYSIS.firststep * STUDY.step_width_ms) - STUDY.step_width_ms;
        ANALYSIS.laststepms = (ANALYSIS.laststep * STUDY.step_width_ms) - STUDY.step_width_ms;

        % create matrix for data indexing
        ANALYSIS.data(1,:) = 1:size(RESULTS.subj_acc,2); % for XTick
        ANALYSIS.data(2,:) = 0:STUDY.step_width_ms:( (size(RESULTS.subj_acc,2) - 1) * STUDY.step_width_ms); % for XLabel
        ptz = find(ANALYSIS.data(2,:) == ANALYSIS.pointzero); % find data with PointZero
        ANALYSIS.data(3,ptz) = 1; clear ptz; % for line location in plot

        % copy parameters from the config file
        ANALYSIS.step_width = STUDY.step_width;
        ANALYSIS.window_width = STUDY.window_width;
        ANALYSIS.sampling_rate = STUDY.sampling_rate;
        ANALYSIS.feat_weights_mode = STUDY.feat_weights_mode;
        
        ANALYSIS.nchannels = SLIST.nchannels;
                
        ANALYSIS.channellocs = SLIST.channellocs;
        ANALYSIS.channel_names_file = SLIST.channel_names_file;     
                
        % extract Tick/Labels for x-axis
        for datastep = 1:ANALYSIS.laststep
            ANALYSIS.xaxis_scale(1,datastep) = ANALYSIS.data(1,datastep);
            ANALYSIS.xaxis_scale(2,datastep) = ANALYSIS.data(2,datastep);
            ANALYSIS.xaxis_scale(3,datastep) = ANALYSIS.data(3,datastep);
        end
        
        % Define chance level for statistical analyses based on the
        % analysis type
        if STUDY.analysis_mode == 1 || STUDY.analysis_mode == 2
            ANALYSIS.chancelevel = ( 100 / size(SLIST.dcg{ANALYSIS.dcg_todo(1)},2) );
        elseif STUDY.analysis_mode == 3 || STUDY.analysis_mode == 4
            ANALYSIS.chancelevel = 0;
        end
        
        % Define channels to be used for group-analyses
        if ANALYSIS.allchan == 1

            % use all channels (default for spatial / spatial-temporal)
            ANALYSIS.allna = size(RESULTS.subj_acc,1);

        elseif ANALYSIS.allchan ~= 1

            % use specified number of channels
            ANALYSIS.allna = size(ANALYSIS.relchan,2);

        end
        
        % get label for DCG
        if size(ANALYSIS.dcg_todo,2) == 1
            ANALYSIS.DCG = SLIST.dcg_labels{ANALYSIS.dcg_todo};
        elseif size(ANALYSIS.dcg_todo,2) == 2
            ANALYSIS.DCG{1} = SLIST.dcg_labels{ANALYSIS.dcg_todo(1)};
            ANALYSIS.DCG{2} = SLIST.dcg_labels{ANALYSIS.dcg_todo(2)};
        end
                
    end % of if s == 1 statement
    
    %% extract results data from specified time-steps / channels
    %______________________________________________________________________
    
    for na = 1:ANALYSIS.allna
        
        % Extract classifier and permutation test accuracies
        ANALYSIS.RES.all_subj_acc(s,na,ANALYSIS.firststep:ANALYSIS.laststep) = RESULTS.subj_acc(na,ANALYSIS.firststep:ANALYSIS.laststep);
        ANALYSIS.RES.all_subj_perm_acc(s,na,ANALYSIS.firststep:ANALYSIS.laststep) = RESULTS.subj_perm_acc(na,ANALYSIS.firststep:ANALYSIS.laststep);
            
        % needed if one wants to test against distribution of randomly
        % drawn permutation results (higher variance, stricter testing)
        ANALYSIS.RES.all_subj_perm_acc_reps(s,na,ANALYSIS.firststep:ANALYSIS.laststep,:,:) = RESULTS.perm_prediction_accuracy{na}(ANALYSIS.firststep:ANALYSIS.laststep,:,:);
            
    end
    %______________________________________________________________________
    
    % Extract feature weights
    if ANALYSIS.fw.do == 1 % If chosen to extract feature weights
        if ~isempty(RESULTS.feature_weights)
            ANALYSIS.RES.feature_weights{s} = RESULTS.feature_weights{1};
            ANALYSIS.RES.feature_weights_corrected{s} = RESULTS.feature_weights_corrected{1};
        end
    end % of if fw.do
    clear RESULTS;
    clear STUDY;
    
end % of for n = 1:ANALYSIS.nsbj loop

fprintf('All data from all subjects loaded.\n');

%% AVERAGE DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

% Calculate average accuracy & standard error across subjects
M(:,:) = mean(ANALYSIS.RES.all_subj_acc,1);
ANALYSIS.RES.mean_subj_acc(:,:) = M'; clear M;

if ANALYSIS.plot_robust == 1 % If plotting trimmed mean for group-level stats
    % Calculate and store the trimmed mean of subject accuracies
    trimmed_M(:,:) = trimmean(ANALYSIS.RES.all_subj_acc, ANALYSIS.plot_robust_trimming, 1);
    ANALYSIS.RES.trimmean_subj_acc(:,:) = trimmed_M'; clear trimmed_M;
    
elseif ANALYSIS.plot_robust == 2 % If plotting median for group-level stats
    
    median_M(:,:) = median(ANALYSIS.RES.all_subj_acc, 1);
    ANALYSIS.RES.median_subj_acc(:,:) = median_M'; clear median_M;
    
end % of if ANALYSIS.plot_robust

SE(:,:) = (std(ANALYSIS.RES.all_subj_acc,1))/(sqrt(ANALYSIS.nsbj));
ANALYSIS.RES.se_subj_acc(:,:) = SE'; clear SE;

if ANALYSIS.permstats == 2
    
    % OPTION 1: Use average results from random-labels test
    % Calculate average accuracy & standard error across subjects for permutation results
    M(:,:) = mean(ANALYSIS.RES.all_subj_perm_acc,1);
    ANALYSIS.RES.mean_subj_perm_acc(:,:) = M'; clear M;
    
    if ANALYSIS.plot_robust == 1 % If plotting trimmed mean for group-level stats
    % Calculate and store the trimmed mean of subject accuracies
        trimmed_M(:,:) = trimmean(ANALYSIS.RES.all_subj_perm_acc, ANALYSIS.plot_robust_trimming, 1);
        ANALYSIS.RES.trimmean_subj_perm_acc(:,:) = trimmed_M'; clear trimmed_M;
        
    elseif ANALYSIS.plot_robust == 2 % If plotting median for group-level stats
        
        median_M(:,:) = median(ANALYSIS.RES.all_subj_perm_acc, 1);
        ANALYSIS.RES.median_subj_perm_acc(:,:) = median_M'; clear median_M;
        
    end % of if ANALYSIS.plot_robust
    
    SE(:,:) = (std(ANALYSIS.RES.all_subj_perm_acc,1)) / (sqrt(ANALYSIS.nsbj));
    ANALYSIS.RES.se_subj_perm_acc(:,:) = SE'; clear SE;

    % OPTION 2: draw values from random-labels test
    % average permutation results across cross-validation steps, but draw later 
    % one for each participant for statistical testing!
    for subj = 1:ANALYSIS.nsbj
        for ana = 1:ANALYSIS.allna
            for step = 1:ANALYSIS.laststep
                
                temp(:,:) = ANALYSIS.RES.all_subj_perm_acc_reps(subj,ana,step,:,:);
                mtemp = mean(temp,1);
                ANALYSIS.RES.all_subj_perm_acc_reps_draw{subj,ana,step} = mtemp;
                clear mtemp;
                
                if ANALYSIS.plot_robust == 1 % If plotting trimmed mean for group-level stats
                    
                    trimmed_mtemp = trimmean(temp, ANALYSIS.plot_robust_trimming, 1);
                    ANALYSIS.RES.trimmean_all_subj_perm_acc_reps_draw{subj,ana,step} = trimmed_mtemp;  
                    clear trimmed_mtemp;
                    
                elseif ANALYSIS.plot_robust == 2 % If plotting median for group-level stats
                    
                    median_mtemp = median(temp, 1);
                    ANALYSIS.RES.median_all_subj_perm_acc_reps_draw{subj,ana,step} = median_mtemp;  
                    clear median_mtemp;
                    
                end % of if ANALYSIS.plot_robust
                clear temp; 
                
            end % step
        end % ana
    end % sbj

end % of if ANALYSIS.permstats == 2 statement

fprintf('All data from all subjects averaged.\n');

%% STATISTICAL TESTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________


if ANALYSIS.group_level_analysis == 1 % Group-level stats based on the minimum statistic
    
    [ANALYSIS] = min_statistic_classifier_accuracies(ANALYSIS);
    
elseif ANALYSIS.group_level_analysis == 2 % Group-level stats based on t tests
    
    [ANALYSIS] = t_tests_classifier_accuracies(ANALYSIS);

end % of if ANALYSIS.group_level_analysis





fprintf('All group statistics performed.\n');

%% FEATURE WEIGHT ANALYSIS
%__________________________________________________________________________

if ANALYSIS.fw.do == 1
    
    [FW_ANALYSIS] = analyse_feature_weights_erp(ANALYSIS);
    
else
    
    FW_ANALYSIS = [];
    
end


%% SAVE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

if size(dcg_todo,2) == 1 % Standard decoding analyses

    savename = [(SLIST.output_dir) study_name '_GROUPRES_NSBJ' num2str(ANALYSIS.nsbj) '_win'...
        num2str(ANALYSIS.window_width_ms) '_steps' num2str(ANALYSIS.step_width_ms)...
        '_av' num2str(ANALYSIS.avmode) '_st' num2str(ANALYSIS.stmode) '_' ANALYSIS.analysis_mode_label...
        '_DCG' SLIST.dcg_labels{ANALYSIS.dcg_todo} '.mat'];
    
elseif size(dcg_todo,2) == 2 % Cross-condition decoding analyses
    
    savename = [(SLIST.output_dir) study_name '_GROUPRES_NSBJ' num2str(ANALYSIS.nsbj) '_win'...
        num2str(ANALYSIS.window_width_ms) '_steps' num2str(ANALYSIS.step_width_ms)...
        '_av' num2str(ANALYSIS.avmode) '_st' num2str(ANALYSIS.stmode) '_' ANALYSIS.analysis_mode_label...
        '_DCG' SLIST.dcg_labels{ANALYSIS.dcg_todo(1)}...
        'toDCG' SLIST.dcg_labels{ANALYSIS.dcg_todo(2)} '.mat'];

end

save(savename,'ANALYSIS','FW_ANALYSIS','-v7.3');

fprintf('All results saved in %s. \n',savename);


%% PLOT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%__________________________________________________________________________

if ANALYSIS.disp.on == 1
    
    fprintf('Results will be plotted. \n');
    display_group_results_erp(ANALYSIS);
    
elseif ANALYSIS.disp.on ~= 1
    
    fprintf('No figures were produced for the results. \n');
    
end

%__________________________________________________________________________