function save_eeg_waveforms(EEG, save_dir, file_prefix, sec, channels_per_fig)

%{
save_eeg_waveforms
EEG波形を指定チャネル数ごとに分割して保存する関数

入力
------------------------------------------------
EEG               : EEGLABのEEG構造体
save_dir          : 保存先フォルダ
file_prefix       : 保存ファイル名の先頭
sec               : 表示する秒数
channels_per_fig  : 1枚に表示するチャネル数

例
------------------------------------------------
save_eeg_waveforms( ...
    preica_eeg, ...
    save_dir, ...
    'sub-001_pre_slMedita_preica', ...
    10, ...
    20);
%}


%% ========================================
% 保存先フォルダ作成
% =========================================

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end


%% ========================================
% 基本情報
% =========================================

fs = EEG.srate;
nChan = EEG.nbchan;

% 表示するサンプル数
nSample = round(sec * fs);

% データ長を超えないようにする
nSample = min(nSample, EEG.pnts);

% 実際の表示時間
actual_sec = nSample / fs;

% Figure数
nGroup = ceil(nChan / channels_per_fig);


%% ========================================
% 使用する脳波
% =========================================

data = double(EEG.data(:, 1:nSample));

% 時間軸
t = (0:nSample-1) / fs;


%% ========================================
% 全チャネル共通の表示間隔を決める
% =========================================

% 各チャネルの標準偏差
channel_std = std(data, 0, 2);

% 極端なチャネルの影響を受けにくいよう中央値を使う
offset = median(channel_std) * 6;

% offsetが異常に小さい場合の保険
if offset <= 0
    offset = 50;
end


%% ========================================
% channels_per_fig ずつ描画
% =========================================

for g = 1:nGroup

    % 今回表示するチャネル番号
    ch_start = (g - 1) * channels_per_fig + 1;
    ch_end   = min(g * channels_per_fig, nChan);

    ch_idx = ch_start:ch_end;

    nCurrentChan = length(ch_idx);


    %% Figure作成

    fig = figure( ...
        'Position', [100 100 1400 900], ...
        'Visible', 'off');

    hold on;


    %% 各チャネル描画

    for i = 1:nCurrentChan

        ch = ch_idx(i);

        % 上からch_start → ch_endになるように配置
        y_offset = (nCurrentChan - i) * offset;

        plot(t, data(ch, :) + y_offset, 'k');

    end

    hold off;


    %% ========================================
    % 軸設定
    % =========================================

    % チャネル名
    labels = {EEG.chanlocs(ch_idx).labels};

    % Y軸位置
    y_positions = (0:nCurrentChan-1) * offset;

    yticks(y_positions);

    % 上下が逆なので反転
    yticklabels(flip(labels));

    xlabel('Time (s)');
    ylabel('Channel');

    xlim([0 actual_sec]);

    title(sprintf( ...
        '%s | Channel %d-%d', ...
        file_prefix, ...
        ch_start, ...
        ch_end), ...
        'Interpreter', 'none');

    grid on;


    %% ========================================
    % 保存
    % =========================================

    filename = sprintf( ...
        '%s_ch%02d-%02d.png', ...
        file_prefix, ...
        ch_start, ...
        ch_end);

    exportgraphics( ...
        fig, ...
        fullfile(save_dir, filename), ...
        'Resolution', 300);

    close(fig);

end


%% 完了表示

fprintf('EEG waveform saved: %s\n', save_dir);

end

%% 実際に関数を使ってみる
%{
9/5作成

sub-001 の slMedita pre の preica を読み込み、
最初の10秒を20chずつ画像保存する
%}


%% ========================================
% データの読み込み
% =========================================

pre_data_dir = ...
    'C:\Users\zhang\OneDrive\Desktop\EEG_analysis\focused-attention-meditation-eeg-analysis\data\derivatives\eeglab_preproc\sub-001\ses-premedita\eeg';

preica_eeg = pop_loadset( ...
    'filename', ...
    'sub-001_ses-premedita_task-slMedita_eeg_preproc_preica.set', ...
    'filepath', ...
    pre_data_dir);


%% ========================================
% 保存先
% =========================================

save_dir = ...
    'C:\Users\zhang\OneDrive\Desktop\EEG_analysis\focused-attention-meditation-eeg-analysis\code\被験者1分析\figure';


%% ========================================
% 原波形を20chずつ保存
% =========================================

save_eeg_waveforms( ...
    preica_eeg, ...
    save_dir, ...
    'sub-001_pre_slMedita_preica', ...
    10, ...     % 表示時間：10秒
    20);        % 1枚あたり20ch