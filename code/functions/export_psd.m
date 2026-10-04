function export_psd(subject, channel_name, data_root, result_root)
% export_psd
%
% 指定した被験者・チャネルについて、
% 4条件のWelch PSDを計算し、
% delta / theta / alpha / beta ごとにExcelのシートへ保存する。
%
% 入力
%   subject     : 'sub-001' など
%   channel_name: 'Fz', 'Oz', 'Cz' など
%   data_root   : 前処理済みデータのルート
%   result_root : PSD結果の保存先


%% ========================================
% 1. 4条件のファイル
% =========================================

file_paths = {
    fullfile(data_root, subject, 'pre', ...
    sprintf('%s_ses-premedita_task-slMedita_eeg_preproc_icrm.set', ...
    subject))

    fullfile(data_root, subject, 'post', ...
    sprintf('%s_ses-posmedita_task-slMedita_eeg_preproc_icrm.set', ...
    subject))

    fullfile(data_root, subject, 'pre', ...
    sprintf('%s_ses-premedita_task-restCE01_eeg_preproc_icrm.set', ...
    subject))

    fullfile(data_root, subject, 'post', ...
    sprintf('%s_ses-posmedita_task-restCE01_eeg_preproc_icrm.set', ...
    subject))
};


condition_names = {
    'pre_MF'
    'post_MF'
    'pre_MW'
    'post_MW'
};


%% ========================================
% 2. 出力先
% =========================================

output_dir = fullfile( ...
    result_root, ...
    subject);

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end


excel_name = sprintf( ...
    '%s_%s_psd.xlsx', ...
    subject, ...
    channel_name);

excel_path = fullfile( ...
    output_dir, ...
    excel_name);


% 前回のファイルを削除
if exist(excel_path, 'file')

    try
        delete(excel_path);

    catch
        error( ...
            '%s を削除できません。Excelで開いていないか確認してください。', ...
            excel_path);
    end

end


%% ========================================
% 3. PSD保存用
% =========================================

Pxx_all = [];
f_common = [];


%% ========================================
% 4. 4条件を処理
% =========================================

for i = 1:length(file_paths)

    fprintf('  %s\n', condition_names{i});


    %% ファイル確認

    if ~exist(file_paths{i}, 'file')
        error('ファイルが見つかりません:\n%s', file_paths{i});
    end


    %% EEG読み込み

    [file_dir, file_name, file_ext] = ...
        fileparts(file_paths{i});

    EEG = pop_loadset( ...
        'filename', [file_name file_ext], ...
        'filepath', file_dir);


    %% ========================================
    % 指定されたチャネルを探す
    % =========================================

    labels = {EEG.chanlocs.labels};

    channel_idx = find( ...
        strcmpi(labels, channel_name), ...
        1);


    if isempty(channel_idx)

        error( ...
            '%s : %s が見つかりません', ...
            subject, ...
            channel_name);

    end


    %% 波形取得

    channel_data = double( ...
        EEG.data(channel_idx, :));

    fs = EEG.srate;


    %% ========================================
    % Welch PSD
    % =========================================

    window_sec = 4.096;

    window_samples = ...
        round(window_sec * fs);

    % 50% overlap
    overlap_samples = ...
        floor(window_samples / 2);

    % FFT点数
    nfft = window_samples;


    [Pxx, f] = pwelch( ...
        channel_data, ...
        hamming(window_samples), ...
        overlap_samples, ...
        nfft, ...
        fs);


    %% ========================================
    % PSD保存
    % =========================================

    if i == 1

        f_common = f;

        Pxx_all = zeros( ...
            length(Pxx), ...
            length(file_paths));

    else

        % 周波数軸が4条件で同じか確認
        if length(f) ~= length(f_common) || ...
                any(abs(f - f_common) > 1e-10)

            error( ...
                '%s : 条件間で周波数軸が一致していません', ...
                subject);

        end

    end


    Pxx_all(:, i) = Pxx;

end


%% ========================================
% 5. 周波数帯域
% =========================================

bands = {
    'delta', 0.5,  3;
    'theta', 4,    7;
    'alpha', 8,   13;
    'beta',  14,  30
};


%% ========================================
% 6. Excelに保存
% =========================================

for b = 1:size(bands, 1)

    band_name = bands{b, 1};
    f_min = bands{b, 2};
    f_max = bands{b, 3};


    % 帯域に該当する周波数
    idx = ...
        f_common >= f_min & ...
        f_common <= f_max;


    %% Table

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


    %% Excelシートへ保存

    writetable( ...
        T, ...
        excel_path, ...
        'Sheet', band_name);

end


fprintf( ...
    '  Saved: %s\n', ...
    excel_path);

end