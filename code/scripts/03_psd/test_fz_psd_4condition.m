%% test_fz_psd_4conditions.m
% sub-001 / Fz
% pre-MF, post-MF, pre-MW, post-MW のPSDを比較する

clear;
clc;

%% 1. データファイル

base_dir = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis\data\preprocessed\sub-001';

file_paths = {
    fullfile(base_dir, 'pre', ...
    'sub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.set')

    fullfile(base_dir, 'post', ...
    'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm.set')

    fullfile(base_dir, 'pre', ...
    'sub-001_ses-premedita_task-restCE01_eeg_preproc_icrm.set')

    fullfile(base_dir, 'post', ...
    'sub-001_ses-posmedita_task-restCE01_eeg_preproc_icrm.set')
};

condition_names = {
    'pre-MF'
    'post-MF'
    'pre-MW'
    'post-MW'
};


%% 2. Figureを作成

figure;
hold on;


%% 3. 4条件を順番に処理

for i = 1:length(file_paths)

    % EEG読み込み
    EEG = pop_loadset(file_paths{i});

    % Fzのチャネル番号を取得
    labels = {EEG.chanlocs.labels};
    fz_idx = find(strcmpi(labels, 'Fz'));

    if isempty(fz_idx)
        error('Fzが見つかりません');
    end

    % Fzの波形
    fz_data = double(EEG.data(fz_idx, :));

    % サンプリング周波数
    fs = EEG.srate;


    %% Welch PSD

    window_sec = 4.096;

    window_samples = round(window_sec * fs);
    overlap_samples = floor(window_samples / 2);
    nfft = window_samples;

    [Pxx, f] = pwelch( ...
        fz_data, ...
        hamming(window_samples), ...
        overlap_samples, ...
        nfft, ...
        fs);


    %% 1～45 Hzのみ表示

    idx = f >= 1 & f <= 45;

    plot( ...
        f(idx), ...
        Pxx(idx), ...
        'LineWidth', 1.2);

end


%% 4. グラフ設定

xlabel('Frequency (Hz)');
ylabel('PSD (\muV^2/Hz)');

title('sub-001 / Fz');

legend(condition_names, ...
    'Location', 'northeast');

xlim([1 45]);

grid on;
hold off;



