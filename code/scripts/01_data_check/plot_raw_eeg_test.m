%% plot_raw_eeg_test.m
% sub-001 / pre MF の原波形を10秒表示
% Ch1を一番上、Ch20を一番下に表示する

clear;
clc;


%% ========================================
% 1. プロジェクト設定
% =========================================

project_root = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis';


%% ========================================
% 2. EEGファイル
% =========================================

subject = 'sub-001';

data_dir = fullfile( ...
    project_root, ...
    'data', ...
    'preprocessed', ...
    subject, ...
    'pre');


file_name = ...
    'sub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.set';


%% ========================================
% 3. EEG読み込み
% =========================================

EEG = pop_loadset( ...
    'filename', file_name, ...
    'filepath', data_dir);


fprintf('Sampling rate : %.1f Hz\n', EEG.srate);
fprintf('Channels      : %d\n', EEG.nbchan);
fprintf('Samples       : %d\n', EEG.pnts);


%% ========================================
% 4. 最初の20chを取得
% =========================================

channel_idx = 1:20;

channel_labels = ...
    {EEG.chanlocs(channel_idx).labels};


% 確認
disp(channel_labels');


%% ========================================
% 5. 最初の10秒を取得
% =========================================

sec = 10;

fs = EEG.srate;

n_samples = sec * fs;

data = double( ...
    EEG.data(channel_idx, 1:n_samples));


% 時間軸
time = (0:n_samples-1) / fs;


%% ========================================
% 6. 表示用スケール
% =========================================
% 各チャネルの波形が重ならないように
% チャネル間隔を決める

spacing = 50;


%% ========================================
% 7. 原波形を描画
% =========================================

figure( ...
    'Color', 'w', ...
    'Position', [100 100 1000 650]);

hold on;


for i = 1:length(channel_idx)

    % Ch1を一番上にする
    y_position = ...
        (length(channel_idx) - i) * spacing;

    signal = data(i, :);

    plot( ...
        time, ...
        signal + y_position, ...
        'k');

end


%% ========================================
% 8. Y軸
% =========================================

% 波形を置いた位置
y_positions = ...
    (0:length(channel_idx)-1) * spacing;


yticks(y_positions);


% Y軸は下からCh20 → Ch1なので
% ラベルを逆順にする
yticklabels(fliplr(channel_labels));


%% ========================================
% 9. Figure設定
% =========================================

xlabel('Time (s)');
ylabel('Channel');

title('Pre MF  Ch1-20');

xlim([0 sec]);

box off;

hold off;