%% =========================================================
% run_ica_all.m
%
% 全被験者・全セッション・全タスクに対して
% ICA + ICLabel + IC除去を実行する
%
% 入力:
%   data/preprocessed/
%       sub-001/
%           pre/
%               slMedita/
%                   *_preproc_preica.set
%
% 出力:
%   data/processed/
%       sub-001/
%           pre/
%               *_preproc_icrm.set
%
%% =========================================================

clear;
clc;


%% =========================
% プロジェクトルート
%% =========================

project_root = ...
    "C:\MATLAB\focused-attention-meditation-eeg-analysis";


%% =========================
% パス設定
%% =========================

% 入力データ
preprocessed_dir = fullfile( ...
    project_root, ...
    "data", ...
    "preprocessed");

% ICA除去後データの保存先
processed_dir = fullfile( ...
    project_root, ...
    "data", ...
    "processed");

% 自作関数
functions_dir = fullfile( ...
    project_root, ...
    "code", ...
    "functions");

% 自作関数をMATLABから使えるようにする
addpath(functions_dir);


%% =========================
% processedフォルダを作成
%% =========================

if ~exist(processed_dir, "dir")
    mkdir(processed_dir);
end


%% =========================
% 対象
%% =========================

subjects = 1;

sessions = [
    "pre"
    "post"
];

tasks = [
    "Medita"
    "restCE01"
    "restCE02"
    "slMedita"
];


%% =========================
% ICLabelの除去基準
%% =========================
%
% ICLabelのクラス順
%
% 1 Brain
% 2 Muscle
% 3 Eye
% 4 Heart
% 5 Line Noise
% 6 Channel Noise
% 7 Other
%
% 各行:
% [下限 上限]
%
% 例:
% 0.90 1
% → そのクラスの確率が90%以上なら除去対象
%

ic_threshold = [
    NaN NaN;   % Brain
    0.90 1;    % Muscle
    0.90 1;    % Eye
    0.90 1;    % Heart
    0.90 1;    % Line Noise
    0.90 1;    % Channel Noise
    NaN NaN    % Other
];


%% =========================
% ログ保存用
%% =========================

log_subject = strings(0);
log_session = strings(0);
log_task = strings(0);
log_status = strings(0);
log_n_removed = [];
log_message = strings(0);


%% =========================
% 全被験者を処理
%% =========================

for sub = subjects

    % sub-001 の形式に変換
    subject = sprintf("sub-%03d", sub);

    fprintf("\n");
    fprintf("========================================\n");
    fprintf("Subject: %s\n", subject);
    fprintf("========================================\n");


    %% =========================
    % pre / post
    %% =========================

    for session = sessions'

        %% -------------------------
        % 入力セッションフォルダ
        %% -------------------------

        input_session_dir = fullfile( ...
            preprocessed_dir, ...
            subject, ...
            session);


        % セッションが存在しない場合
        if ~exist(input_session_dir, "dir")

            fprintf("Skip: %s does not exist\n", input_session_dir);

            continue;

        end


        %% -------------------------
        % 出力セッションフォルダ
        %% -------------------------

        output_session_dir = fullfile( ...
            processed_dir, ...
            subject, ...
            session);


        % processed/sub-XXX/pre などを作成
        if ~exist(output_session_dir, "dir")
            mkdir(output_session_dir);
        end


        %% =========================
        % 各task
        %% =========================

        for task = tasks'

            fprintf("\n");
            fprintf("----------------------------------------\n");
            fprintf("%s / %s / %s\n", ...
                subject, ...
                session, ...
                task);
            fprintf("----------------------------------------\n");


            %% -------------------------
            % taskフォルダ
            %% -------------------------

            task_dir = fullfile( ...
                input_session_dir, ...
                task);


            if ~exist(task_dir, "dir")

                fprintf("Task folder not found\n");

                continue;

            end


            %% -------------------------
            % preica.set を探す
            %% -------------------------

            files = dir(fullfile( ...
                task_dir, ...
                "*_preproc_preica.set"));


            if isempty(files)

                fprintf("preica.set not found\n");

                continue;

            end


            %% -------------------------
            % 複数ファイル対策
            %% -------------------------

            if length(files) > 1

                warning( ...
                    "Multiple preica.set files found: %s", ...
                    task_dir);

                continue;

            end


            %% -------------------------
            % 入力ファイル
            %% -------------------------

            input_file = fullfile( ...
                files(1).folder, ...
                files(1).name);


            %% -------------------------
            % 出力ファイル名
            %% -------------------------

            % 拡張子を除いたファイル名を取得
            [~, base_name, ~] = fileparts(input_file);

            % _preproc_preica
            %       ↓
            % _preproc_icrm
            output_name = strrep( ...
                base_name, ...
                '_preproc_preica', ...
                '_preproc_icrm');


            %% -------------------------
            % 出力ファイルパス
            %% -------------------------

            output_file = fullfile( ...
                output_session_dir, ...
                [output_name '.set']);


            %% -------------------------
            % すでに存在する場合はスキップ
            %% -------------------------

            if exist(output_file, "file")

                fprintf("Already exists. Skip:\n");
                fprintf("%s\n", output_file);

                continue;

            end


            %% =========================
            % ICA前処理
            %% =========================

            try

                n_removed = run_ica_preprocessing( ...
                    input_file, ...
                    output_session_dir, ...
                    ic_threshold);


                %% -------------------------
                % 成功ログ
                %% -------------------------

                log_subject(end+1, 1) = subject;
                log_session(end+1, 1) = session;
                log_task(end+1, 1) = task;
                log_status(end+1, 1) = "success";
                log_n_removed(end+1, 1) = n_removed;
                log_message(end+1, 1) = "";


                fprintf("Completed\n");


            catch ME

                %% -------------------------
                % エラーログ
                %% -------------------------

                log_subject(end+1, 1) = subject;
                log_session(end+1, 1) = session;
                log_task(end+1, 1) = task;
                log_status(end+1, 1) = "error";
                log_n_removed(end+1, 1) = NaN;
                log_message(end+1, 1) = string(ME.message);


                fprintf("ERROR\n");
                fprintf("%s\n", ...
                    getReport( ...
                        ME, ...
                        'extended', ...
                        'hyperlinks', ...
                        'off'));

            end

        end
    end
end


%% =========================
% ログをテーブル化
%% =========================

log_table = table( ...
    log_subject, ...
    log_session, ...
    log_task, ...
    log_status, ...
    log_n_removed, ...
    log_message, ...
    'VariableNames', { ...
        'subject', ...
        'session', ...
        'task', ...
        'status', ...
        'n_removed_ic', ...
        'message' ...
    });


%% =========================
% ログを保存
%% =========================

log_file = fullfile( ...
    processed_dir, ...
    "ica_processing_log.csv");


writetable( ...
    log_table, ...
    log_file);


%% =========================
% 完了表示
%% =========================

fprintf("\n");
fprintf("========================================\n");
fprintf("All processing finished\n");
fprintf("Log saved:\n%s\n", log_file);
fprintf("========================================\n");