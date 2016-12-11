function [ANALYSIS] = min_statistic_classifier_accuracies(ANALYSIS)
%
% This function organises data to use with the allefeld_algorithm.m
% function, which performs group-level fixed effects analyses and
% prevalence estimates using the minimum statistic, as described in
% Allefeld et al. (2016).
%
% Allefeld, C., Gorgen, K., Haynes, J.D. (2016). Valid population inference
% for information-based imaging: From the second-level t-test to prevalence
% inference. Neuroimage 141, 378-392.
%
%
% Inputs:
%
%   ANALYSIS            Structure containing organised data and analysis
%                       parameters set in analyse_decoding_erp
%
% Outputs:
%
%   ANALYSIS            Structure containing the data input to the function
%                       plus the results of the statistical analyses and
%                       the analysis parameters used in the test.
%
%
% Example:      % [ANALYSIS] = min_statistic_classifier_accuracies(ANALYSIS)
%
%
% Copyright (C) 2016 Daniel Feuerriegel and Contributors
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version. This program is distributed in the hope that
% it will be useful, but without any warranty; without even the implied
% warranty of merchantability or fitness for a particular purpose. See the
% GNU General Public License <http://www.gnu.org/licenses/> for more details.



% Get number of time windows, number of subject, number of permutations per
% subject
n_time_windows = size(ANALYSIS.RES.all_subj_perm_acc_reps_draw, 3);
n_subjects = size(ANALYSIS.RES.all_subj_perm_acc_reps_draw, 1);
n_permutations_per_subject = length(ANALYSIS.RES.all_subj_perm_acc_reps_draw{1, 1, 1});

for na = 1:size(ANALYSIS.RES.mean_subj_acc,1) % analysis

    % Get classification accuracies from the observed data: 
    % ANALYSIS.RES.all_subj_acc(subject, analysis, time_window)
    % and copy into a
    % matrix:  observed_data(time_window, subject)
    observed_data = squeeze(ANALYSIS.RES.all_subj_acc(:, na, :));
    observed_data = permute(observed_data, [2, 1]);

    % Get classification accuracies from permutation test data
    % ANALYSIS.RES.all_subj_perm_acc_reps_draw{subject, analysis , time_window}(1, permutation_number)
    % and copy into a matrix:
    % permtest_data(time_window, subject, permutation)
    
    permtest_data = NaN(n_time_windows, n_subjects, n_permutations_per_subject); % Preallocate
    
    for subject_no = 1:size(ANALYSIS.RES.all_subj_perm_acc_reps_draw, 1)
        for time_window = 1:size(ANALYSIS.RES.all_subj_perm_acc_reps_draw, 3)
            
            temp = ANALYSIS.RES.all_subj_perm_acc_reps_draw{subject_no, na, time_window};
            permtest_data(time_window, subject_no, :) = temp;
            
        end % of for time_window    
    end % of for subject_no

    % Run the algorithm in Allefeld et al. (2016) for global null and
    % prevalence testing using the minimum statistic and permutation testing
    [RESULTS, PARAMS] = allefeld_algorithm(observed_data, permtest_data, 'n_second_level_permutations', ANALYSIS.P2, 'alpha_level', ANALYSIS.pstats);
     
     % Extract p-values and check for statistical significance
     % Outputs from Results structure are vectors of lenght n_time_windows

     ANALYSIS.RES.p_minstat_uncorrected(na, :) = RESULTS.puGN; % Uncorrected for multiple comparisons
     ANALYSIS.RES.p_minstat_corrected(na, :) = RESULTS.pcGN; % Corrected for multiple comparisons

     % Significance testing
     ANALYSIS.RES.h_minstat_uncorrected(na, :) = zeros(1, n_time_windows); % Preallocate
     ANALYSIS.RES.h_minstat_corrected(na, :) = zeros(1, n_time_windows); % Preallocate
     
     ANALYSIS.RES.h_minstat_uncorrected(na, RESULTS.puGN < ANALYSIS.pstats) = 1;
     ANALYSIS.RES.h_minstat_corrected(na, RESULTS.pcGN < ANALYSIS.pstats) = 1;
     
     
     
     % Copy into generic (analysis-unspecific) matrices for p and h
     ANALYSIS.RES.p_uncorrected(na, :) = ANALYSIS.RES.p_minstat_uncorrected(na, :);
     ANALYSIS.RES.p_corrected(na, :) = ANALYSIS.RES.p_minstat_corrected(na, :);
     ANALYSIS.RES.h_uncorrected(na, :) = ANALYSIS.RES.h_minstat_uncorrected(na, :);
     ANALYSIS.RES.h_corrected(na, :) = ANALYSIS.RES.h_minstat_uncorrected(na, :);
     
     % Extract prevalence estimates (corrected and uncorrected for multiple
     % comparisons)
     ANALYSIS.RES.prevalence_lowerbound_uncorrected(na, :) = RESULTS.gamma0u;
     ANALYSIS.RES.prevalence_lowerbound_corrected(na, :) = RESULTS.gamma0c;
     
     % Copy PARAMS structure contents into ANALYSIS structure
     ANALYSIS.Min_Stat_Analysis_Parameters.n_time_windows(na) = PARAMS.n_time_windows;
     ANALYSIS.Min_Stat_Analysis_Parameters.N(na) = PARAMS.N; 
     ANALYSIS.Min_Stat_Analysis_Parameters.P1(na) = PARAMS.P1;
     ANALYSIS.Min_Stat_Analysis_Parameters.P2(na) = PARAMS.P2;
     ANALYSIS.Min_Stat_Analysis_Parameters.alpha_level(na) = PARAMS.alpha_level;
     ANALYSIS.Min_Stat_Analysis_Parameters.puMNMin(na) = PARAMS.puMNMin;
     ANALYSIS.Min_Stat_Analysis_Parameters.pcMNMin(na) = PARAMS.pcMNMin;
     ANALYSIS.Min_Stat_Analysis_Parameters.gamma0uMax(na) = PARAMS.gamma0uMax;
     ANALYSIS.Min_Stat_Analysis_Parameters.gamma0cMax(na) = PARAMS.gamma0cMax;  
     
end % of for na (loop through analyses)


% Marking h values (statistical significance) for plotting depending on whether using multiple
% comparisons corrections
 if ANALYSIS.minstat_multcomp == 1
     
     ANALYSIS.RES.h = ANALYSIS.RES.h_minstat_corrected;
     
 elseif ANALYSIS.minstate_multcomp == 0

     ANALYSIS.RES.h = ANALYSIS.RES.h_minstat_uncorrected;

 end % of if ANALYSIS.minstat_multcomp
