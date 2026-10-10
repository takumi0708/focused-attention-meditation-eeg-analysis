%% compare_preica_icrm.m

clear;
clc;

%% ------------------------------------------------
% preICA ファイルを選択
%% ------------------------------------------------

[pre_file, pre_folder] = uigetfile( ...
    '*.set', ...
    'preICA ファイルを選択してください' ...
);

if isequal(pre_file, 0)
    return;
end

pre_path = fullfile(pre_folder, pre_file);


%% ------------------------------------------------
% ICA除去後ファイルを選択
%% ------------------------------------------------

[ica_file, ica_folder] = uigetfile( ...
    '*.set', ...
    'ICA除去後ファイルを選択してください' ...
);

if isequal(ica_file, 0)
    return;
end

ica_path = fullfile(ica_folder, ica_file);


%% ------------------------------------------------
% 読み込み
%% ------------------------------------------------

EEG_pre = pop_loadset(pre_path);
EEG_ica = pop_loadset(ica_path);

pre_data = double(EEG_pre.data);
ica_data = double(EEG_ica.data);


%% ------------------------------------------------
% サイズ確認
%% ------------------------------------------------

fprintf('\n--- Data size ---\n');

fprintf( ...
    'preICA : %d ch x %d samples\n', ...
    size(pre_data, 1), ...
    size(pre_data, 2) ...
);

fprintf( ...
    'ICA後  : %d ch x %d samples\n', ...
    size(ica_data, 1), ...
    size(ica_data, 2) ...
);


%% ------------------------------------------------
% 全体的な振幅を比較
%% ------------------------------------------------

% 各chの標準偏差
pre_std = std(pre_data, 0, 2);
ica_std = std(ica_data, 0, 2);

% 全chの標準偏差の平均
mean_pre_std = mean(pre_std);
mean_ica_std = mean(ica_std);

% データ全体の最大絶対値
max_pre = max(abs(pre_data(:)));
max_ica = max(abs(ica_data(:)));


fprintf('\n--- Amplitude ---\n');

fprintf( ...
    'Mean channel SD\n' ...
);

fprintf( ...
    'preICA : %.2f uV\n', ...
    mean_pre_std ...
);

fprintf( ...
    'ICA後  : %.2f uV\n', ...
    mean_ica_std ...
);


fprintf('\nMaximum absolute amplitude\n');

fprintf( ...
    'preICA : %.2f uV\n', ...
    max_pre ...
);

fprintf( ...
    'ICA後  : %.2f uV\n', ...
    max_ica ...
);


%% ------------------------------------------------
% ICA後 / preICA の比率
%% ------------------------------------------------

ratio = mean_ica_std / mean_pre_std;

fprintf('\nICA後 / preICA = %.3f\n', ratio);