%% ==========================================
% L-FAME 64ch 電極配置図
% ==========================================

clear;
clc;

%% ------------------------------------------
% ファイル指定
% -------------------------------------------

file_path = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis\data\processed\sub-001\pre';

file_name = ...
    'sub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.set';


%% ------------------------------------------
% EEG読み込み
% -------------------------------------------

EEG = pop_loadset( ...
    'filename', file_name, ...
    'filepath', file_path);


%% ------------------------------------------
% 電極配置図
% -------------------------------------------

figure( ...
    'Name', 'L-FAME 64ch Electrode Layout', ...
    'Color', 'w');

topoplot( ...
    zeros(1, EEG.nbchan), ...
    EEG.chanlocs, ...
    'style', 'blank', ...
    'electrodes', 'labels');

title( ...
    'L-FAME EEG Electrode Layout', ...
    'FontSize', 16, ...
    'FontWeight', 'bold');


%% ------------------------------------------
% PDF保存
% -------------------------------------------

exportgraphics( ...
    gcf, ...
    'L_FAME_64ch_electrode_layout.pdf', ...
    'ContentType', 'vector');