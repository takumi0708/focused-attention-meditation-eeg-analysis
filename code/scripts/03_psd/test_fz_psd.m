%% test_fz_psd.m
% sub-001 / pre-MF / Fz のPSDを確認する

clear;
clc;

%% 1. データファイル


data_dir = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis\data\preprocessed\sub-001\pre';

file_name = ...
    'sub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.set';

%% 2. EEG読み込み

EEG = pop_loadset( ...
    'filename', file_name, ...
    'filepath', data_dir);


%% 3. Fzを探す

labels = {EEG.chanlocs.labels};

fz_idx = find(strcmpi(labels, "Fz"));

if isempty(fz_idx)
    error("Fzが見つかりません");
end

fprintf("Fz : channel %d\n", fz_idx);

%% 4. Fzの波形を取得

fz_data = double(EEG.data(fz_idx, :));

fs = EEG.srate;

fprintf("Sampling rate : %.1f Hz\n", fs);
fprintf("Samples       : %d\n", length(fz_data));

%% 5. Welch PSD

window_sec = 4.096;

window_samples  = round(window_sec * fs);
overlap_samples = floor(window_samples / 2);
nfft            = window_samples;

[Pxx, f] = pwelch( ...
    fz_data, ...
    hamming(window_samples), ...
    overlap_samples, ...
    nfft, ...
    fs);

%% 6. 1～45 Hzを表示
idx = f >= 1 & f <= 45;

figure;
plot(f(idx), Pxx(idx), ...
    'LineWidth', 1.2);

xlabel('Frequency (Hz)');
ylabel('PSD (\muV^2/Hz)');
title('sub-001 / pre-MF / Fz');

xlim([1 45]);
grid on;