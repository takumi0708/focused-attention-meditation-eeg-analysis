%% export_fz_psd_by_band.m
% sub-001 / Fz
%
% 4条件
%   pre-MF
%   post-MF
%   pre-MW
%   post-MW
%
% Welch法でPSDを計算し、
% delta / theta / alpha / beta ごとにCSV保存する。
%
% ※ この段階では平均・積分は行わない。
% ※ 各周波数点のPSDをそのまま保存する。

clear;
clc;


%% ========================================
% 1. 基本設定
% =========================================

subject = 'sub-001';

data_dir = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis\data\preprocessed';

output_dir = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis\results\psd\sub-001';

% 出力フォルダがなければ作成
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end


%% ========================================
% 2. 4条件のファイル
% =========================================

subject_dir = fullfile(data_dir, subject);

file_paths = {
    fullfile(subject_dir, 'pre', ...
    'sub-001_ses-premedita_task-slMedita_eeg_preproc_icrm.set')

    fullfile(subject_dir, 'post', ...
    'sub-001_ses-posmedita_task-slMedita_eeg_preproc_icrm.set')

    fullfile(subject_dir, 'pre', ...
    'sub-001_ses-premedita_task-restCE01_eeg_preproc_icrm.set')

    fullfile(subject_dir, 'post', ...
    'sub-001_ses-posmedita_task-restCE01_eeg_preproc_icrm.set')
};


% CSVの列名として使用
condition_names = {
    'pre_MF'
    'post_MF'
    'pre_MW'
    'post_MW'
};


%% ========================================
% 3. PSD保存用
% =========================================

Pxx_all = [];
f_common = [];


%% ========================================
% 4. 4条件についてPSDを計算
% =========================================

for i = 1:length(file_paths)

    fprintf('\n=============================\n');
    fprintf('%s\n', condition_names{i});
    fprintf('=============================\n');


    %% EEG読み込み

    [file_dir, file_name, file_ext] = fileparts(file_paths{i});

    EEG = pop_loadset( ...
        'filename', [file_name file_ext], ...
        'filepath', file_dir);


    %% Fzを探す

    labels = {EEG.chanlocs.labels};

    fz_idx = find(strcmpi(labels, 'Fz'));

    if isempty(fz_idx)
        error('Fzが見つかりません');
    end

    fprintf('Fz channel : %d\n', fz_idx);


    %% Fzの波形を取得

    fz_data = double(EEG.data(fz_idx, :));

    fs = EEG.srate;

    fprintf('Sampling rate : %.1f Hz\n', fs);
    fprintf('Samples       : %d\n', length(fz_data));


    %% ========================================
    % Welch PSD
    % =========================================

    window_sec = 4.096;

    window_samples = round(window_sec * fs);

    % 50% overlap
    overlap_samples = floor(window_samples / 2);

    % FFT点数
    nfft = window_samples;


    [Pxx, f] = pwelch( ...
        fz_data, ...
        hamming(window_samples), ...
        overlap_samples, ...
        nfft, ...
        fs);


    fprintf('Window samples       : %d\n', window_samples);
    fprintf('Frequency resolution : %.3f Hz\n', fs / nfft);


    %% PSDを保存

    if i == 1

        % 1条件目の周波数軸を基準にする
        f_common = f;

        Pxx_all = zeros( ...
            length(Pxx), ...
            length(file_paths));

    else

        % 条件間で周波数軸が同じか確認
        if length(f) ~= length(f_common) || ...
                any(abs(f - f_common) > 1e-10)

            error('条件間で周波数軸が一致していません');

        end

    end

    Pxx_all(:, i) = Pxx;

end


%% ========================================
% 5. 帯域を定義
% =========================================

% {名前, 最小周波数, 最大周波数}

bands = {
    'delta', 0.5,  3;
    'theta', 4,    7;
    'alpha', 8,   13;
    'beta',  14,  30
};


%% ========================================
% 6. 帯域ごとにExcelのシートへ保存
% =========================================

% Excelファイル
excel_name = sprintf( ...
    '%s_Fz_psd.xlsx', ...
    subject);

excel_path = fullfile( ...
    output_dir, ...
    excel_name);


% すでに同名ファイルがあれば削除
% → 前回の結果が残らないようにする
if exist(excel_path, 'file')
    delete(excel_path);
end


for b = 1:size(bands, 1)

    band_name = bands{b, 1};
    f_min = bands{b, 2};
    f_max = bands{b, 3};


    %% 該当する周波数を取得

    idx = ...
        f_common >= f_min & ...
        f_common <= f_max;


    %% Table作成

    T = table( ...
        f_common(idx), ...
        Pxx_all(idx, 1), ...
        Pxx_all(idx, 2), ...
        Pxx_all(idx, 3), ...
        Pxx_all(idx, 4), ...
        'VariableNames', {
            'Frequency_Hz', ...
            'pre_MF', ...
            'post_MF', ...
            'pre_MW', ...
            'post_MW'
        });


    %% MATLAB上でも表示

    fprintf('\n');
    fprintf('===== %s =====\n', upper(band_name));

    disp(T);


    %% Excelのシートに保存

    writetable( ...
        T, ...
        excel_path, ...
        'Sheet', band_name);

    fprintf('Saved sheet : %s\n', band_name);

end


%% ========================================
% 7. 完了
% =========================================

fprintf('\n');
fprintf('=============================\n');
fprintf('PSD export completed\n');
fprintf('File : %s\n', excel_path);
fprintf('=============================\n');
