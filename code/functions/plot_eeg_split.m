function plot_eeg_split(file_path, channels_per_fig, save_dir, title_name)
% plot_eeg_split
% ============================================================
% .set形式のEEGデータを読み込み、
% 指定チャネル数ずつ原波形を分割してPNG保存する。
%
% 例：
%   plot_eeg_split(file_path, 20, save_dir, "Post MF");
%
% 入力
%   file_path        : .setファイルのパス
%   channels_per_fig : 1枚に表示するチャネル数
%                      省略時：20
%   save_dir         : Figure保存先
%                      省略時：.setファイルと同じフォルダ
%   title_name       : Figureタイトル
%                      例："Post MF"
%
% 表示仕様
%   ・最初の10秒
%   ・20chずつ表示
%   ・50 µV の振幅スケールバー
%   ・1 s の時間スケールバー
%   ・チャネル名を左側に表示
% ============================================================


%% ---------------------------------------------------------
% 引数の初期値
%% ---------------------------------------------------------

% 1枚あたりのチャネル数
if nargin < 2 || isempty(channels_per_fig)
    channels_per_fig = 20;
end

% 保存先
if nargin < 3 || isempty(save_dir)
    save_dir = fileparts(file_path);
end

% タイトル
if nargin < 4 || isempty(title_name)
    title_name = "";
end


%% ---------------------------------------------------------
% 保存フォルダ作成
%% ---------------------------------------------------------

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end


%% ---------------------------------------------------------
% EEG読み込み
%% ---------------------------------------------------------

EEG = pop_loadset(file_path);


%% ---------------------------------------------------------
% 基本情報
%% ---------------------------------------------------------

fs = EEG.srate;          % Sampling rate [Hz]
nChan = EEG.nbchan;      % チャネル数

% 表示する時間
duration = 10;           % [s]

% 表示サンプル数
nSample = min( ...
    round(duration * fs), ...
    size(EEG.data, 2) ...
);

% EEGデータ
data = double(EEG.data(:, 1:nSample));

% 時間軸
time = (0:nSample - 1) / fs;


%% ---------------------------------------------------------
% 表示設定
%% ---------------------------------------------------------

% チャネル間隔
spacing = 100;           % [µV]

% スケールバー
scale_uv = 50;           % [µV]
scale_sec = 1;           % [s]

% 線の太さ
wave_line_width = 1.0;

% Figureサイズ
fig_position = [ ...
    100, ...     % x
    100, ...     % y
    1500, ...    % width
    1000 ...     % height
];


%% ---------------------------------------------------------
% ファイル名取得
%% ---------------------------------------------------------

[~, base_name, ~] = fileparts(file_path);


%% ---------------------------------------------------------
% 指定チャネル数ずつFigure作成
%% ---------------------------------------------------------

for start_ch = 1:channels_per_fig:nChan

    %% 今回表示するチャネル

    end_ch = min( ...
        start_ch + channels_per_fig - 1, ...
        nChan ...
    );

    ch_idx = start_ch:end_ch;

    nPlot = length(ch_idx);


    %% -----------------------------------------------------
    % Figure作成
    %% -----------------------------------------------------

    fig = figure( ...
        'Color', 'w', ...
        'Position', fig_position ...
    );

    hold on;


    %% -----------------------------------------------------
    % EEG波形描画
    %% -----------------------------------------------------

    for i = 1:nPlot

        ch = ch_idx(i);

        % ch番号が若いものを上に表示
        offset = (nPlot - i) * spacing;

        plot( ...
            time, ...
            data(ch, :) + offset, ...
            'k', ...
            'LineWidth', wave_line_width ...
        );

    end


    %% -----------------------------------------------------
    % チャネルラベル
    %% -----------------------------------------------------

    % yticksは昇順で指定する必要がある
    y_positions = (0:nPlot - 1) * spacing;

    yticks(y_positions);


    % チャネル名取得
    if ~isempty(EEG.chanlocs)

        labels = {EEG.chanlocs(ch_idx).labels};

    else

        % chanlocsがない場合
        labels = arrayfun( ...
            @(x) sprintf('Ch%d', x), ...
            ch_idx, ...
            'UniformOutput', false ...
        );

    end


    % 下→上のtickに合わせるためラベルを逆順
    yticklabels(fliplr(labels));


    %% -----------------------------------------------------
    % 軸設定
    %% -----------------------------------------------------

    xlabel( ...
        'Time (s)', ...
        'FontSize', 14 ...
    );

    ylabel( ...
        'Channel', ...
        'FontSize', 14 ...
    );

    xlim([0 duration]);


    % 上と下に少し余白を作る
    bottom_margin = spacing * 2.0;
    top_margin = spacing * 2.0;

    ylim([ ...
        -bottom_margin, ...
        (nPlot - 1) * spacing + top_margin ...
    ]);


    %% -----------------------------------------------------
    % タイトル
    %% -----------------------------------------------------

    if strlength(title_name) > 0

        title( ...
            sprintf( ...
                '%s   Ch%d-%d', ...
                title_name, ...
                start_ch, ...
                end_ch ...
            ), ...
            'FontSize', 16, ...
            'FontWeight', 'bold' ...
        );

    else

        title( ...
            sprintf( ...
                'Ch%d-%d', ...
                start_ch, ...
                end_ch ...
            ), ...
            'FontSize', 16, ...
            'FontWeight', 'bold' ...
        );

    end


    %% -----------------------------------------------------
    % スケールバーの位置
    %% -----------------------------------------------------

    % 右上に配置
    scale_x_start = duration - 1.5;

    scale_y_base = ...
        (nPlot - 1) * spacing + spacing * 1.0;


    %% -----------------------------------------------------
    % 振幅スケールバー：50 µV
    %% -----------------------------------------------------

    plot( ...
        [scale_x_start scale_x_start], ...
        [scale_y_base scale_y_base + scale_uv], ...
        'k', ...
        'LineWidth', 4 ...
    );


    % 50 µV の文字
    text( ...
        scale_x_start - 0.15, ...
        scale_y_base + scale_uv / 2, ...
        sprintf('%d \\muV', scale_uv), ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 18, ...
        'FontWeight', 'bold' ...
    );


    %% -----------------------------------------------------
    % 時間スケールバー：1秒
    %% -----------------------------------------------------

    scale_x_end = scale_x_start + scale_sec;

    plot( ...
        [scale_x_start scale_x_end], ...
        [scale_y_base scale_y_base], ...
        'k', ...
        'LineWidth', 4 ...
    );


    % 1 s の文字
    text( ...
        scale_x_start + scale_sec / 2, ...
        scale_y_base - spacing * 0.35, ...
        sprintf('%d s', scale_sec), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 18, ...
        'FontWeight', 'bold' ...
    );


    %% -----------------------------------------------------
    % Figureの見た目
    %% -----------------------------------------------------

    ax = gca;

    ax.FontSize = 12;

    % 上と右の枠線を消す
    box off;

    % 背景
    ax.Color = 'w';

    % gridなし
    grid off;


    %% -----------------------------------------------------
    % PNG保存
    %% -----------------------------------------------------

    save_name = sprintf( ...
        '%s_Ch%02d-%02d.png', ...
        base_name, ...
        start_ch, ...
        end_ch ...
    );

    save_path = fullfile( ...
        save_dir, ...
        save_name ...
    );


    exportgraphics( ...
        fig, ...
        save_path, ...
        'Resolution', 300 ...
    );


    fprintf( ...
        'Saved: %s\n', ...
        save_path ...
    );


    %% -----------------------------------------------------
    % Figureを閉じる
    %% -----------------------------------------------------

    close(fig);

end


fprintf('EEG plotting finished.\n');

end