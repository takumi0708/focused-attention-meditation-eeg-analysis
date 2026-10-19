%% view_eeg_psd.m
% GUIでEEGファイルを選択し、
% Fzの原波形・絶対PSD・相対PSDを表示する

clear;
clc;

%% 1. GUIで .set ファイルを選択

[file_name, file_path] = uigetfile( ...
    '*.set', ...
    'EEGファイルを選択してください');

% キャンセルした場合
if isequal(file_name, 0)
    disp('ファイル選択をキャンセルしました');
    return;
end

%% 2. EEG読み込み

EEG = pop_loadset( ...
    'filename', file_name, ...
    'filepath', file_path);

fprintf("Loaded file : %s\n", file_name);

%% 3. Fzチャネルを探す

channel_name = "Fz";

labels = {EEG.chanlocs.labels};

ch_idx = find(strcmpi(labels, channel_name));

if isempty(ch_idx)
    error("%s が見つかりません", channel_name);
end

fprintf("%s : channel %d\n", channel_name, ch_idx);

%% 4. Fzの波形を取得

signal = double(EEG.data(ch_idx, :));

fs = EEG.srate;

fprintf("Sampling rate : %.1f Hz\n", fs);
fprintf("Samples       : %d\n", length(signal));

%% 5. 絶対PSDを計算

[f, Pxx] = calc_absolute_psd(signal, fs);

%% 6. 相対PSDを計算

relative_psd = calc_relative_psd(Pxx);

%% 7. Figure作成

figure;

% -----------------------------------------
% 1. 原波形
% -----------------------------------------
subplot(3,1,1);

plot_eeg_waveform(signal, fs);

title(sprintf('%s / %s / EEG Waveform', ...
    file_name, channel_name), ...
    'Interpreter', 'none');


% -----------------------------------------
% 2. 絶対PSD
% -----------------------------------------
subplot(3,1,2);

plot(f, Pxx, ...
    'LineWidth', 1.2);

xlabel('Frequency (Hz)');
ylabel('PSD (\muV^2/Hz)');

title('Absolute PSD');

xlim([1 45]);

grid on;


% -----------------------------------------
% 3. 相対PSD
% -----------------------------------------
subplot(3,1,3);

plot(f, relative_psd, ...
    'LineWidth', 1.2);

xlabel('Frequency (Hz)');
ylabel('Relative PSD');

title('Relative PSD');

xlim([1 45]);

grid on;