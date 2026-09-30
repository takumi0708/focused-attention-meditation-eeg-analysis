%% export_psd_3subjects.m
% sub-001 ～ sub-003 のPSDを一括処理

clear;
clc;


%% ========================================
% 1. プロジェクト
% =========================================

project_root = ...
    'C:\MATLAB\focused-attention-meditation-eeg-analysis';


%% 自作関数

addpath(fullfile( ...
    project_root, ...
    'code', ...
    'functions'));


%% データ

data_root = fullfile( ...
    project_root, ...
    'data', ...
    'preprocessed');


%% 結果

result_root = fullfile( ...
    project_root, ...
    'results', ...
    'psd');


%% ========================================
% 2. 解析するチャネル
% =========================================

channel_name = 'Fz';


%% ========================================
% 3. 被験者
% =========================================

subjects = {
    'sub-001'
    'sub-002'
    'sub-003'
};


%% ========================================
% 4. 被験者ごとに実行
% =========================================

for i = 1:length(subjects)

    subject = subjects{i};


    fprintf('\n');
    fprintf('=============================\n');
    fprintf('%s / %s\n', subject, channel_name);
    fprintf('=============================\n');


    export_psd( ...
        subject, ...
        channel_name, ...
        data_root, ...
        result_root);

end


fprintf('\n');
fprintf('All subjects completed\n');