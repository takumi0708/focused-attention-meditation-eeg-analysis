function plot_current_psd( ...
    EEG, ...
    eegFig, ...
    psdChannelMenu, ...
    subject, ...
    session, ...
    condition)

% =========================================================
% eegplotで現在表示している区間のPSDを表示する
%
% Input
%   EEG             : EEGLAB EEG構造体
%   eegFig          : eegplotのFigure
%   psdChannelMenu  : Channel選択メニュー
%   subject         : Subject名
%   session         : pre / post
%   condition       : 条件名
% =========================================================


%% =========================================================
% eegplotが存在するか確認
% ==========================================================

if ~isgraphics(eegFig)

    return;

end


%% =========================================================
% eegplotの現在位置
% ==========================================================

g = get( ...
    eegFig, ...
    'UserData');


start_sec = g.time;

duration_sec = g.winlength;


%% =========================================================
% 選択Channel
% ==========================================================

channel_labels = string({EEG.chanlocs.labels});


channel_idx = ...
    psdChannelMenu.Value;


selected_channel = ...
    channel_labels(channel_idx);


%% =========================================================
% sample番号
% ==========================================================

fs = EEG.srate;

% MATLABは1スタートより
start_sample = ...
    round(start_sec * fs) + 1;


end_sample = ...
    start_sample + ...
    round(duration_sec * fs) - 1;


% データ範囲を超えないように補正
start_sample = max( ...
    start_sample, ...
    1);


end_sample = min( ...
    end_sample, ...
    EEG.pnts);


%% =========================================================
% 現在区間の1chを取得
% ==========================================================

signal = double( ...
    EEG.data( ...
        channel_idx, ...
        start_sample:end_sample));


%% =========================================================
% Welch法
% ==========================================================

% Welch法で使う1区間の長さ
window_sec = 2;


window_length = ...
    round(window_sec * fs);


% EEG区間より長くならないようにする
window_length = min( ...
    window_length, ...
    length(signal));


% Hamming窓
window = ...
    hamming(window_length);


% 50% overlap
noverlap = ...
    floor(window_length * 0.5);


% FFT点数
nfft = max( ...
    512, ...
    2^nextpow2(window_length));


% PSD計算
[pxx, freq] = pwelch( ...
    signal, ...
    window, ...
    noverlap, ...
    nfft, ...
    fs);


%% =========================================================
% 1～45 Hzだけ使用
% ==========================================================

idx = ...
    freq >= 1 & ...
    freq <= 45;


freq_plot = ...
    freq(idx);


psd_plot = ...
    pxx(idx);


%% =========================================================
% PSD Figure
% ==========================================================

psdFig = figure( ...
    'Name', ...
    char( ...
        selected_channel + ...
        " PSD | " + ...
        subject + ...
        " / " + ...
        session + ...
        " / " + ...
        condition), ...
    'NumberTitle', 'off');


psdFig.Position(3) = 900;

psdFig.Position(4) = 550;


movegui( ...
    psdFig, ...
    'center');


%% =========================================================
% 描画
% ==========================================================

plot( ...
    freq_plot, ...
    psd_plot, ...
    'LineWidth', 1.5);


xlabel('Frequency [Hz]');

ylabel('PSD [\muV^2/Hz]');


title( ...
    selected_channel + ...
    " PSD | " + ...
    num2str(start_sec, '%.3f') + ...
    " - " + ...
    num2str( ...
        start_sec + duration_sec, ...
        '%.3f') + ...
    " sec");


xlim([1 45]);

grid on;


%% =========================================================
% 周波数帯域境界
% ==========================================================

xline(4,  '--', 'δ / θ');

xline(8,  '--', 'θ / α');

xline(13, '--', 'α / β');

xline(30, '--', 'β / γ');

end