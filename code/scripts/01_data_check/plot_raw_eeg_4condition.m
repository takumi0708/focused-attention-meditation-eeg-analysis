%{
10/1 中間発表のパワポの画像のため
%}

%% plot_raw_eeg_4conditions.m
% sub-001 の4条件について
% 最初の20ch・最初の10秒を表示してPNG保存する

clear;
clc;


%% ========================================
% 1. プロジェクト設定
% =========================================

project_root = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis';

subject = 'sub-001';


%% ========================================
% 2. 4条件
% =========================================

file_paths = {

    % pre MF
    fullfile( ...
        project_root, ...
        'data', 'preprocessed', subject, 'pre', ...
        sprintf( ...
        '%s_ses-premedita_task-slMedita_eeg_preproc_icrm.set', ...
        subject))

    % post MF
    fullfile( ...
        project_root, ...
        'data', 'preprocessed', subject, 'post', ...
        sprintf( ...
        '%s_ses-posmedita_task-slMedita_eeg_preproc_icrm.set', ...
        subject))

    % pre MW
    fullfile( ...
        project_root, ...
        'data', 'preprocessed', subject, 'pre', ...
        sprintf( ...
        '%s_ses-premedita_task-restCE01_eeg_preproc_icrm.set', ...
        subject))

    % post MW
    fullfile( ...
        project_root, ...
        'data', 'preprocessed', subject, 'post', ...
        sprintf( ...
        '%s_ses-posmedita_task-restCE01_eeg_preproc_icrm.set', ...
        subject))
};


condition_names = {
    'pre_MF'
    'post_MF'
    'pre_MW'
    'post_MW'
};


condition_titles = {
    'Pre MF'
    'Post MF'
    'Pre MW'
    'Post MW'
};


%% ========================================
% 3. 保存先
% =========================================

save_dir = fullfile( ...
    project_root, ...
    'results', ...
    'raw_waveform', ...
    subject);


if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end


%% ========================================
% 4. 表示設定
% =========================================

sec = 10;

channel_idx = 1:20;

% チャンネル間隔
spacing = 50;

% フォント
title_font_size = 18;
axis_label_font_size = 18;
tick_font_size = 11;

% スケールバー
scale_time = 1;      % 1秒
scale_amp  = 50;     % 50 µV

scale_bar_line_width = 4;
scale_bar_font_size  = 18;


%% ========================================
% 5. 4条件を処理
% =========================================

for c = 1:length(file_paths)

    fprintf('\n%s\n', condition_names{c});


    %% ----------------------------
    % EEG読み込み
    % -----------------------------

    [file_dir, file_name, file_ext] = ...
        fileparts(file_paths{c});


    EEG = pop_loadset( ...
        'filename', [file_name file_ext], ...
        'filepath', file_dir);


    %% ----------------------------
    % 最初の20ch
    % -----------------------------

    channel_labels = ...
        {EEG.chanlocs(channel_idx).labels};


    %% ----------------------------
    % 最初の10秒
    % -----------------------------

    fs = EEG.srate;

    n_samples = round(sec * fs);


    data = double( ...
        EEG.data( ...
        channel_idx, ...
        1:n_samples));


    time = (0:n_samples-1) / fs;


    %% ========================================
    % Figure
    % =========================================

    fig = figure( ...
        'Color', 'w', ...
        'Position', [100 100 1100 750], ...
        'Visible', 'on');


    hold on;


    %% ----------------------------
    % 20ch描画
    % -----------------------------

    for i = 1:length(channel_idx)

        % Ch1を一番上にする
        y_position = ...
            (length(channel_idx) - i) * spacing;


        signal = data(i, :);


        plot( ...
            time, ...
            signal + y_position, ...
            'k', ...
            'LineWidth', 1);

    end


    %% ----------------------------
    % Y軸
    % -----------------------------

    y_positions = ...
        (0:length(channel_idx)-1) * spacing;


    yticks(y_positions);

    % 下からCh20→Ch1になるためラベルを反転
    yticklabels(fliplr(channel_labels));


    %% ----------------------------
    % Figure設定
    % -----------------------------

    xlabel( ...
        'Time (s)', ...
        'FontSize', axis_label_font_size, ...
        'FontWeight', 'bold');

    ylabel( ...
        'Channel', ...
        'FontSize', axis_label_font_size, ...
        'FontWeight', 'bold');

    title( ...
        sprintf('%s  Ch1-20', condition_titles{c}), ...
        'FontSize', title_font_size, ...
        'FontWeight', 'bold');


    ax = gca;

    ax.FontSize = tick_font_size;
    ax.LineWidth = 1;


    xlim([0 sec]);

    % スケールバー用に下側へ余白
    ylim([ ...
        -120, ...
        (length(channel_idx)-1) * spacing + 100 ...
        ]);


%% ========================================
% スケールバー
% =========================================

scale_time = 1;      % 1秒
scale_amp  = 50;     % 50 µV

% 右上の空白部分に配置
scale_x = 8.5;
scale_y = 1020;

% 横：1秒
plot( ...
    [scale_x, scale_x + scale_time], ...
    [scale_y, scale_y], ...
    'k', ...
    'LineWidth', 4);

% 縦：50 µV
plot( ...
    [scale_x, scale_x], ...
    [scale_y, scale_y + scale_amp], ...
    'k', ...
    'LineWidth', 4);

% 「1 s」
text( ...
    scale_x + scale_time/2, ...
    scale_y - 20, ...
    '1 s', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'top', ...
    'FontSize', 18, ...
    'FontWeight', 'bold');

% 「50 µV」
text( ...
    scale_x - 0.12, ...
    scale_y + scale_amp/2, ...
    '50 \muV', ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'middle', ...
    'FontSize', 18, ...
    'FontWeight', 'bold');

    box off;

    hold off;


    %% ========================================
    % PNG保存
    % =========================================

    save_name = sprintf( ...
        '%s_%s_Ch1-20.png', ...
        subject, ...
        condition_names{c});


    save_path = fullfile( ...
        save_dir, ...
        save_name);


    exportgraphics( ...
        fig, ...
        save_path, ...
        'Resolution', 300);


    fprintf('Saved : %s\n', save_path);

end


fprintf('\n4 conditions completed.\n');