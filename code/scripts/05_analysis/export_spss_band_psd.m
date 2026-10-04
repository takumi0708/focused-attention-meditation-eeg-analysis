%% export_spss_band_psd.m
% 各被験者のPSD Excelを読み込み、
% 帯域ごとの平均PSDを計算する。
%
% 出力Excel
%   delta
%   theta
%   alpha
%   beta
%
% 各シート
%   subject | pre_MF | post_MF | pre_MW | post_MW

clear;
clc;


%% ========================================
% 1. プロジェクト設定
% =========================================

project_root = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis';

addpath(fullfile( ...
    project_root, ...
    'code', ...
    'functions'));


%% ========================================
% 2. 設定
% =========================================

% チャネル
channel_name = 'Fz';


% 対象被験者
subjects = {
    'sub-001'
    'sub-002'
    'sub-003'
};


% 対象帯域
bands = {
    'delta'
    'theta'
    'alpha'
    'beta'
};


%% ========================================
% 3. ディレクトリ
% =========================================

psd_root = fullfile( ...
    project_root, ...
    'results', ...
    'psd');


output_dir = fullfile( ...
    project_root, ...
    'results', ...
    'statistics');


if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end


%% ========================================
% 4. 出力Excel
% =========================================

output_name = sprintf( ...
    '%s_mean_psd_SPSS.xlsx', ...
    channel_name);

output_path = fullfile( ...
    output_dir, ...
    output_name);


% 前回の結果を削除
if exist(output_path, 'file')

    try
        delete(output_path);

    catch
        error( ...
            'Excelファイルを閉じてから実行してください:\n%s', ...
            output_path);
    end

end


%% ========================================
% 5. 帯域ごとに処理
% =========================================

for b = 1:length(bands)

    band_name = bands{b};

    fprintf('\n');
    fprintf('=============================\n');
    fprintf('%s\n', upper(band_name));
    fprintf('=============================\n');


    % この帯域の全被験者結果
    all_results = table();


    %% ========================================
    % 6. 被験者ごとに処理
    % =========================================

    for i = 1:length(subjects)

        subject = subjects{i};

        fprintf('Processing : %s\n', subject);


        %% PSD Excelの場所

        excel_path = fullfile( ...
            psd_root, ...
            subject, ...
            sprintf( ...
                '%s_%s_psd.xlsx', ...
                subject, ...
                channel_name));


        %% ファイル確認

        if ~exist(excel_path, 'file')

            error( ...
                'PSD Excelが見つかりません:\n%s', ...
                excel_path);

        end


        %% 指定帯域の平均PSD

        result = calc_mean_band_psd( ...
            excel_path, ...
            band_name);


        %% subject列を追加

        result = addvars( ...
            result, ...
            {subject}, ...
            'Before', 1, ...
            'NewVariableNames', 'subject');


        %% 縦方向に連結

        all_results = [
            all_results;
            result
        ];

    end


    %% ========================================
    % 7. 帯域ごとにシート保存
    % =========================================

    writetable( ...
        all_results, ...
        output_path, ...
        'Sheet', band_name);


    fprintf('Saved sheet : %s\n', band_name);

end


%% ========================================
% 8. 完了
% =========================================

fprintf('\n');
fprintf('=============================\n');
fprintf('SPSS data export completed\n');
fprintf('=============================\n');

fprintf('Saved : %s\n', output_path);