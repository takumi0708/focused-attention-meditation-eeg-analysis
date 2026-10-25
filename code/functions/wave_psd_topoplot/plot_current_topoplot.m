function plot_current_topoplot( ...
    EEG, ...
    eegFig, ...
    bandMenu, ...
    subject, ...
    session, ...
    condition)

% =========================================================
% eegplotで現在表示している区間について
% 指定周波数帯域のTopoplotを表示する
%
% Input
%   EEG       : EEGLAB EEG構造体
%   eegFig    : eegplotのFigure
%   bandMenu  : Band選択メニュー
%   subject   : Subject名
%   session   : pre / post
%   condition : 条件名
%
% 出力
%   なし
%
% 処理
%   1. eegplotの現在表示区間を取得
%   2. 選択した周波数帯を取得
%   3. 各ChannelについてWelch法でPSDを計算
%   4. 指定帯域を積分してBand Power [μV^2]を計算
%   5. Topoplotで頭皮分布を表示
% =========================================================


%% =========================================================
% eegplotが存在するか確認
% ==========================================================

if ~isgraphics(eegFig)

    return;

end


%% =========================================================
% eegplotの現在表示区間
% ==========================================================

g = get( ...
    eegFig, ...
    'UserData');


start_sec = g.time;

duration_sec = g.winlength;

fs = EEG.srate;


%% =========================================================
% sample番号
% ==========================================================

start_sample = ...
    round(start_sec * fs) + 1;


end_sample = ...
    start_sample + ...
    round(duration_sec * fs) - 1;


% EEGデータの範囲外にならないように補正
start_sample = max( ...
    start_sample, ...
    1);


end_sample = min( ...
    end_sample, ...
    EEG.pnts);


%% =========================================================
% Band選択
% ==========================================================

band_idx = bandMenu.Value;


switch band_idx

    case 1

        band_name = "Delta";

        band_range = [1 4];


    case 2

        band_name = "Theta";

        band_range = [4 8];


    case 3

        band_name = "Alpha";

        band_range = [8 13];


    case 4

        band_name = "Beta";

        band_range = [13 30];


    case 5

        band_name = "Gamma";

        band_range = [30 45];

end


%% =========================================================
% 現在表示している区間を全Channelまとめて取得
% ==========================================================

segment = double( ...
    EEG.data( ...
        :, ...
        start_sample:end_sample));


%% =========================================================
% Welch法の設定
% ==========================================================

% 1つのWelch windowの長さ
window_sec = 2;


window_length = ...
    round(window_sec * fs);


% 現在区間より長くならないようにする
window_length = min( ...
    window_length, ...
    size(segment, 2));


% Hamming window
window = ...
    hamming(window_length);


% 50% overlap
noverlap = ...
    floor(window_length * 0.5);


% FFT点数
nfft = max( ...
    512, ...
    2^nextpow2(window_length));


%% =========================================================
% 各ChannelのBand Power
% ==========================================================

band_power = zeros( ...
    EEG.nbchan, ...
    1);


for ch = 1:EEG.nbchan

    %% -----------------------------------------------------
    % ch番目の波形を取得
    % ------------------------------------------------------

    signal = ...
        segment(ch, :);


    %% -----------------------------------------------------
    % PSD計算
    % ------------------------------------------------------

    [pxx, freq] = pwelch( ...
        signal, ...
        window, ...
        noverlap, ...
        nfft, ...
        fs);


    %% -----------------------------------------------------
    % 対象周波数帯
    % ------------------------------------------------------

    idx = ...
        freq >= band_range(1) & ...
        freq <= band_range(2);


    %% -----------------------------------------------------
    % Band Power
    %
    % pxxの単位
    %   μV^2 / Hz
    %
    % 周波数方向に積分することで
    %   μV^2
    % にする
    % ------------------------------------------------------

    band_power(ch) = ...
        trapz( ...
            freq(idx), ...
            pxx(idx));

end


%% =========================================================
% Topoplotに使用しないChannel
% ==========================================================

exclude_labels = [ ...
    "FT9", ...
    "FT10", ...
    "TP9", ...
    "TP10", ...
    "PO9", ...
    "PO10" ...
];


channel_labels = ...
    string({EEG.chanlocs.labels});


use_idx = ~ismember( ...
    channel_labels, ...
    exclude_labels);


%% =========================================================
% カラースケール
% ==========================================================

% 現在表示しているChannelの最大値
max_power = ...
    max(band_power(use_idx));


% Band Powerは0以上なので
% 0 ～ 最大値をカラースケールにする
map_limits = ...
    [0 max_power];


%% =========================================================
% Topoplot Figure
% ==========================================================

topoFig = figure( ...
    'Name', ...
    char( ...
        band_name + ...
        " Topoplot | " + ...
        subject + ...
        " / " + ...
        session + ...
        " / " + ...
        condition), ...
    'NumberTitle', ...
    'off');


topoFig.Position(3) = 650;

topoFig.Position(4) = 600;


movegui( ...
    topoFig, ...
    'center');


%% =========================================================
% Topoplot
% ==========================================================

topoplot( ...
    band_power(use_idx), ...
    EEG.chanlocs(use_idx), ...
    'electrodes', ...
    'on', ...
    'maplimits', ...
    map_limits);


%% =========================================================
% Colorbar
% ==========================================================

cb = colorbar;


cb.Label.String = ...
    'Band Power [\muV^2]';


%% =========================================================
% Title
% ==========================================================

title( ...
    band_name + ...
    " " + ...
    num2str(band_range(1)) + ...
    "-" + ...
    num2str(band_range(2)) + ...
    " Hz | " + ...
    num2str(start_sec, '%.3f') + ...
    " - " + ...
    num2str( ...
        start_sec + duration_sec, ...
        '%.3f') + ...
    " sec");

end