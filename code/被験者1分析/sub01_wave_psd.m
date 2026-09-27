clear;
clc;
close all;

data_dir = 'C:\MATLAB\focused-attention-meditation-eeg-analysis\data\sub-001\post';

EEG = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-restCE01_eeg_preproc_icrm (1).set', ...
    'filepath', data_dir);

% 10秒ごとに分割
epoches = divide_epoches(EEG, 10);

% サイズ確認
size(epoches)

% 保存先
save_dir = "figure";

% Fzの原波形
plot_wave(epoches, EEG, "Fz", save_dir);

% FzのPSD
plot_psd(epoches, EEG, "Fz", save_dir);