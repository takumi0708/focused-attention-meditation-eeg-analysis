%% sub-001をfftする

clear;
clc;

%% フォルダ
data_dir = ...
    'C:\Users\zhang\OneDrive\ドキュメント\MATLAB\meditaion_anylysis\fucus-meditation-eeg\focused-attention-meditation-eeg-analysis\data\preprocessed\sub-001\ses-posmedita\eeg';


% 自作した処理済みデータ
EEG = pop_loadset( ...
    'filename', 'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm_my.set', ...
    'filepath', data_dir);

fs = EEG.srate;      % サンプリング周波数
nChan = EEG.nbchan;  % チャネル数

fprintf("sampling rate = %d Hz\n", fs);
fprintf("channels = %d\n", nChan);

%%  FFT解析
%{
10秒ごとにエポック化
各エポックごとにWelch法を適用
epoch 平均（被験者平均PSD）
原波形 / 絶対PSD / 相対PSD の Figure を作る
%}

% 10秒ごとにエポック化するための事前準備
fs = EEG.srate;          % サンプリング周波数
nChan = EEG.nbchan;      % チャネル数

epoch_sec = 10;          % 10秒
epoch_samples = fs * epoch_sec; % 1エポックあたりのサンプル数

% 総サンプル数 EEG.dataはチャネル × 時間サンプルより
nSamples = size(EEG.data, 2);

% 作れる10秒エポック数
nEpoch = floor(nSamples / epoch_samples);

fprintf("10秒エポック数: %d\n", nEpoch);

%% 10秒ごとにエポック化

% ch x サンプル数 x エポック の配列
epochs = zeros(nChan, epoch_samples, nEpoch);

for ep = 1:nEpoch

    % ep番目の開始位置（2ep ならepoch_sample+1から）
    start_idx = (ep-1) * epoch_samples + 1;

    end_idx = ep * epoch_samples;

    % 切り出し
    epochs(:, :, ep) = EEG.data(:, start_idx:end_idx);
end

%% 各エポックごとにWelch法を適用

% 1エポック目・1チャネルでfを作成
x = double(epochs(1,:,1));

% powerとfのベクトルがそれぞれ作成
% 設定は標準にしてる
[power, f] = pwelch(x, [], [], [], fs);

% 今回は1～45 Hzを使用
freq_idx = (f >= 1) & (f <= 45);

% 使用する周波数軸
f_use = f(freq_idx);

% 周波数の点の数
nFreq = length(f_use);

%% PSDを保存する配列準備

% 行：f 列：chnnel 

PSD_all = zeros(nFreq, nChan, nEpoch);

%% 全エポック × 全チャネルでWelch法

for ep = 1:nEpoch
    for ch = 1:nChan
        
        x = double(epochs(ch,:,ep));

        % Welch法
        [power, f] = pwelch(x, [], [], [], fs);
        % 行にpowerベクトル入れてる
        PSD_all(:, ch, ep) = power(freq_idx);

    end
end

fprintf("Welch PSD計算完了\n");
fprintf("PSDサイズ: %d周波数 × %dチャネル × %dエポック\n", ...
    nFreq, nChan, nEpoch);




%% epoch 平均（被験者平均PSD）
% epoch方向について平均する

% 絶対PSD
mean_PSD = mean(PSD_all, 3);

% 相対PSD

%{
相対PSDについて
-> 各周波数のPSD / 1～45Hz全体の合計
%}

for ep = 1:nEpoch
    for ch = 1:nChan
        % 絶対PSD
        psd_tmp = PSD_all(:, ch, ep);

        % 全体の合計
        total_power = sum(psd_temp);
        
        % 相対PSD=各周波数のPSD / 1～45Hz全体の合計
        relative_PSD_all(:, ch, ep) = ...
            (psd_tmp / total_power) * 100;
    end
end

% epoch方向に平均
mean_relative_PSD = mean(relative_PSD_all, 3);


%% 絶対PSD / 相対PSD の Figure を作る

%% 代表チャネル
ch = 1;

%% -----------------------------
% 絶対PSD
%% -----------------------------
abs_psd = mean_PSD(:, ch);

figure;

subplot(3,1,1)

% 原波形
display_sec = 10;
display_samples = fs * display_sec;
t = (0:display_samples-1) / fs;

plot(t, epochs(ch,1:display_samples,1));

xlabel("時間 [s]");
ylabel("振幅 [\muV]");
title("Ch1 - 原波形");

xlim([0 display_sec]);
grid on;


%% -----------------------------
% 絶対PSD
%% -----------------------------
subplot(3,1,2)

plot(f_use, abs_psd);

xlabel("周波数 [Hz]");
ylabel("PSD");
title("Ch1 - 絶対PSD");

xlim([1 45]);
grid on;


%% -----------------------------
% 相対PSD
%% -----------------------------

% 1～45 Hzの総パワー
total_power = sum(abs_psd);

% 相対PSD
rel_psd = abs_psd / total_power;

subplot(3,1,3)

plot(f_use, rel_psd);

xlabel("周波数 [Hz]");
ylabel("相対PSD");
title("Ch1 - 相対PSD");

xlim([1 45]);
grid on;